//
//  CurrencyPickerViewModel.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

final class CurrencyPickerViewModel: ObservableObject {
    
    // MARK: - Output
    
    @Published var currencies: [Currency] = []
    @Published var selectedCurrency: Currency
    
    // MARK: - Dependencies
    
    private let currencyExchange: CurrencyExchanging
    
    // MARK: - Properties
    
    private var disposables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(currencyExchange: CurrencyExchanging = CurrencyExchange.shared) {
        self.currencyExchange = currencyExchange
        self.selectedCurrency = currencyExchange.currentCurrency
        setupBindings()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        currencyExchange.availableCurrencies
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currencies in
                self?.currencies = currencies
            })
            .store(in: &disposables)
        
        $selectedCurrency
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currency in
                self?.currencyExchange.setCurrency(currency)
            })
            .store(in: &disposables)
    }
}
