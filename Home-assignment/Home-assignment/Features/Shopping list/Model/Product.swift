//
//  Product.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 13/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import SwiftUI

struct Product: Decodable, Identifiable {
    
    var id: String { name }
    
    let name: String
    let priceUSD: Decimal
    let unit: String
    let imageName: String
    
    init(name: String,
         priceUSD: Decimal,
         unit: String,
         imageName: String) {
        self.name = name
        self.priceUSD = priceUSD
        self.unit = unit
        self.imageName = imageName
    }
    
    init(product: Product, newPrice: Decimal) {
        self.name = product.name
        self.priceUSD = newPrice
        self.unit = product.unit
        self.imageName = product.imageName
    }

    enum Category: String, Codable {
        case name
        case priceUSD
        case unit
        case imageName
    }
}

extension Product: Hashable {
  static func == (lhs: Product, rhs: Product) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
