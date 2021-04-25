//
//  Binding.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/7/21.
//

import Foundation
import SwiftUI

public extension Binding {
    
    func didSet(_ didSet: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                didSet(newValue)
            }
        )
    }
}
