//
//  CurrencyPickerViewModelTests.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import XCTest
@testable import Home_assignment

class CurrencyPickerViewModelTests: XCTestCase {
    
    private var currencyExchangeMock: CurrencyExchangeMock!
    private var systemUnderTests: CurrencyPickerViewModel!

    override func setUp() {
        currencyExchangeMock = Mocks.currencyExchangeMock
        systemUnderTests = CurrencyPickerViewModel(currencyExchange: currencyExchangeMock)
    }

    override func tearDown() {
        currencyExchangeMock = nil
        systemUnderTests = nil
    }
    
    func testCurrenciesList() {
        // When
        let testReceive = expectedResult(publisher: systemUnderTests.$currencies, expectedResponse: Mocks.availableCurrencies)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testSelectedCurrency() {
        // When
        let testReceive = expectedResult(publisher: currencyExchangeMock.chosenCurrency, expectedResponse: Mocks.currencyPLN)
        
        // Then
        systemUnderTests.selectedCurrency = Mocks.currencyPLN
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testExchangeAvailable() {
        // When
        let testReceive = expectedResult(publisher: systemUnderTests.$exchangeAvailable, expectedResponse: true)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
}
