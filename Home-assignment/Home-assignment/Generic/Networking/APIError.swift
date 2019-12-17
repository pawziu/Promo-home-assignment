//
//  APIError.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

enum APIError: Error {
    case parsing(description: String),
    network(description: String),
    unknown
}
