//  StatCard.swift
//  TimeDiary


import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(AppTypography.title(size: 28))
                .foregroundColor(AppColors.textPrimary)

            Text(title)
                .font(AppTypography.caption())
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
