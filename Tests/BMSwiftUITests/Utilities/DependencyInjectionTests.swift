import XCTest
import BMSwiftUI

final class DependencyInjectionTests: XCTestCase {
    
    // MARK: - Mock Dependency
    
    struct TestClient {
        var value: String
    }
    
    struct TestKey: DependencyKey {
        static var liveValue = TestClient(value: "live")
        static var previewValue = TestClient(value: "preview")
        static var testValue = TestClient(value: "test")
    }
    
    // MARK: - Tests
    
    func testDefaultValueResovlesToTest() {
        let values = DependencyValues.shared
        XCTAssertEqual(values[TestKey.self].value, "test")
    }
    
    func testOverrideDependency() {
        var values = DependencyValues.shared
        values[TestKey.self] = TestClient(value: "overridden")
        XCTAssertEqual(values[TestKey.self].value, "overridden")
    }
    
    func testWithDependenciesScopedOverride() {
        DependencyValues.withDependencies {
            $0[TestKey.self] = TestClient(value: "scoped")
        } operation: {
            XCTAssertEqual(DependencyValues.shared[TestKey.self].value, "scoped")
        }
        
        // Should revert back to default after scope
        XCTAssertEqual(DependencyValues.shared[TestKey.self].value, "test")
    }
    
    func testWithDependenciesAsyncScopedOverride() async throws {
        await DependencyValues.withDependencies {
            $0[TestKey.self] = TestClient(value: "scoped-async")
        } operation: {
            XCTAssertEqual(DependencyValues.shared[TestKey.self].value, "scoped-async")
            try? await Task.sleep(nanoseconds: 100_000_000)
            XCTAssertEqual(DependencyValues.shared[TestKey.self].value, "scoped-async")
        }
        
        XCTAssertEqual(DependencyValues.shared[TestKey.self].value, "test")
    }
    
    func testInjectedPropertyWrapper() {
        class MockViewModel {
            @Injected(\.testClient) var client: TestClient
        }
        
        DependencyValues.withDependencies {
            $0.testClient = TestClient(value: "injected")
        } operation: {
            let vm = MockViewModel()
            XCTAssertEqual(vm.client.value, "injected")
        }
    }
}

// MARK: - Helper Extension for Tests

extension DependencyValues {
    var testClient: DependencyInjectionTests.TestClient {
        get { self[DependencyInjectionTests.TestKey.self] }
        set { self[DependencyInjectionTests.TestKey.self] = newValue }
    }
}
