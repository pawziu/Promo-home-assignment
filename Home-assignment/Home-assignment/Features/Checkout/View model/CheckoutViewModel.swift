//
//  CheckoutViewModel.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

final class CheckoutViewModel: ObservableObject {
    
    // MARK: - Output
    
    @Published private(set) var dataSource: [ProductViewModel]
    @Published private(set) var totalAmount: Decimal
    @Published private(set) var currencyName: String
    
    // MARK: - Initializaton

    init(products: [ProductViewModel], totalAmount: Decimal, currencyName: String) {
        self.dataSource = products
        self.totalAmount = totalAmount
        self.currencyName = currencyName
    }
}
