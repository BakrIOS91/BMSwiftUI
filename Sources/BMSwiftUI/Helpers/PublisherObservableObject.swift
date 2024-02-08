//
//  PublisherObservableObject.swift
//
//  Created by Bakr mohamed on 08/02/2024.
//

import Foundation
import Combine

/// A class for observing changes from a publisher and sending objectWillChange notifications.
@MainActor
public final class PublisherObservableObject: ObservableObject {
    
    /// The subscriber to the publisher.
    var subscriber: AnyCancellable?
    
    /// Initializes the observable object with a publisher.
    ///
    /// - Parameter publisher: The publisher to observe for changes.
    public init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher
            .sink(receiveValue: { _ in
                // Send the objectWillChange notification after the view update has happened.
                self.objectWillChange.send()
            })
    }
}
