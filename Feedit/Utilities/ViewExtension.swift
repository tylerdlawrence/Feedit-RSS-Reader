//
//  ViewExtension.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/7/21.
//

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    func erase() -> AnyView {
        return AnyView(self)
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: @autoclosure () -> Bool, apply: (Self) -> T) -> some View {
        if condition() {
            apply(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func hidden(_ hides: Bool) -> some View {
        switch hides {
        case true: self.hidden()
        case false: self
        }
    }
}
