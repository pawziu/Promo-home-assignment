//
//  ExchangeRateRequest.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

final class ExchangeRateRequest: ExchangeRatesListRequest {
    private let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
        super.init()
    }
    
    override var queryItems: [RequestParameter] {
        return [
            RequestParameter(
                name: "pairs", value: Currency.default.name + currency.name
            )
        ]
    }
}
