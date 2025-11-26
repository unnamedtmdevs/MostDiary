//  Typography.swift
//  TimeDiary


import SwiftUI

enum AppTypography {
    static func display(size: CGFloat = 36) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func title(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func headline(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func body(size: CGFloat = 18) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func timer(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }

    static func caption(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }
}
