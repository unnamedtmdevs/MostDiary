//  AnalyticsView.swift
//  TimeDiary


import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    AppColors.backgroundPrimary,
                    AppColors.backgroundSecondary,
                    AppColors.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .id("header_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)

                    periodSelector
                        .id("period_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    if viewModel.hasData {
                        overviewSection
                            .id("overview_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.lg)

                        categoryBreakdownSection
                            .id("breakdown_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.lg)

                        balanceSection
                            .id("balance_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.xl)
                    } else {
                        emptyState
                            .id("empty_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.xl)
                    }
                    
                    // Extra padding for deeper scroll
                    Spacer()
                        .frame(height: 120)
                }
            }
            .padding(.bottom, 70)
            .background(
                GeometryReader { _ in
                    Color.clear
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
        }
        .onAppear {
            viewModel.loadAnalytics()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Analytics")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)

                    Text("Understand your time usage patterns")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Decorative element
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.accent1.opacity(0.3), AppColors.accent6.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)

                    Circle()
                        .fill(AppColors.accent1.opacity(0.2))
                        .frame(width: 60, height: 60)
                }
            }
        }
    }

    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                PeriodButton(title: "Today", isSelected: viewModel.selectedPeriod.displayName == "Today") {
                    viewModel.selectPeriod(.today)
                }

                PeriodButton(title: "This Week", isSelected: viewModel.selectedPeriod.displayName == "This Week") {
                    viewModel.selectPeriod(.thisWeek)
                }

                PeriodButton(title: "This Month", isSelected: viewModel.selectedPeriod.displayName == "This Month") {
                    viewModel.selectPeriod(.thisMonth)
                }
            }
        }
    }

    private var overviewSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Overview")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                StatCard(
                    title: "Total Time",
                    value: viewModel.totalTime,
                    icon: "clock.fill",
                    color: AppColors.accent1
                )

                StatCard(
                    title: "Entries",
                    value: "\(viewModel.numberOfEntries)",
                    icon: "list.bullet",
                    color: AppColors.accent2
                )

                StatCard(
                    title: "Avg/Day",
                    value: viewModel.averageTimePerDay,
                    icon: "chart.line.uptrend.xyaxis",
                    color: AppColors.accent3
                )

                StatCard(
                    title: "Top Category",
                    value: viewModel.mostActiveCategory,
                    icon: "star.fill",
                    color: AppColors.accent6
                )
            }
        }
    }

    private var categoryBreakdownSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Category Breakdown")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.topCategories.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textTertiary.opacity(0.5))
                    Text("No data available")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.topCategories) { stat in
                        CategoryStatRow(
                            name: stat.categoryName,
                            time: stat.formattedTotalTime,
                            percentage: stat.formattedPercentage,
                            color: viewModel.getCategoryColor(stat.categoryColorHex)
                        )
                    }
                }
            }
        }
    }

    private var balanceSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Balance Analysis")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppSpacing.lg) {
                // Main ratio display
                HStack(spacing: AppSpacing.lg) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        viewModel.balanceIndicator.color.opacity(0.3),
                                        viewModel.balanceIndicator.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        viewModel.balanceIndicator.color,
                                        viewModel.balanceIndicator.color.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Work/Rest Ratio")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(viewModel.workRestRatio)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        AppColors.accent1,
                                        AppColors.accent6,
                                        AppColors.accent2
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(viewModel.balanceIndicator.color)
                                .frame(width: 10, height: 10)
                                .shadow(color: viewModel.balanceIndicator.color.opacity(0.5), radius: 4, x: 0, y: 0)
                            
                            Text(viewModel.balanceIndicator.text)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.balanceIndicator.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [
                                    viewModel.balanceIndicator.color.opacity(0.2),
                                    viewModel.balanceIndicator.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.balanceIndicator.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(AppSpacing.lg)
                
                // Visual progress bar
                if let ratio = viewModel.analyticsData?.workRestRatio, ratio > 0 {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Work")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Text("Rest")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppColors.backgroundCard.opacity(0.3),
                                                AppColors.backgroundCard.opacity(0.2)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 12)
                                
                                // Work portion
                                let workPercentage = min(ratio / (ratio + 1), 1.0)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppColors.accent1,
                                                AppColors.accent6
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * workPercentage, height: 12)
                                    .shadow(color: AppColors.accent1.opacity(0.4), radius: 4, x: 0, y: 2)
                                
                                // Rest portion
                                let restPercentage = 1.0 / (ratio + 1)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppColors.accent2,
                                                AppColors.accent3
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * restPercentage, height: 12)
                                    .offset(x: geometry.size.width * workPercentage)
                                    .shadow(color: AppColors.accent2.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.md)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        AppColors.backgroundCard,
                        AppColors.backgroundCard.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                viewModel.balanceIndicator.color.opacity(0.4),
                                AppColors.borderPrimary.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: viewModel.balanceIndicator.color.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary.opacity(0.5))

            Text("Not enough data")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("Track more time to see analytics")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }
}

struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            action()
        }) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [AppColors.accent1, AppColors.accent6],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [AppColors.backgroundCard, AppColors.backgroundCard.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    Group {
                        if !isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColors.borderPrimary.opacity(0.5), AppColors.borderPrimary.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    }
                )
                .shadow(color: isSelected ? AppColors.accent1.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
    }
}

struct CategoryStatRow: View {
    let name: String
    let time: String
    let percentage: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 14, height: 14)
                .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)

            Text(name)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(time)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text(percentage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
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
                        colors: [color.opacity(0.4), AppColors.borderPrimary.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
