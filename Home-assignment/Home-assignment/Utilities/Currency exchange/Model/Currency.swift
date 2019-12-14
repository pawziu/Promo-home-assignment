//
//  Currency.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

struct Currency: Equatable {
    let name: String
    
    static var `default`: Currency { Currency(name: "USD") }
}
