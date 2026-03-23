//
//  DataExtensionsTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
@testable import BMSwiftUI

final class DataExtensionsTests: XCTestCase {
    func testExample() {
        // Add specific data tests if Data+Ext.swift has custom logic
        let data = Data([0x00, 0x01])
        XCTAssertEqual(data.count, 2)
    }
}
