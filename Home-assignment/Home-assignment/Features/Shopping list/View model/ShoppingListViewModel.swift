//
//  ShoppingListViewModel.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

struct ProductItem: Identifiable{
    let product: Product
    let currencyName: String
    
    var id: String { product.id }
}

final class ShoppingListViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let jsonLoader: JSONLoading
    private let currencyExchange: CurrencyExchanging = CurrencyExchange.shared
    
    // MARK: - Properties
    
    private var initialProductList: [Product]
    
    @Published private(set) var dataSource: [ProductItem] = []
    @Published private(set) var totalAmount: Decimal = 0.0
    @Published private(set) var currencyName: String = Currency.default.name
    
    private var disposables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(jsonLoader: JSONLoading = JSONLoader()) {
        self.jsonLoader = jsonLoader
        self.initialProductList = jsonLoader.load("ProductData.json") ?? []
        setupBindings()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        currencyExchange.currentAvailableCurrency
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currency in
                guard let self = self else { return }
                self.dataSource = self.initialProductList
                    .map {
                        ProductItem(
                            product: Product(
                                product: $0,
                                newPrice: self.currencyExchange.exchange($0.priceUSD)
                            ),
                            currencyName: currency.name
                        )
                    }
            })
            .store(in: &disposables)
    }
}
