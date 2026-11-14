//
//  Theme.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import SwiftUI
import UIKit

enum Theme {
    static let background = Color(light: 0xFBF6EE, dark: 0x1A1512)
    static let surface    = Color(light: 0xFFFFFF, dark: 0x262019)
    static let ink        = Color(light: 0x2A211B, dark: 0xF5EDE4)
    static let muted      = Color(light: 0x6B5E55, dark: 0xB8A99C)
    static let pill       = Color(light: 0xF3E6D8, dark: 0x3A2F27)
    static let field      = Color(light: 0xF3E9DE, dark: 0x2E2620)
    static let line       = Color(light: 0xEADFD2, dark: 0x3A3029)
    static let accent     = Color(light: 0xB4532A, dark: 0xE07A4F)
    static let accentText = Color(light: 0x8F3F1E, dark: 0xF2A27E)
    static let future     = Color(light: 0x857568, dark: 0x8C7E72)
    static let shadow     = Color(red: 42 / 255, green: 33 / 255, blue: 27 / 255)
}

extension Font {
    /// Serif display type (New York) used for titles, like a printed journal.
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// Stable tinted colors per category so the same tag always looks the same.
enum CategoryPalette {
    private static let palette: [(bg: Color, fg: Color)] = [
        (Color(light: 0xE3ECF7, dark: 0x22324A), Color(light: 0x284A73, dark: 0xBFD3F0)),
        (Color(light: 0xE8E3F4, dark: 0x2E2840), Color(light: 0x463A73, dark: 0xD3CBF0)),
        (Color(light: 0xF8E1DC, dark: 0x47251F), Color(light: 0x7A2E22, dark: 0xF3C2B7)),
        (Color(light: 0xE1F0E6, dark: 0x1F3527), Color(light: 0x2D5A3D, dark: 0xBDE3C8)),
        (Color(light: 0xF7EBD3, dark: 0x3D3018), Color(light: 0x6B4A12, dark: 0xEDD3A0))
    ]

    static func colors(for category: String) -> (bg: Color, fg: Color) {
        let seed = category.lowercased().unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return palette[seed % palette.count]
    }
}
