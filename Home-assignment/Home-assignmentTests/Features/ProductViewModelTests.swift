//
//  ProductViewModelTests.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import XCTest
@testable import Home_assignment

final class ProductViewModelTests: XCTestCase {
    
    private var systemUnderTests: ProductViewModel!

    override func setUp() {
        systemUnderTests = ProductViewModel(product: Mocks.product, currencyName: Mocks.currencyName)
    }

    override func tearDown() {
        systemUnderTests = nil
    }

    func testCounter() {
        // When
        systemUnderTests.increaseCount()
        systemUnderTests.increaseCount()
        systemUnderTests.decreaseCount()
        systemUnderTests.increaseCount()
        
        // Then
        XCTAssert(systemUnderTests.count == 2)
        XCTAssert(systemUnderTests.totalPrice == Mocks.price * 2)
    }
    
    func testCounterWithMultipleDecreases() {
        // When
        systemUnderTests.increaseCount()
        systemUnderTests.decreaseCount()
        systemUnderTests.decreaseCount()
        systemUnderTests.decreaseCount()
        
        // Then
        XCTAssert(systemUnderTests.count == 0)
        XCTAssert(systemUnderTests.totalPrice == .zero)
    }
    
    func testCurrencyName() {
        // When
        systemUnderTests.currencyName = "PLN"
        
        //Then
        XCTAssert(systemUnderTests.currencyName == "PLN")
    }
    
    func testRecalculatedPrice() {
        // Given
        systemUnderTests.increaseCount()
        systemUnderTests.increaseCount()
        
        // When
        systemUnderTests.calculatedPrice = 50.0
        
        // Then
        XCTAssert(systemUnderTests.totalPrice == 100.0)
    }
    
    func testCountWhenPriceRecalculated() {
        // Given
        systemUnderTests.calculatedPrice = 30.0
        
        // When
        systemUnderTests.increaseCount()
        systemUnderTests.increaseCount()
        systemUnderTests.increaseCount()
    
        // Then
        XCTAssert(systemUnderTests.totalPrice == 90.0)
    }
    
    func testUnitPluralName() {
        // When
        systemUnderTests.increaseCount()
        systemUnderTests.increaseCount()
        
        // Then
        XCTAssert(systemUnderTests.unitPlural == Mocks.unit + "s")
    }
}
