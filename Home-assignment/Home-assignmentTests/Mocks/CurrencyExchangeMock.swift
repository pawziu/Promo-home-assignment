//
//  CurrencyExchangeMock.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine
@testable import Home_assignment

final class CurrencyExchangeMock: CurrencyExchanging {
    
    // MARK: - Protocol
    
    lazy var exchangeAvailable: AnyPublisher<Bool, Never> = Just(true).eraseToAnyPublisher()
    var availableCurrencies: AnyPublisher<[Currency], Never> { Just(Mocks.availableCurrencies).eraseToAnyPublisher() }
    var currentCurrency: Currency { .default }
    lazy var chosenCurrency: AnyPublisher<Currency, Never> = currentCurrencySubject.eraseToAnyPublisher()
    
    func setCurrency(_ currency: Currency) {
        currentCurrencySubject.send(currency)
    }
    
    func exchange(_ givenAmount: Decimal) -> Decimal {
        switch currentCurrency {
        case Mocks.currencyPLN: return givenAmount * Mocks.currencyPLNRate
        default: return givenAmount
        }
    }
    
    // MARK: - Properties
    
    private let currentCurrencySubject = CurrentValueSubject<Currency, Never>(.default)
}
