//
//  NumericExtensionsTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
@testable import BMSwiftUI

final class NumericExtensionsTests: XCTestCase {
    
    func testDoubleToStringRounded() {
        let value = 123.4567
        XCTAssertEqual(value.toStringRounded(2), "123.46")
        XCTAssertEqual(value.toStringRounded(0), "123")
    }
    
    func testDoubleBytesToSizeString() {
        XCTAssertEqual((512.0).bytesToSizeString(), "512.0 B")
        XCTAssertEqual((1024.0).bytesToSizeString(), "1.0 kB")
        XCTAssertEqual((1024.0 * 1024.0).bytesToSizeString(), "1.0 MB")
        XCTAssertEqual((0.0).bytesToSizeString(), "0 B")
    }
    
    func testDoubleRoundToDecimal() {
        XCTAssertEqual((1.2345).roundToDecimal(2), 1.23)
        XCTAssertEqual((1.2355).roundToDecimal(2), 1.24)
    }
    
    func testIntConversions() {
        let value = 10
        XCTAssertEqual(value.toDouble, 10.0)
        XCTAssertEqual(value.toString, "10")
    }
}
