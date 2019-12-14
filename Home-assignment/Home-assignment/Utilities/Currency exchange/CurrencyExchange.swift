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
    var currentAvailableCurrency: AnyPublisher<Currency, Never> { get }
    var availableCurrencies: [Currency] { get }
    var exchangeAvailable: Bool { get }
    
    func setCurrency(_ currency: Currency)
    func exchange(_ givenAmount: Decimal) -> Decimal
}

final class CurrencyExchange: CurrencyExchanging {
    
    // MARK: - Instance
    
    static let shared = CurrencyExchange()
    
    var availableCurrencies: [Currency] = []
    var exchangeAvailable: Bool = false
    var currentAvailableCurrency: AnyPublisher<Currency, Never> {
        currentAvailableCurrencySubject.eraseToAnyPublisher()
    }
    
    // MARK: - Properties
    
    private var currentExchangeRate: Decimal = .zero
    private let referenceCurrency: Currency = .default
    
    private let chosenCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentAvailableCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
    private let currentTimePublisher = Timer.TimerPublisher(interval: 60.0, runLoop: .current, mode: .common)
    
    private var disposables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        getCurrentExchangePairs()
            .map { $0.supportedCurrencies }
            .sink(receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .finished:
                    self.exchangeAvailable = true
                case .failure(_):
                    self.exchangeAvailable = false
                }
            }) { [weak self] currencies in
                guard let self = self else { return}
                self.availableCurrencies = currencies
                self.exchangeAvailable = true
            }
            .store(in: &disposables)
        
        Publishers
            .Merge(
                currentTimePublisher.combineLatest(chosenCurrencySubject).map { $0.1 },
                chosenCurrencySubject
            )
            .filter { $0 != .default }
            .setFailureType(to: APIError.self)
            .flatMap(maxPublishers: .max(1)) { [weak self] currency -> AnyPublisher<ExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.getExchangeRate(for: currency)
            }
            .map { $0.rates.first?.value.rate ?? .zero }
            .catch { _ -> Empty<Decimal, APIError> in Empty(completeImmediately: false) }
            .sink(receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .failure:
                  self.exchangeAvailable = false
                case .finished:
                  self.exchangeAvailable = true
                }
            }) { [weak self] exchangeRate in
                guard let self = self else { return}
                self.currentExchangeRate = exchangeRate
                self.currentAvailableCurrencySubject.send(self.chosenCurrencySubject.value)
                self.exchangeAvailable = true
            }
            .store(in: &disposables)
    }
    
    // MARK: - Exchanging
    
    func setCurrency(_ currency: Currency) {
        chosenCurrencySubject.send(currency)
    }
    
    func exchange(_ givenAmount: Decimal) -> Decimal {
        guard chosenCurrencySubject.value != referenceCurrency else { return givenAmount }
        return givenAmount * currentExchangeRate
    }
    
    // MARK: - Data
    
    private func getCurrentExchangePairs() -> AnyPublisher<SupportedExchangeRatesPairs, APIError> {
        let request = ExchangeRatesListRequest()
        return API.shared.call(with: request)
    }
    
    private func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError> {
        let request = ExchangeRateRequest(currency: currency)
        return API.shared.call(with: request)
    }
}
