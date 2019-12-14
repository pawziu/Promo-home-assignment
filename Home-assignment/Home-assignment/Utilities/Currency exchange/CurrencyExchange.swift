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
    var chosenCurrency: Currency { get set }
    func exchange(_ givenAmount: Decimal) -> Decimal
}

final class CurrencyExchange: CurrencyExchanging {
    
    // MARK: - Instance
    
    static let shared = CurrencyExchange()
    
    // MARK: - Input
    
    @Published var chosenCurrency: Currency = .default
    
    // MARK: - Output
    
    private(set) lazy var availableCurrencies = availableCurrenciesSubject
        .eraseToAnyPublisher()
        .replaceError(with: [])
    
    // MARK: - Properties
    
    private let referenceCurrency: Currency = .default
    private var currentExchangeRate: Decimal = .zero
    
    private let availableCurrenciesSubject = CurrentValueSubject<[Currency], APIError>([])
    private var disposables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        getCurrentExchangePairs()
            .map { $0.supportedCurrencies }
            .subscribe(availableCurrenciesSubject)
            .store(in: &disposables)
        
        Publishers
            .CombineLatest(availableCurrencies, $chosenCurrency)
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
                  break
                case .finished:
                  break
                }
            }) { [weak self] exchangeRate in
                guard let self = self else { return}
                self.currentExchangeRate = exchangeRate
            }
            .store(in: &disposables)
    }
    
    // MARK: - Exchanging
    
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
