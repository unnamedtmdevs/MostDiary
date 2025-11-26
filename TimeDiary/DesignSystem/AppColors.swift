//  ColorScheme.swift
//  TimeDiary


import SwiftUI
import UIKit

@MainActor
enum AppColors {
    private static var isLightTheme: Bool {
        let theme = ThemeManager.shared.currentTheme
        if theme == .light {
            return true
        } else if theme == .dark {
            return false
        } else {
            // System theme - check current system color scheme
            return UITraitCollection.current.userInterfaceStyle == .light
        }
    }
    
    static var backgroundPrimary: Color {
        isLightTheme ? Color(hex: "F5F5F5") : Color(hex: "1a1a2e")
    }
    
    static var backgroundSecondary: Color {
        isLightTheme ? Color(hex: "E8E8E8") : Color(hex: "16213e")
    }
    
    static var backgroundCard: Color {
        isLightTheme ? Color.white.opacity(0.9) : Color.white.opacity(0.05)
    }
    
    static var backgroundInput: Color {
        isLightTheme ? Color.white.opacity(0.8) : Color.white.opacity(0.1)
    }

    static let primary = Color(hex: "D32F2F")
    static let secondary = Color(hex: "2196F3")

    static let accent1 = Color(hex: "6A1B9A")
    static let accent2 = Color(hex: "43A047")
    static let accent3 = Color(hex: "FF5722")
    static let accent4 = Color(hex: "6A1B9A")
    static let accent5 = Color(hex: "546E7A")
    static let accent6 = Color(hex: "E91E63")

    static let success = Color(hex: "4CAF50")
    static let error = Color(hex: "F44336")
    static let warning = Color(hex: "FF5722")

    static var textPrimary: Color {
        isLightTheme ? Color(hex: "1a1a2e") : Color.white
    }
    
    static var textSecondary: Color {
        isLightTheme ? Color(hex: "1a1a2e").opacity(0.7) : Color.white.opacity(0.8)
    }
    
    static var textTertiary: Color {
        isLightTheme ? Color(hex: "1a1a2e").opacity(0.6) : Color.white.opacity(0.7)
    }

    static var borderPrimary: Color {
        isLightTheme ? Color.black.opacity(0.1) : Color.white.opacity(0.2)
    }
    
    static var shadowPrimary: Color {
        isLightTheme ? Color.black.opacity(0.1) : Color.black.opacity(0.3)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
