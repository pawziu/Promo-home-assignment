//
//  ExchangeRatesPairs.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

final class ExchangeRatesPairs: Decodable {
    let rates: [String: ExchangeRate]
    
    init(rates: [String: ExchangeRate]) {
        self.rates = rates
    }
}
