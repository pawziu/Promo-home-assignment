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
        static var defaultExchangeRate: Decimal { 1.0 }
        static var allowedRetryTimes: Int { 1 }
    }
    
    // MARK: - Instance
    
    static let shared = CurrencyExchange()
    
    // MARK: - Dependencies
    
    private let exchangeRatesManager: ExchangeRatesManaging
    
    // MARK: - Properties
    
    lazy var exchangeAvailable: AnyPublisher<Bool, Never> = exchangeAvailableSubject.eraseToAnyPublisher()
    lazy var availableCurrencies: AnyPublisher<[Currency], Never> = availableCurrenciesSubject.eraseToAnyPublisher()
    lazy var chosenCurrency: AnyPublisher<Currency, Never> = currentAvailableCurrencySubject.eraseToAnyPublisher()
    var currentCurrency: Currency { currentAvailableCurrencySubject.value }
    
    private let referenceCurrency: Currency = .default
    private let currentTimePublisher = Timer.TimerPublisher(interval: Configuration.currencyRefreshTime, runLoop: .current, mode: .default)
    private var disposables = Set<AnyCancellable>()
    private let timerCancellable: AnyCancellable?
    
    // MARK: - Subjects
    
    private let exchangeAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    private let loadDataSubject = PassthroughSubject<Void, APIError>()
    private let availableCurrenciesSubject = CurrentValueSubject<[Currency], Never>([])
    private let chosenCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let chosenCurrencyPassthroughSubject = PassthroughSubject<Currency, Never>()
    private let currentAvailableCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentExchangeRateSubject = CurrentValueSubject<Decimal, Never>(1.0)
    
    // MARK: - Initialization
    
    init(exchangeRatesManager: ExchangeRatesManaging = ExchangeRatesManager()) {
        self.exchangeRatesManager = exchangeRatesManager
        timerCancellable = currentTimePublisher.connect() as? AnyCancellable
        setupBindings()
        loadDataSubject.send(())
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        bindAvailableCurrencies()
        bindDefaultCurrency()
        bindExchangeRate()
    }
    
    private func bindDefaultCurrency() {
        let defaultChosen = chosenCurrencySubject
            .removeDuplicates()
            .filter { $0 == .default }
            .share()
        
        defaultChosen
            .subscribe(currentAvailableCurrencySubject)
            .store(in: &disposables)
        
        defaultChosen
            .map { _ in Configuration.defaultExchangeRate }
            .subscribe(currentExchangeRateSubject)
            .store(in: &disposables)
    }
    
    private func bindAvailableCurrencies() {
        loadDataSubject
            .flatMap { [weak self] _ -> AnyPublisher<SupportedExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.exchangeRatesManager.getCurrentExchangePairs()
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
            .subscribe(availableCurrenciesSubject)
            .store(in: &disposables)
    }
    
    private func bindExchangeRate() {
        chosenCurrencySubject
            .subscribe(chosenCurrencyPassthroughSubject)
            .store(in: &disposables)
        
        let exchangeRate = getExchangeRate()
            .catch { _ -> Empty<ExchangeRatesPairs, Never> in
                return Empty(completeImmediately: true)
            }
            .map { $0.rates.first?.value.rate ?? .zero }
            .share()
            .eraseToAnyPublisher()
        
        exchangeRate
            .subscribe(currentExchangeRateSubject)
            .store(in: &disposables)
        
        exchangeRate
            .map { _ in return self.chosenCurrencySubject.value }
            .subscribe(currentAvailableCurrencySubject)
            .store(in: &disposables)
    }
    
    private func getExchangeRate() -> AnyPublisher<ExchangeRatesPairs, APIError> {
        return Publishers
            .Merge(
                currentTimePublisher
                    .map { _ in return self.chosenCurrencySubject.value },
                chosenCurrencyPassthroughSubject
                    .removeDuplicates()
            )
            .filter { $0 != .default }
            .setFailureType(to: APIError.self)
            .flatMap(maxPublishers: .max(1)) { [weak self] currency -> AnyPublisher<ExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.exchangeRatesManager.getExchangeRate(for: currency)
            }
            .retry(Configuration.allowedRetryTimes)
            .catch { [weak self] _ -> AnyPublisher<ExchangeRatesPairs, APIError> in
                guard let self = self else { assertionFailure(); return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.getExchangeRate()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Error handling
    
    private func disableExchange() {
        exchangeAvailableSubject.send(false)
        currentAvailableCurrencySubject.send(.default)
        currentExchangeRateSubject.send(Configuration.defaultExchangeRate)
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
}
