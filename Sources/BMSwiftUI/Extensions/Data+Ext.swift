//
//  Data+Ext.swift
//  DynamicForm
//
//  Created by Bakr mohamed on 29/05/2024.
//

import Foundation
public extension Data {
    func getSizeInMB() -> Double {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        
        // Get the formatted string from ByteCountFormatter
        let formattedString = bcf.string(fromByteCount: Int64(self.count))
        
        // Replace Arabic decimal separator and remove "MB"
        let cleanedString = formattedString
            .replacingOccurrences(of: "٫", with: ".") // Replace Arabic decimal separator
            .replacingOccurrences(of: " م.ب.", with: "") // Remove "MB" in Arabic
            .arabicToEnglishDigits
        
        // Attempt to parse the cleaned string as a Double
        if let double = Double(cleanedString) {
            return double
        }
        
        return 0.0
    }
    
    func getMBSize() -> Double {
        return Double((Double(self.count) / 1000) / 1000).roundToDecimal(2)
    }
}
