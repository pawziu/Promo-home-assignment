//
//  ExchangeRatesRequest.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

class ExchangeRatesListRequest: Request {
    override var host: String { "www.freeforexapi.com" }
    override var path: String { "/api/live" }
}
