//
//  Mocks.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
@testable import Home_assignment

enum Mocks {
    static var price: Decimal { 20.0 }
    static var unit: String { "bag" }
    static var product: Product {
        Product(
            name: "Peas",
            priceUSD: price,
            unit: unit,
            imageName: .empty
        )
    }
    static var currencyName: String { "USD" }
    static var currencyPLN: Currency { Currency(name: "PLN") }
    static var currencyPLNRate: Decimal { 4.0 }
    static var products: [ProductViewModel] {
        [
            ProductViewModel(product: product, currencyName: currencyName, count: 1),
            ProductViewModel(product: product, currencyName: currencyName, count: 1),
            ProductViewModel(product: product, currencyName: currencyName, count: 1)
        ]
    }
    static var currencyExchangeMock: CurrencyExchangeMock { CurrencyExchangeMock() }
    static var availableCurrencies: [Currency] {
        [
            .default,
            Mocks.currencyPLN
        ]
    }
}
