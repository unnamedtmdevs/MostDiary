//  AppTheme.swift
//  TimeDiary


import SwiftUI

@MainActor
struct AppTheme {
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 8
    static let minTouchTarget: CGFloat = 44

    static func cardShadow() -> some View {
        EmptyView()
            .shadow(color: AppColors.shadowPrimary, radius: AppTheme.shadowRadius, x: 0, y: 4)
    }
}
