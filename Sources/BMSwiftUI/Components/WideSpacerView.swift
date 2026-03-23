//
//  WideSpacerView.swift
//
//
//  Created by Bakr mohamed on 09/06/2024.
//

import SwiftUI

public struct WideSpacerView: View {
    var axis: Axis.Set
    
   public init(_ axis: Axis.Set) {
        self.axis = axis
    }
    
    public var body: some View {
        switch axis {
            case .horizontal:
                HStack {
                    Spacer()
                }
            case .vertical:
                VStack {
                    Spacer()
                }
            default:
                EmptyView()
        }
        
    }
}
