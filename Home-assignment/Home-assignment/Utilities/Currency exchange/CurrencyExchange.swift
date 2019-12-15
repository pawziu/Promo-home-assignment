//
//  CurrencyExchange.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

protocol CurrencyExchanging {
    var exchangeAvailable: AnyPublisher<Bool, Never> { get }
    var availableCurrencies: AnyPublisher<[Currency], Never> { get }
       
    var currentCurrency: Currency { get }
    var chosenCurrency: AnyPublisher<Currency, Never> { get }

    func setCurrency(_ currency: Currency)
    func exchange(_ givenAmount: Decimal) -> Decimal
}

final class CurrencyExchange: CurrencyExchanging {
    
    private enum Configuration {
        static var currencyRefreshTime: TimeInterval { 5.0 }
    }
    
    // MARK: - Instance
    
    static let shared = CurrencyExchange()
    
    // MARK: - Dependencies
    
    private let api: APIProtocol
    
    // MARK: - Properties
    
    lazy var exchangeAvailable: AnyPublisher<Bool, Never> = exchangeAvailableSubject
        .eraseToAnyPublisher()
    
    lazy var availableCurrencies: AnyPublisher<[Currency], Never> = availableCurrenciesSubject
        .eraseToAnyPublisher()
    
    lazy var chosenCurrency: AnyPublisher<Currency, Never> = currentAvailableCurrencySubject
        .eraseToAnyPublisher()
    
    var currentCurrency: Currency {
        currentAvailableCurrencySubject.value
    }
    
    private let referenceCurrency: Currency = .default

    // MARK: - Subjects
    
    private let exchangeAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    private let loadDataSubject = PassthroughSubject<Void, APIError>()
    private let availableCurrenciesSubject = CurrentValueSubject<[Currency], Never>([])
    private let chosenCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentAvailableCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentExchangeRateSubject = CurrentValueSubject<Decimal, Never>(1.0)
    
    private let currentTimePublisher = Timer.TimerPublisher(interval: Configuration.currencyRefreshTime, runLoop: .current, mode: .default)
    
    private var disposables = Set<AnyCancellable>()
    private let timerCancellable: AnyCancellable?
    
    // MARK: - Initialization
    
    private init(api: APIProtocol = API.shared) {
        self.api = api
        timerCancellable = currentTimePublisher.connect() as? AnyCancellable
        setupBindings()
        loadDataSubject.send(())
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        let defaultChosen = chosenCurrencySubject
            .removeDuplicates()
            .filter { $0 == .default }
            .share()
        
        defaultChosen
            .subscribe(currentAvailableCurrencySubject)
            .store(in: &disposables)
        
        defaultChosen
            .map { _ in 1.0 }
            .subscribe(currentExchangeRateSubject)
            .store(in: &disposables)
        
        let availableCurrencies = loadDataSubject
            .flatMap { [weak self] _ -> AnyPublisher<SupportedExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.getCurrentExchangePairs()
            }
            .catch { [weak self] _ -> Empty<SupportedExchangeRatesPairs, Never> in
                self?.disableExchange()
                return Empty(completeImmediately: false)
            }
            .map { $0.supportedCurrencies }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.exchangeAvailableSubject.send(true)
            })
            .share()
            .eraseToAnyPublisher()
        
        let exchangeRate = Publishers
            .Merge(
                currentTimePublisher
                    .map { _ in return self.chosenCurrencySubject.value },
                chosenCurrencySubject
                    .removeDuplicates()
            )
            .filter { $0 != .default }
            .setFailureType(to: APIError.self)
            .flatMap(maxPublishers: .max(1)) { [weak self] currency -> AnyPublisher<ExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.getExchangeRate(for: currency)
            }
            .catch { [weak self] _ -> Empty<ExchangeRatesPairs, Never> in
                self?.disableExchange()
                return Empty(completeImmediately: false)
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.exchangeAvailableSubject.send(true)
            })
            .map { $0.rates.first?.value.rate ?? .zero }
            .share()
            .eraseToAnyPublisher()
        
        bindAvailableCurrencies(availableCurrencies)
        bindExchangeRate(exchangeRate)
        bindCurrencySubject(exchangeRate)
    }
    
    private func bindAvailableCurrencies(_ availableCurrencies: AnyPublisher<[Currency], Never>) {
        availableCurrencies
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.bindAvailableCurrencies(availableCurrencies)
            })
            .subscribe(availableCurrenciesSubject)
            .store(in: &disposables)
    }
    
    private func bindExchangeRate(_ exchangeRate: AnyPublisher<Decimal, Never>) {
        exchangeRate
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.bindExchangeRate(exchangeRate)
            })
            .subscribe(currentExchangeRateSubject)
            .store(in: &disposables)
    }
    
    private func bindCurrencySubject(_ exchangeRate: AnyPublisher<Decimal, Never>) {
        exchangeRate
            .map { _ in return self.chosenCurrencySubject.value }
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.bindCurrencySubject(exchangeRate)
            })
            .subscribe(currentAvailableCurrencySubject)
            .store(in: &disposables)
    }
    
    private func disableExchange() {
        exchangeAvailableSubject.send(false)
        currentAvailableCurrencySubject.send(.default)
        currentExchangeRateSubject.send(1.0)
    }
    
    // MARK: - Exchanging
    
    func setCurrency(_ currency: Currency) {
        chosenCurrencySubject.send(currency)
    }
    
    func exchange(_ givenAmount: Decimal) -> Decimal {
        guard chosenCurrencySubject.value == currentAvailableCurrencySubject.value else { return givenAmount }
        guard chosenCurrencySubject.value != referenceCurrency else { return givenAmount }
        return givenAmount * currentExchangeRateSubject.value
    }
    
    // MARK: - Data downloading
    
    private func getCurrentExchangePairs() -> AnyPublisher<SupportedExchangeRatesPairs, APIError> {
        let request = ExchangeRatesListRequest()
        return api.call(with: request)
    }
    
    private func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError> {
        let request = ExchangeRateRequest(currency: currency)
        return api.call(with: request)
    }
}
