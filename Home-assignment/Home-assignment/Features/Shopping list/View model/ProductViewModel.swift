//
//  ProductItem.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

final class ProductViewModel: ObservableObject {
    
    // MARK: - Input
    func increaseCount() {
        count += 1
    }
    
    func decreaseCount() {
        count -= 1
    }
    
    // MARK: - Output
    
    let product: Product
    
    @Published var calculatedPrice: Decimal {
        didSet {
            recalculateTotalPrice()
        }
    }
    @Published var currencyName: String
    @Published private(set) var count: Int {
        didSet {
            if count < 0 { count = 0 }
            recalculateTotalPrice()
        }
    }
    @Published private(set) var totalPrice: Decimal = 0.0
    
    var unitPlural: String {
        count == 1 ? product.unit : product.unit + "s"
    }
    
    // MARK: - Initialization
    
    init(product: Product, currencyName: String, count: Int = 0) {
        self.product = product
        self.currencyName = currencyName
        self.count = count
        self.calculatedPrice = product.priceUSD
        recalculateTotalPrice()
    }
    
    // MARK: - Data
    
    private func recalculateTotalPrice() {
        totalPrice = calculatedPrice * Decimal(count)
    }
}

extension ProductViewModel: Identifiable {
    var id: String { product.id }
}
