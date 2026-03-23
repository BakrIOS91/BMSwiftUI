//
//  OptionalExtensionsTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
@testable import BMSwiftUI

final class OptionalExtensionsTests: XCTestCase {
    
    func testIsNil() {
        let nilValue: String? = nil
        let nonNilValue: String? = "Hello"
        
        XCTAssertTrue(nilValue.isNil)
        XCTAssertFalse(nonNilValue.isNil)
    }
    
    func testIsEmptyOrNil() {
        let nilArray: [Int]? = nil
        let emptyArray: [Int]? = []
        let filledArray: [Int]? = [1, 2, 3]
        
        XCTAssertTrue(nilArray.isEmptyOrNil)
        XCTAssertTrue(emptyArray.isEmptyOrNil)
        XCTAssertFalse(filledArray.isEmptyOrNil)
    }
}
