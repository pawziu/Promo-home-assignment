//
//  JSONLoader.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation

protocol JSONLoading {
    func load<T: Decodable>(_ filename: String) -> T?
}

final class JSONLoader: JSONLoading {
    func load<T: Decodable>(_ filename: String) -> T? {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else { return nil }
        guard let data = try? Data(contentsOf: file) else { return nil }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
