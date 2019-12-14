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
    var currentCurrency: Currency { get }
    var availableCurrencies: [Currency] { get }
    var exchangeAvailable: Bool { get }
    
    func setCurrency(_ currency: Currency)
    func exchange(_ givenAmount: Decimal) -> Decimal
}

final class CurrencyExchange: CurrencyExchanging {
    
    // MARK: - Instance
    
    static let shared = CurrencyExchange()
    
    @Published var availableCurrencies: [Currency] = []
    @Published var exchangeAvailable: Bool = false
    @Published var currentCurrency: Currency = .default
    
    // MARK: - Properties
    
    @Published private var chosenCurrency: Currency = .default
    @Published private var currentExchangeRate: Decimal = .zero
    private let referenceCurrency: Currency = .default
    
    private let availableCurrenciesSubject = CurrentValueSubject<[Currency], APIError>([])
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
            .CombineLatest($availableCurrencies, $chosenCurrency)
            .filter { $0.0.contains($0.1) }
            .map { $0.1 }
            .setFailureType(to: APIError.self)
            .flatMap(maxPublishers: .max(1)) { [weak self] currency -> AnyPublisher<ExchangeRatesPairs, APIError> in
                guard let self = self else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                return self.getExchangeRate(for: currency)
            }
            .map { $0.rates.first?.rate ?? .zero }
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
                self.currentCurrency = self.chosenCurrency
                self.exchangeAvailable = true
            }
            .store(in: &disposables)
    }
    
    // MARK: - Exchanging
    
    func setCurrency(_ currency: Currency) {
        chosenCurrency = currency
    }
    
    func exchange(_ givenAmount: Decimal) -> Decimal {
        guard chosenCurrency != referenceCurrency else { return givenAmount }
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
