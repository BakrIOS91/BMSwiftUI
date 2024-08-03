//
//  URL+Ext.swift
//  ServeBig
//
//  Created by Bakr mohamed on 24/07/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//

import Foundation
public extension URL {
    static let documentsDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
}
