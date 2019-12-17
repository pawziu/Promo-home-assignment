//
//  SupportedExchangeRatesPairs.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

class SupportedExchangeRatesPairs: Decodable {
    // MARK: - Properties
    
    let supportedPairs: [String]
    
    var supportedCurrencies: [Currency] {
        return [.default] + supportedPairs
            .compactMap {
                let firstCurrency = Currency(name: String($0.prefix(3)))
                let secondCurrency = Currency(name: String($0.suffix(3)))
                guard firstCurrency == Currency.default else { return nil }
                return secondCurrency
            }
    }
    
    // MARK: - Initialization
    
    init(supportedPairs: [String]) {
        self.supportedPairs = supportedPairs
    }
}
