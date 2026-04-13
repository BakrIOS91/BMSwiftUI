//
//  ViewModelTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
import Combine
@testable import BMSwiftUI

final class ViewModelTests: XCTestCase {
    
    // MARK: - Mock Types
    
    struct MockState: Equatable {
        var count: Int = 0
        var title: String = ""
    }
    
    enum MockAction {
        case increment
        case updateTitle(String)
    }
    
    // MARK: - ObservedBaseViewModel Tests (Pre-iOS 17)
    
    class TestObservedViewModel: ObservedBaseViewModel<MockState, MockAction> {
        @discardableResult
        override func onTrigger(_ action: MockAction) -> ViewModelEffect {
            switch action {
            case .increment:
                state.count += 1
            case .updateTitle(let title):
                state.title = title
            }
            return .none
        }
    }
    
    @MainActor
    func testObservedViewModelState() async {
        let vm = TestObservedViewModel(state: MockState())
        XCTAssertEqual(vm.state.count, 0)
        
        vm.trigger(.increment)
        XCTAssertEqual(vm.state.count, 1)
        
        vm.trigger(.updateTitle("New Title"))
        XCTAssertEqual(vm.state.title, "New Title")
    }
    
    @MainActor
    func testObservedViewModelChangeNotification() async {
        let vm = TestObservedViewModel(state: MockState())
        let expectation = XCTestExpectation(description: "Object will change")
        
        let cancellable = vm.objectWillChange.sink { _ in
            expectation.fulfill()
        }
        
        vm.trigger(.increment)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
    
    // MARK: - BaseViewModel Tests (iOS 17+)
    
    #if canImport(Observation)
    @available(iOS 17.0, macOS 14.0, *)
    class TestModernViewModel: BaseViewModel<MockState, MockAction> {
        @discardableResult
        override func onTrigger(_ action: MockAction) -> ViewModelEffect {
            switch action {
            case .increment:
                state.count += 1
            case .updateTitle(let title):
                state.title = title
            }
            return .none
        }
    }
    
    @MainActor
    func testModernViewModelState() async {
        guard #available(iOS 17.0, macOS 14.0, *) else { return }
        
        let vm = TestModernViewModel(state: MockState())
        XCTAssertEqual(vm.state.count, 0)
        
        vm.trigger(.increment)
        XCTAssertEqual(vm.state.count, 1)
    }
    #endif
}
