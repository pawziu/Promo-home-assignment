//
//  ExchangeRatesManager.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

protocol ExchangeRatesManaging {
    func getCurrentExchangePairs() -> AnyPublisher<SupportedExchangeRatesPairs, APIError>
    func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError>
}

final class ExchangeRatesManager: ExchangeRatesManaging {
    
    // MARK: - Properties
    
    private let api = API.shared
    
    // MARK: - Managing
    
    func getCurrentExchangePairs() -> AnyPublisher<SupportedExchangeRatesPairs, APIError> {
        let request = ExchangeRatesListRequest()
        return api.call(with: request)
    }
    
    func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError> {
        let request = ExchangeRateRequest(currency: currency)
        return api.call(with: request)
    }
}
