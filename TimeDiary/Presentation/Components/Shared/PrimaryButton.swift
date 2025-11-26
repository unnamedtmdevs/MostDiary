//  PrimaryButton.swift
//  TimeDiary


import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var color: Color = AppColors.accent1
    var isEnabled: Bool = true

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.medium)
            action()
        }) {
            Text(title)
                .font(AppTypography.headline(size: 18))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isEnabled ? color : color.opacity(0.5))
                .cornerRadius(AppTheme.cornerRadius)
        }
        .disabled(!isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            action()
        }) {
            Text(title)
                .font(AppTypography.headline(size: 18))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColors.backgroundCard)
                .cornerRadius(AppTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppColors.borderPrimary, lineWidth: 1)
                )
        }
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    var size: CGFloat = 60

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: size, height: size)
                .background(color)
                .cornerRadius(size / 2)
        }
    }
}
