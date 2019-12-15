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
    var exchangeAvailable: Bool { get }
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
    
    // MARK: - Properties
    
    var exchangeAvailable: Bool = false
    
    lazy var availableCurrencies: AnyPublisher<[Currency], Never> = availableCurrenciesSubject.eraseToAnyPublisher()
    lazy var chosenCurrency: AnyPublisher<Currency, Never> = currentAvailableCurrencySubject.eraseToAnyPublisher()
    
    var currentCurrency: Currency {
        currentAvailableCurrencySubject.value
    }
    
    // MARK: - Properties
    
    private let referenceCurrency: Currency = .default
    
    private let availableCurrenciesSubject = CurrentValueSubject<[Currency], Never>([])
    private let chosenCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentAvailableCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentExchangeRateSubject = CurrentValueSubject<Decimal, Never>(1.0)
    
    private let currentTimePublisher = Timer.TimerPublisher(interval: Configuration.currencyRefreshTime, runLoop: .main, mode: .default)
    
    private var disposables = Set<AnyCancellable>()
    private let timerCancellable: AnyCancellable?
    
    // MARK: - Initialization
    
    private init() {
        timerCancellable = currentTimePublisher.connect() as? AnyCancellable
        setupBindings()
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        getCurrentExchangePairs()
            .map { $0.supportedCurrencies }
            .catch { [weak self] _ -> Empty<[Currency], Never> in
                self?.exchangeAvailable = false
                return Empty(completeImmediately: false)
            }
            .share()
            .subscribe(availableCurrenciesSubject)
            .store(in: &disposables)
        
        let exchangeRate = Publishers
            .Merge(
                currentTimePublisher
                    .map { _ in return self.chosenCurrencySubject.value },
                chosenCurrencySubject
            )
            .filter { $0 != .default }
            .setFailureType(to: APIError.self)
            .flatMap(maxPublishers: .max(1)) { [weak self] currency -> AnyPublisher<ExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.getExchangeRate(for: currency)
            }
            .map { $0.rates.first?.value.rate ?? .zero }
            .catch { [weak self] _ -> Empty<Decimal, Never> in
                self?.exchangeAvailable = false
                return Empty(completeImmediately: false)
            }
            .share()
        
        exchangeRate
            .map { _ in return self.chosenCurrencySubject.value }
            .subscribe(currentAvailableCurrencySubject)
            .store(in: &disposables)
        
        exchangeRate
            .subscribe(currentExchangeRateSubject)
            .store(in: &disposables)
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
        return API.shared.call(with: request)
    }
    
    private func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError> {
        let request = ExchangeRateRequest(currency: currency)
        return API.shared.call(with: request)
    }
}
