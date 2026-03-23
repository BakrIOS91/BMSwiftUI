import XCTest
import Combine
@testable import BMSwiftUI

final class StorageTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        // Clean up keychain for test keys
        cleanupKeychain(forKey: "testSecureKey")
    }
    
    private func cleanupKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    func testSecureStorage() {
        class MockSecureSettings {
            @Secure("testSecureKey")
            var secretValue: String = "DefaultSecret"
        }
        
        let settings = MockSecureSettings()
        XCTAssertEqual(settings.secretValue, "DefaultSecret")
        
        settings.secretValue = "NewSecret"
        XCTAssertEqual(settings.secretValue, "NewSecret")
        
        // Create new instance to check persistence in keychain
        let newSettings = MockSecureSettings()
        XCTAssertEqual(newSettings.secretValue, "NewSecret")
    }
    
    func testCustomPreferences() {
        class CustomPreferences: Preferences {
            static let custom = CustomPreferences()
            
            @UserDefault("customKey")
            var customValue: String = "Initial"
        }
        
        class MockView {
            @Preference(\CustomPreferences.customValue, store: .custom)
            var value
        }
        
        let view = MockView()
        XCTAssertEqual(view.value, "Initial")
        
        view.value = "Updated"
        XCTAssertEqual(CustomPreferences.custom.customValue, "Updated")
        XCTAssertEqual(view.value, "Updated")
    }
    
    func testPreferenceObservation() {
        class ObsPreferences: Preferences {
            static let obs = ObsPreferences()
            @UserDefault("obsKey")
            var obsValue: Int = 0
        }
        
        class MockView {
            @Preference(\ObsPreferences.obsValue, store: .obs)
            var value
        }
        
        let view = MockView()
        let expectation = XCTestExpectation(description: "Preference changed")
        
        var receivedKeyPath: AnyKeyPath?
        ObsPreferences.obs.preferencesChangedSubject
            .sink { kp in
                receivedKeyPath = kp
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        view.value = 42
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedKeyPath, \ObsPreferences.obsValue)
        XCTAssertEqual(ObsPreferences.obs.obsValue, 42)
    }

    func testMacroPreferences() {
        // Defined at top level or class level usually, but let's see if it works here
        // If not, I'll move it outside
        @Preferences
        class MacroSettings {
             @UserDefault("macroKey")
             var macroValue: String = "MacroDefault"
        }
        
        class MockView {
            @Preference(\MacroSettings.macroValue) // Simplified invocation
            var value
        }
        
        let view = MockView()
        XCTAssertEqual(view.value, "MacroDefault")
        
        view.value = "UpdatedMacro"
        XCTAssertEqual(MacroSettings.shared.macroValue, "UpdatedMacro")
        XCTAssertEqual(view.value, "UpdatedMacro")
    }
}

