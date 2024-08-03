//
//  Double+Ext.swift
//
//
//  Created by Bakr mohamed on 28/04/2024.
//

import Foundation

public extension Double {
    /// Rounds the double to decimal places value
    func toStringRounded(_ toPlaces: Int = 2) -> String {
        return String(format: "%.\(toPlaces)f", self)
    }
    
    
    func bytesToSizeString() -> String {
        // Define suffixes for different unit scales
        let suffixes = ["B", "kB", "MB", "GB", "TB", "PB"]
        
        // Handle zero bytes
        if self == 0 {
            return "0 B"
        }
        
        var convertedBytes = self
        var suffixIndex = 0
        
        // Loop through suffixes until bytes are below 1024
        while convertedBytes >= 1024 && suffixIndex < suffixes.count - 1 {
            convertedBytes /= 1024
            suffixIndex += 1
        }
        
        // Format the number with one decimal place
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        
        let formattedString = numberFormatter.string(for: convertedBytes) ?? ""
        
        // Combine formatted number and suffix
        return "\(formattedString) \(suffixes[suffixIndex])"
    }
    
    func toSizeDouble() -> Double? {
        let suffixes = ["B", "kB", "MB", "GB", "TB", "PB"]
        
        // Handle zero bytes
        if self == 0 {
            return 0
        }
        
        var convertedBytes = self
        var suffixIndex = 0
        
        // Loop through suffixes until bytes are below 1024
        while convertedBytes >= 1024 && suffixIndex < suffixes.count - 1 {
            convertedBytes /= 1024
            suffixIndex += 1
        }
        
        return convertedBytes.roundToDecimal(1)
    }
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    var toInt: Int {
        return Int(self)
    }
}
