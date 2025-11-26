//  TimerDisplayView.swift
//  TimeDiary


import SwiftUI

struct TimerDisplayView: View {
    let elapsedTime: TimeInterval
    let status: TimerStatus

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text(formattedTime)
                .font(AppTypography.timer(size: 56))
                .foregroundColor(timerColor)
                .monospacedDigit()

            Text(statusText)
                .font(AppTypography.caption())
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(timerColor.opacity(0.3), lineWidth: 2)
        )
    }

    private var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var timerColor: Color {
        switch status {
        case .idle:
            return AppColors.textTertiary
        case .running:
            return AppColors.accent1
        case .paused:
            return AppColors.accent3
        }
    }

    private var statusText: String {
        switch status {
        case .idle:
            return "Not Started"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        }
    }
}
