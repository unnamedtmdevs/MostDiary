//  View+Extensions.swift
//  TimeDiary


import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    func cardStyle() -> some View {
        self
            .background(AppColors.backgroundCard)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppColors.borderPrimary, lineWidth: 1)
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(AppColors.accent1)
            .foregroundColor(AppColors.textPrimary)
            .cornerRadius(AppTheme.cornerRadius)
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(AppColors.backgroundCard)
            .foregroundColor(AppColors.textPrimary)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppColors.borderPrimary, lineWidth: 1)
            )
    }
}
