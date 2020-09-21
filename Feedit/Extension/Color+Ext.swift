//
//  Color+Ext.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import Foundation
import SwiftUI

extension Color {
    init(_ rgb: UInt, _ alpha: CGFloat = 1.0) {
        self.init(RGBColorSpace.sRGB,
              red: Double((rgb & 0xFF0000) >> 16) / 255.0,
              green: Double((rgb & 0x00FF00) >> 8) / 255.0,
              blue: Double(rgb & 0x0000FF) / 255.0, opacity: Double(alpha))
    }
}
