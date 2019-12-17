//
//  Request.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

class Request {
    var scheme: String { "https" }
    var host: String { .empty }
    var path: String { .empty }
    var queryItems: [RequestParameter] { [] }
    
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
            .map { URLQueryItem(name: $0.name, value: $0.value) }
        
        return components
    }
}

struct RequestParameter {
    let name: String
    let value: String
}
