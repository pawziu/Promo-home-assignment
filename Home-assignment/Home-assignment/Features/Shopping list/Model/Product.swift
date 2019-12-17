//
//  Product.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 13/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

final class Product: Decodable {
    let name: String
    var priceUSD: Decimal
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
}

extension Product: Identifiable {
     var id: String { name }
}

extension Product: Hashable {
  static func == (lhs: Product, rhs: Product) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
