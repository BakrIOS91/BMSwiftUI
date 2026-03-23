//
//  StringExtensionsTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
import SwiftUI
@testable import BMSwiftUI

final class StringExtensionsTests: XCTestCase {
    
    func testLocalizedStringKey() {
        let text = "Hello"
        let key = text.localizedStringKey
        XCTAssertNotNil(key)
    }
    
    func testFormatDate() {
        let dateString = "2024-03-23"
        let formatted = dateString.formatDate(formateFrom: .yyyyMMdd, formateTo: .ddMMyyyy)
        XCTAssertEqual(formatted, "23-03-2024")
    }
    
    func testFormatDateInvalid() {
        let dateString = "invalid-date"
        let formatted = dateString.formatDate(formateFrom: .yyyyMMdd, formateTo: .ddMMyyyy)
        XCTAssertEqual(formatted, "invalid-date")
    }
    
    func testCapitalizingFirstLetter() {
        XCTAssertEqual("hello".capitalizingFirstLetter(), "Hello")
        XCTAssertEqual("Hello".capitalizingFirstLetter(), "Hello")
        XCTAssertEqual("".capitalizingFirstLetter(), "")
    }
    
    func testCapitalizeFirstLetterMutating() {
        var text = "world"
        text.capitalizeFirstLetter()
        XCTAssertEqual(text, "World")
    }
    
    func testToURL() {
        XCTAssertNotNil("https://www.google.com".toURL)
        // URL(string:) behavior varies by platform/version regarding spaces.
        // We'll test with a string that is universally likely to be nil or just skip the nil check if it's inconsistent.
        XCTAssertNil("".toURL)
    }
    
    func testReplaceEmpty() {
        XCTAssertEqual("".replaceEmpty(), "N/A")
        XCTAssertEqual("Value".replaceEmpty(), "Value")
    }
    
    func testToDouble() {
        XCTAssertEqual("123.45".toDouble(), 123.45)
        XCTAssertNil("abc".toDouble())
    }
    
    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed(), "hello")
        XCTAssertEqual("\nhello\n".trimmed(), "hello")
    }
    
    func testConvertedDigits() {
        let english = "123.45"
        let arabic = "١٢٣٫٤٥"
        
        XCTAssertEqual(english.convertedDigits(.arabic), arabic)
        XCTAssertEqual(arabic.convertedDigits(.english), english)
    }
    
    func testPermitOnlyEnglishCharacters() {
        let input = "Hello 123! @أهلا"
        let expected = "Hello123!@.-_" // Based on allowedCharacters: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@.-_"
        // Wait, "!" is not in the allowed set I saw in the file.
        // let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@.-_")
        XCTAssertEqual("Hello 123! @".permitOnlyEnglishCharacters, "Hello123@")
    }
}
