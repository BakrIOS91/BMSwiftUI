//
//  UserDefaultsTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
import Combine
@testable import BMSwiftUI

final class UserDefaultsTests: XCTestCase {
    
    var container: UserDefaults!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        container = UserDefaults(suiteName: "BMSwiftUITests")
        container.removePersistentDomain(forName: "BMSwiftUITests")
        cancellables = []
    }
    
    func testUserDefaultStorage() {
        class MockSettings {
            @UserDefault("testKey", container: UserDefaults(suiteName: "BMSwiftUITests")!)
            var testValue: String = "Default"
        }
        
        let settings = MockSettings()
        XCTAssertEqual(settings.testValue, "Default")
        
        settings.testValue = "New Value"
        XCTAssertEqual(settings.testValue, "New Value")
        
        // Create new instance to check persistence in container
        let newSettings = MockSettings()
        XCTAssertEqual(newSettings.testValue, "New Value")
    }
    
    func testUserDefaultOptional() {
        class MockSettings {
            @UserDefault("optKey", container: UserDefaults(suiteName: "BMSwiftUITests")!)
            var optValue: String?
        }
        
        let settings = MockSettings()
        XCTAssertNil(settings.optValue)
        
        settings.optValue = "Optional"
        XCTAssertEqual(settings.optValue, "Optional")
        
        settings.optValue = nil
        XCTAssertNil(settings.optValue)
    }
    
    func testUserDefaultPublisher() {
        class MockSettings {
            @UserDefault("pubKey", container: UserDefaults(suiteName: "BMSwiftUITests")!)
            var pubValue: Int = 0
        }
        
        let settings = MockSettings()
        let expectation = XCTestExpectation(description: "Value published")
        var receivedValue: Int?
        
        settings.$pubValue.publisher
            .dropFirst() // Ignore initial value
            .sink { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        settings.pubValue = 42
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValue, 42)
    }
}
