//
//  CancelableStoreTests.swift
//  BMSwiftUITests
//
//  Created by Bakr mohamed on 23/03/2026.
//

import XCTest
import Combine
@testable import BMSwiftUI

final class CancelableStoreTests: XCTestCase {
    
    class MockStore: CancelableStore {
        // CancelableStore implementation is provided by extension
    }
    
    func testCancelableStorage() {
        let store = MockStore()
        let subject = PassthroughSubject<Void, Never>()
        var fired = false
        
        subject.sink { _ in
            fired = true
        }
        .store(in: &store.cancelables)
        
        XCTAssertEqual(store.cancelables.count, 1)
        
        subject.send()
        XCTAssertTrue(fired)
    }
    
    func testMultipleStoresHaveDifferentBags() {
        let store1 = MockStore()
        let store2 = MockStore()
        
        AnyCancellable({}).store(in: &store1.cancelables)
        
        XCTAssertEqual(store1.cancelables.count, 1)
        XCTAssertEqual(store2.cancelables.count, 0)
    }
}
