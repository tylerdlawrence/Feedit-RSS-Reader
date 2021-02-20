//
//  Image.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/7/21.
//

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SwiftUI.Image {
    func styleFit() -> some View {
        return self
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
