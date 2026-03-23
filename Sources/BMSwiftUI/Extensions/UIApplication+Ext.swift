//
//  UIApplication+Ext.swift
//  DynamicForm
//
//  Created by Bakr mohamed on 26/05/2024.
//

#if os(iOS)
import UIKit

public extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
