import XCTest
import Combine
@testable import BMSwiftUI

final class StorageTests: XCTestCase {
    
    // MARK: - Mocks
    
    final class MockSecureSettings {
        @Secure("testSecureKey")
        var secretValue: String = "DefaultSecret"
    }
    
    final class CustomPreferences: PreferencesStore {
        static let shared = CustomPreferences()
        let preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
        
        @UserDefault("customKey")
        var customValue: String = "Initial"
    }
    
    class MockViewCustom {
        @Preference(\CustomPreferences.customValue, store: CustomPreferences.shared)
        var value
    }
    
    final class ObsPreferences: PreferencesStore {
        static let shared = ObsPreferences()
        let preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
        
        @UserDefault("obsKey")
        var obsValue: Int = 0
    }
    
    class MockViewObs {
        @Preference(\ObsPreferences.obsValue, store: ObsPreferences.shared)
        var value
    }

    @Preferences
    final class MacroSettings {
         @UserDefault("macroKey")
         var macroValue: String = "MacroDefault"
    }
    
    class MockViewMacro {
        @Preference(\MacroSettings.macroValue, store: MacroSettings.shared)
        var value
    }
    
    // MARK: - Setup
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        // Clean up keychain for test keys
        cleanupKeychain(forKey: "testSecureKey")
        // Clean up UserDefaults for test keys
        UserDefaults.standard.removeObject(forKey: "customKey")
        UserDefaults.standard.removeObject(forKey: "obsKey")
        UserDefaults.standard.removeObject(forKey: "macroKey")
    }
    
    private func cleanupKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Tests
    
    func testSecureStorage() {
        let settings = MockSecureSettings()
        XCTAssertEqual(settings.secretValue, "DefaultSecret")
        
        settings.secretValue = "NewSecret"
        XCTAssertEqual(settings.secretValue, "NewSecret")
        
        // Create new instance to check persistence in keychain
        let newSettings = MockSecureSettings()
        XCTAssertEqual(newSettings.secretValue, "NewSecret")
    }
    
    func testCustomPreferences() {
        let view = MockViewCustom()
        XCTAssertEqual(view.value, "Initial")
        
        view.value = "Updated"
        XCTAssertEqual(CustomPreferences.shared.customValue, "Updated")
        XCTAssertEqual(view.value, "Updated")
    }
    
    func testPreferenceObservation() {
        let view = MockViewObs()
        let expectation = XCTestExpectation(description: "Preference changed")
        
        var receivedKeyPath: AnyKeyPath?
        ObsPreferences.shared.preferencesChangedSubject
            .sink { kp in
                receivedKeyPath = kp
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        view.value = 42
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedKeyPath, \ObsPreferences.obsValue)
        XCTAssertEqual(ObsPreferences.shared.obsValue, 42)
    }

    func testMacroPreferences() {
        let view = MockViewMacro()
        XCTAssertEqual(view.value, "MacroDefault")
        
        view.value = "UpdatedMacro"
        XCTAssertEqual(MacroSettings.shared.macroValue, "UpdatedMacro")
        XCTAssertEqual(view.value, "UpdatedMacro")
    }
}

