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
    
    private var initialProductList: [ProductViewModel]
    
    @Published private(set) var dataSource: [ProductViewModel] = []
    @Published private(set) var checkoutItems: [ProductViewModel] = []
    @Published private(set) var totalAmount: Decimal = .zero
    @Published private(set) var currencyName: String = Currency.default.name
    
    private var disposables = Set<AnyCancellable>()
    private var dataSourceDisposables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(jsonLoader: JSONLoading = JSONLoader()) {
        self.jsonLoader = jsonLoader
        self.initialProductList = []
        setupBindings()
        self.initialProductList = loadData()
    }
    
    private func loadData() -> [ProductViewModel] {
        guard let data: [Product] = jsonLoader.load("ProductData.json") else { return [] }
        return data.map { ProductViewModel(product: $0, currencyName: Currency.default.name) }
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        currencyExchange.chosenCurrency
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currency in
                guard let self = self else { return }
                self.dataSource = self.initialProductList
                    .map {
                        $0.calculatedPrice = currency == .default ? $0.product.priceUSD : self.currencyExchange.exchange($0.product.priceUSD)
                        $0.currencyName = currency.name
                        self.currencyName = currency.name
                        return $0
                    }
                self.dataSourceDisposables = []
                self.dataSource.forEach {
                    $0.$totalPrice
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { [weak self] _ in
                        self?.recalculateTotalPrice()
                    })
                    .store(in: &self.dataSourceDisposables)
                }
            })
            .store(in: &disposables)
    }
    
    private func recalculateTotalPrice() {
        totalAmount = .zero
        dataSource.forEach { totalAmount += $0.totalPrice }
        checkoutItems = dataSource.filter { $0.count != 0 }
    }
}
