//
//  BindingOptionalTextFields.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/25/21.
//

import Foundation
import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
