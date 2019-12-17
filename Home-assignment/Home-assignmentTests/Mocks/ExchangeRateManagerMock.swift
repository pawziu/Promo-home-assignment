//
//  ExchangeRateManagerMock.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 17/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine
@testable import Home_assignment

final class ExchangeRateManagerMock: ExchangeRatesManaging {
    func getCurrentExchangePairs() -> AnyPublisher<SupportedExchangeRatesPairs, APIError> {
        return Just(Mocks.supportedExchangePairs)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
    
    func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError> {
        return Just(Mocks.exchangeRatePair)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}

final class ExchangeRateManagerFailingMock: ExchangeRatesManaging {
    func getCurrentExchangePairs() -> AnyPublisher<SupportedExchangeRatesPairs, APIError> {
        return Fail(error: APIError.unknown)
            .eraseToAnyPublisher()
    }
    
    func getExchangeRate(for currency: Currency) -> AnyPublisher<ExchangeRatesPairs, APIError> {
        return Fail(error: APIError.unknown)
            .eraseToAnyPublisher()
    }
}
