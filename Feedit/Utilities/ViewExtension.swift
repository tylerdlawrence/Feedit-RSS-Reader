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

struct HiddenItem: View {
    @State private var hideRemove = false
    @State private var hideKeep = false
    
    var body: some View {
        VStack() {
            HStack {
                Text("Text that needs to be hidden")
                    .modifier(IsHidden(isHidden: hideRemove, remove: hideRemove))
            }
        }
    }
}

struct IsHidden: ViewModifier {
    private let isHidden: Bool
    private let remove: Bool
    
    init(isHidden: Bool, remove: Bool) {
        self.isHidden = isHidden
        self.remove = remove
    }
    
    func body(content: Content) -> some View {
        Group {
            if isHidden {
                if remove {
                    EmptyView()
                } else {
                    content.hidden()
                }
            } else {
                content
            }
        }
    }
}
