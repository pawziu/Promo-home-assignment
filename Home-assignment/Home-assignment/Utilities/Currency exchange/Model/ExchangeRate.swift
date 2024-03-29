//
//  ExchangeRate.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

final class ExchangeRate: Decodable {
    let rate: Decimal
    
    init(rate: Decimal) {
        self.rate = rate
    }
}
