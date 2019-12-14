//
//  Currency.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

enum Currency: String, CaseIterable {
    case EUR, GBP, AUD, NZD, USD, CAD, CHF, JPY

    static var `default`: Currency { .USD }

    var description: String {
        return rawValue
    }
    
    var symbol: String {
        switch self {
        case .EUR: return "€"
        case .GBP: return "￡"
        case .AUD: return "$"
        case .NZD: return "$"
        case .USD: return "$"
        case .CAD: return "$"
        case .CHF: return "CHF"
        case .JPY: return "¥"
        }
    }
}
