//
//  CheckoutViewModelTests.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import XCTest
import Combine
@testable import Home_assignment

class CheckoutViewModelTests: XCTestCase {
    
    private var currencyExchangeMock: CurrencyExchangeMock!
    private var systemUnderTests: CheckoutViewModel!

    override func setUp() {
        currencyExchangeMock = Mocks.currencyExchangeMock
        systemUnderTests = CheckoutViewModel(
            products: Mocks.productsViewModels,
            currencyExchange: currencyExchangeMock
        )
    }

    override func tearDown() {
        currencyExchangeMock = nil
        systemUnderTests = nil
    }
    
    func testInitialTotalAmount() {
        // Given
        let totalPrice: Decimal = Mocks.productsViewModels
            .reduce(into: 0) { price, product in
                price += product.totalPrice
            }
        
        // Then
        XCTAssert(systemUnderTests.totalAmount == totalPrice)
    }

    func testCurrencyChange() {
        // Given
        let testReceive = expectedResult(publisher: systemUnderTests.$currencyName, expectedResponse: Mocks.currencyPLN.name)
        
        // When
        currencyExchangeMock.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
}
