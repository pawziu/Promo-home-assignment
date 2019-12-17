//
//  CombineTestUtilities.swift
//  Home-assignmentTests
//
//  Created by Paweł Wiśniewski on 16/12/2019.
//  Copyright © 2019 promo. All rights reserved.
//

import XCTest
import Foundation
import Combine

extension XCTestCase {
    
    private var testTimeout: TimeInterval { 1.0 }
    
    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: testTimeout)
    }
    
    func expectedResult<T: Publisher>(publisher: T?, expectedResponse: T.Output) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) where T.Output: Equatable {
        let expectationReceive = expectation(description: "receiveValue")
        
        let cancellable = publisher?
            .sink (receiveCompletion: { (completion) in
            
            }, receiveValue: { response in
                guard response == expectedResponse else { return }
                expectationReceive.fulfill()
            })
        return (expectations: [expectationReceive],
                cancellable: cancellable)
    }
}
