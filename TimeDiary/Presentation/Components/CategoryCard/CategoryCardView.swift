//  CategoryCardView.swift
//  TimeDiary


import SwiftUI

struct CategoryCardView: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            action()
        }) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: category.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(category.color)

                Text(category.name)
                    .font(AppTypography.caption(size: 13))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(AppColors.backgroundCard)
            .cornerRadius(AppTheme.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(isSelected ? category.color : AppColors.borderPrimary, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryDetailCardView: View {
    let category: Category
    let totalTime: String
    let entryCount: Int

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: category.iconName)
                .font(.system(size: 28))
                .foregroundColor(category.color)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.3),
                            category.color.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(entryCount) entries")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text(totalTime)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundCard,
                    AppColors.backgroundCard.opacity(0.6)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [category.color.opacity(0.4), AppColors.borderPrimary.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
