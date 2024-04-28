//
//  Double+Ext.swift
//
//
//  Created by Bakr mohamed on 28/04/2024.
//

import Foundation

public extension Double {
    /// Rounds the double to decimal places value
    func toStringRounded(toPlaces places: Int) -> String {
        return String(format: "%.\(places)f", self)
    }
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var toInt: Int {
        return Int(self)
    }
}
