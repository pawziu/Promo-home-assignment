//
//  ShoppingListViewModelTests.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import XCTest
@testable import Home_assignment

class ShoppingListViewModelTests: XCTestCase {
    
    private var jsonLoaderMock: JSONLoaderMock!
    private var currencyExchangeMock: CurrencyExchangeMock!
    private var systemUnderTests: ShoppingListViewModel!

    override func setUp() {
        jsonLoaderMock = JSONLoaderMock()
        currencyExchangeMock = CurrencyExchangeMock()
        systemUnderTests = ShoppingListViewModel(
            jsonLoader: jsonLoaderMock,
            currencyExchange: currencyExchangeMock
        )
    }

    override func tearDown() {
        jsonLoaderMock = nil
        currencyExchangeMock = nil
        systemUnderTests = nil
    }

    func testLoadData() {
        // Given
        let products = Mocks.productsViewModels
        
        // Then
        let testReceive = expectedResult(publisher: systemUnderTests.$dataSource, expectedResponse: products)
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
        XCTAssert(systemUnderTests.checkoutItems == [])
    }
    
    func testCheckoutItems() {
        // Given
        let expectedCheckoutItems = [
            ProductViewModel(
                product: Mocks.product,
                currencyName: Currency.default.name,
                count: 2
            )
        ]
        
        let predictionReceive = expectedResult(publisher: systemUnderTests.$dataSource, expectedResponse: Mocks.productsViewModels)
        wait(for: predictionReceive.expectations)
        predictionReceive.cancellable?.cancel()
        
        // When
        systemUnderTests.dataSource.first?.increaseCount()
        systemUnderTests.dataSource.first?.increaseCount()
        
        // Then
        let testReceive = expectedResult(
            publisher: systemUnderTests.$checkoutItems.removeDuplicates(),
            expectedResponse: expectedCheckoutItems
        )
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testChangeCurrency() {
        // Given
        let testReceive = expectedResult(
            publisher: systemUnderTests.$currencyName.removeDuplicates(),
            expectedResponse: Mocks.currencyPLN.name
        )
        
        // When
        currencyExchangeMock.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testCurrencyExchange() {
        // Given
        let expectedDataSource = Mocks.productsViewModels
        expectedDataSource.forEach {
            $0.calculatedPrice = Mocks.price * Mocks.currencyPLNRate
            $0.currencyName = Mocks.currencyPLN.name
        }
        let testReceive = expectedResult(
            publisher: systemUnderTests.$dataSource,
            expectedResponse: expectedDataSource
        )
        
        // When
        currencyExchangeMock.setCurrency(Mocks.currencyPLN)
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
    
    func testTotalAmount() {
        // Given
        let predictionReceive = expectedResult(publisher: systemUnderTests.$dataSource.removeDuplicates(), expectedResponse: Mocks.productsViewModels)
        wait(for: predictionReceive.expectations)
        predictionReceive.cancellable?.cancel()
        
        let expectedPrice = Decimal(Mocks.productsViewModels.count) * Mocks.price * Mocks.currencyPLNRate
        let testReceive = expectedResult(
            publisher: systemUnderTests.$totalAmount.removeDuplicates(),
            expectedResponse: expectedPrice
        )
        
        // When
        currencyExchangeMock.setCurrency(Mocks.currencyPLN)
        systemUnderTests.dataSource.forEach {
            $0.increaseCount()
        }
        
        // Then
        wait(for: testReceive.expectations)
        testReceive.cancellable?.cancel()
    }
}
