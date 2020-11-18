import SwiftUI
import iColor
import iGraphics

extension Color{
    
    init(_ hex: String, opacity: Int = 100) {
        self.init(hex, opacity: Double(opacity / 100))!
    }
    
    static let accent = Color("accent")
    static let background = Color("bg")
    static let darkShadow = Color("darkShadow")
    static let lightShadow = Color("lightShadow")
    static let darkerAccent = Color("darkerAccent")
    static let text = Color("text")
}

