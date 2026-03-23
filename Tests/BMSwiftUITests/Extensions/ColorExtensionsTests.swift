//
//  ColorExtensionsTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
import SwiftUI
@testable import BMSwiftUI

final class ColorExtensionsTests: XCTestCase {
    
    #if os(iOS)
    func testColorFromHex() {
        let whiteHex = "#FFFFFF"
        let color = Color(hex: whiteHex)
        XCTAssertNotNil(color)
        
        let invalidHex = "ZZZZZZ"
        let fallbackColor = Color(hex: invalidHex)
        XCTAssertEqual(fallbackColor, .clear)
    }
    
    func testAdaptiveColor() {
        let light = "#FFFFFF"
        let dark = "#000000"
        let color = Color(light: light, dark: dark)
        XCTAssertNotNil(color)
    }
    #endif
}
