//  TrackingView.swift
//  TimeDiary


import SwiftUI

struct TrackingView: View {
    @StateObject private var viewModel = TrackingViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @Binding var selectedTab: TabItem

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
                    // Back button
                    backButton
                        .id("back_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.sm)
                    
                    timerSection
                        .id("timer_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.sm)
                        .padding(.bottom, AppSpacing.lg)

                    if !viewModel.isTimerRunning {
                        categorySelectionSection
                            .id("categories_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.lg)
                    }

                    todaySummarySection
                        .id("summary_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                    
                    // Extra padding for deeper scroll
                    Spacer()
                        .frame(height: 120)
                }
            }
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
            viewModel.loadCategories()
            viewModel.loadTodayData()
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: {
                HapticsService.shared.impact(.light)
                selectedTab = .home
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
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
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.accent1.opacity(0.4), AppColors.accent6.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
        }
    }

    private var timerSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Gradient header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tracking")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)

                    Text("Time Tracker")
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

            TimerDisplayView(
                elapsedTime: viewModel.elapsedTime,
                status: viewModel.timerState.status
            )

            if let category = viewModel.selectedCategory {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: category.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(category.color)
                        .frame(width: 40, height: 40)
                        .background(category.color.opacity(0.2))
                        .cornerRadius(10)

                    Text(category.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [
                            category.color.opacity(0.15),
                            category.color.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(category.color.opacity(0.3), lineWidth: 1)
                )
            }

            timerControls
        }
    }

    private var timerControls: some View {
        HStack(spacing: AppSpacing.md) {
            if viewModel.timerState.status == .idle {
                Button(action: {
                    HapticsService.shared.impact(.medium)
                    viewModel.startTimer()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: viewModel.canStartTimer ? [AppColors.accent1, AppColors.accent6] : [AppColors.accent1.opacity(0.5), AppColors.accent6.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: AppColors.accent1.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .disabled(!viewModel.canStartTimer)
            } else if viewModel.isTimerRunning {
                IconButton(
                    icon: "pause.fill",
                    color: AppColors.accent3,
                    action: viewModel.pauseTimer
                )

                IconButton(
                    icon: "stop.fill",
                    color: AppColors.accent2,
                    action: {
                        viewModel.stopTimer()
                    }
                )
            } else if viewModel.isTimerPaused {
                IconButton(
                    icon: "play.fill",
                    color: AppColors.accent1,
                    action: viewModel.resumeTimer
                )

                IconButton(
                    icon: "stop.fill",
                    color: AppColors.accent2,
                    action: {
                        viewModel.stopTimer()
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var categorySelectionSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Select Category")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.mostUsedCategories.isEmpty {
                Text("Most Used")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, AppSpacing.sm)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                    ForEach(viewModel.mostUsedCategories) { category in
                        CategoryCardView(
                            category: category,
                            isSelected: viewModel.selectedCategory?.id == category.id
                        ) {
                            viewModel.selectCategory(category)
                        }
                    }
                }
            }

            Text("All Categories")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, AppSpacing.md)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                ForEach(viewModel.categories) { category in
                    CategoryCardView(
                        category: category,
                        isSelected: viewModel.selectedCategory?.id == category.id
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
        }
    }

    private var todaySummarySection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Today's Summary")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.xs) {
                    Text(viewModel.formattedTodayTime)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Total Time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.lg)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.accent1.opacity(0.2),
                            AppColors.accent1.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.accent1.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: AppColors.accent1.opacity(0.2), radius: 15, x: 0, y: 8)

                VStack(spacing: AppSpacing.xs) {
                    Text("\(viewModel.todayEntries.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Entries")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.lg)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.accent2.opacity(0.2),
                            AppColors.accent2.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.accent2.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: AppColors.accent2.opacity(0.2), radius: 15, x: 0, y: 8)
            }
        }
    }
}
