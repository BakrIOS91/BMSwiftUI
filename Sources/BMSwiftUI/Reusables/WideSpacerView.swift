//
//  WideSpacerView.swift
//
//
//  Created by Bakr mohamed on 09/06/2024.
//

import SwiftUI

struct WideSpacerView: View {
    var axis: Axis.Set
    
    init(_ axis: Axis.Set) {
        self.axis = axis
    }
    
    var body: some View {
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
