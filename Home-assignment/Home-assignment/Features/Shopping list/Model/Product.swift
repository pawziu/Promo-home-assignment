//
//  Product.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 13/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import SwiftUI

struct Product: Decodable {
    
    let name: String
    let priceUSD: Decimal
    let unit: String
    private let imageName: String
    
//    var image: Image {
//        ImageStore.shared.image(name: imageName)
//    }

    enum Category: String, Codable {
        case name
        case priceUSD
        case unit
        case imageName
    }
}
