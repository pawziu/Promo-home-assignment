//
//  API.swift
//  Home-assignment
//
//  Created by Paweł Wiśniewski on 14/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import Foundation
import Combine

class API {
    
    // MARK: - Instance
    
    static let shared = API()
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
      self.session = session
    }
    
    // MARK: - Networking
    
    func call<T: Decodable>(with request: Request) -> AnyPublisher<T, APIError> {
        let urlComponents = request.urlComponents
        guard let url = urlComponents.url else {
            let error = APIError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
              APIError.network(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { output -> AnyPublisher<T, APIError> in
                let decoder = JSONDecoder()
                return Just(output.data)
                  .decode(type: T.self, decoder: decoder)
                  .mapError { error in
                    .parsing(description: error.localizedDescription)
                  }
                  .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
