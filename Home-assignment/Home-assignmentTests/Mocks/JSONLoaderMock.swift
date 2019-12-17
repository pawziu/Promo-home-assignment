//
//  JSONLoaderMock.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
@testable import Home_assignment

final class JSONLoaderMock: JSONLoading {
    func load<T>(_ filename: String) -> T? where T : Decodable {
        return Mocks.products as? T
    }
}
