//
//  CurrencyExchangeTests.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 17/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import XCTest
import Combine
@testable import Home_assignment

class CurrencyExchangeTests: XCTestCase {
    
    private var systemUnderTests: CurrencyExchange!
    private var failingSystemUnderTests: CurrencyExchange!

    override func setUp() {
        systemUnderTests = CurrencyExchange(exchangeRatesManager: ExchangeRateManagerMock())
        failingSystemUnderTests = CurrencyExchange(exchangeRatesManager: ExchangeRateManagerFailingMock())
    }

    override func tearDown() {
        systemUnderTests = nil
        failingSystemUnderTests = nil
    }

    func testExchangeAvailable() {
        // When
        let testReceive = expectedResult(
            publisher: systemUnderTests.exchangeAvailable,
            expectedResponse: true
        )
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testExchangeNotAvailable() {
        // When
        let testReceive = expectedResult(
            publisher: failingSystemUnderTests.exchangeAvailable,
            expectedResponse: false
        )
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testAvailableCurrencies() {
        // When
        let testReceive = expectedResult(
            publisher: systemUnderTests.availableCurrencies,
            expectedResponse: Mocks.availableCurrencies
        )
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testSetCurrency() {
        // Given
        let testReceive = expectedResult(
            publisher: systemUnderTests.chosenCurrency,
            expectedResponse: Mocks.currencyPLN
        )
        
        // When
        systemUnderTests.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
        XCTAssert(systemUnderTests.currentCurrency == Mocks.currencyPLN)
    }
    
    func testFailingSetCurrency() {
        // Given
        let testReceive = expectedResult(
            publisher: failingSystemUnderTests.chosenCurrency,
            expectedResponse: Currency.default
        )
        
        // When
        systemUnderTests.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testExchange() {
        // Given
        let testReceive = expectedResult(
            publisher: systemUnderTests.chosenCurrency,
            expectedResponse: Mocks.currencyPLN
        )
        
        // When
        systemUnderTests.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
        XCTAssert(systemUnderTests.exchange(Mocks.price) == Mocks.price * Mocks.currencyPLNRate)
    }
    
    func setFailingExchange() {
        // Given
        let testReceive = expectedResult(
            publisher: systemUnderTests.chosenCurrency,
            expectedResponse: Currency.default
        )
        
        // When
        systemUnderTests.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
        XCTAssert(systemUnderTests.exchange(Mocks.price) == Mocks.price)
    }
}
