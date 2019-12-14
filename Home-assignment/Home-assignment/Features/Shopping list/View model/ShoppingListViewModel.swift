//
//  ShoppingListViewModel.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

final class ShoppingListViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let jsonLoader: JSONLoading
    private let currencyExchange: CurrencyExchanging = CurrencyExchange.shared
    
    // MARK: - Properties
    
    @Published private(set) var dataSource: [Product] = []
    @Published private(set) var selectedCurrency: Currency = .default
    @Published private(set) var totalAmount: Decimal = 0.0
    
    // MARK: - Initialization
    
    init(jsonLoader: JSONLoading = JSONLoader()) {
        self.jsonLoader = jsonLoader
        loadProducts()
    }
    
    // MARK: - Data
    
    private func loadProducts() {
        dataSource = jsonLoader.load("ProductData.json") ?? []
    }
}
