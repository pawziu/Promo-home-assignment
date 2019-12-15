//
//  CheckoutViewModel.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

final class CheckoutViewModel: ObservableObject {
    
    // MARK: - Output
    
    @Published private(set) var dataSource: [ProductViewModel]
    @Published private(set) var totalAmount: Decimal = .zero
    @Published private(set) var currencyName: String = Currency.default.name
    
    // MARK: - Dependencies
    
    private let currencyExchange: CurrencyExchanging
    
    // MARK: - Properties
    
    private var disposables = Set<AnyCancellable>()
    
    // MARK: - Initializaton

    init(products: [ProductViewModel],
         currencyExchange: CurrencyExchanging = CurrencyExchange.shared) {
        self.dataSource = products
        self.currencyExchange = currencyExchange
        
        setupBindings()
        recalculateTotalPrice()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
         currencyExchange.chosenCurrency
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currency in
                guard let self = self else { return }
                self.currencyName = currency.name
                self.recalculateTotalPrice()
            })
            .store(in: &disposables)
    }
    
    // MARK: - Data
    
    private func recalculateTotalPrice() {
        totalAmount = .zero
        dataSource.forEach { totalAmount += $0.totalPrice }
    }
}
