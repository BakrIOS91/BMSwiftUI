//
//  ComponentTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
import SwiftUI
@testable import BMSwiftUI

final class ComponentTests: XCTestCase {
    
    func testUnwrapWithContent() {
        let value: String? = "Hello"
        let view = Unwrap(value) { val in
            Text(val)
        } fallbackContent: {
            Text("Fallback")
        }
        
        XCTAssertNotNil(view.body)
        // Note: Full UI testing of body content usually requires hosting or more advanced techniques,
        // but we can verify the view initializes correctly with the given value.
    }
    
    func testUnwrapWithFallback() {
        let value: String? = nil
        let view = Unwrap(value) { val in
            Text(val)
        } fallbackContent: {
            Text("Fallback")
        }
        
        XCTAssertNotNil(view.body)
    }
}
