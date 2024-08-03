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
        let string = bcf.string(fromByteCount: Int64(self.count)).replacingOccurrences(of: ",", with: ".")
        if let double = Double(string.replacingOccurrences(of: " MB", with: "")) {
            return double
        }
        return 0.0
    }
}
