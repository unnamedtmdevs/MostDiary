//  HomeView.swift
//  TimeDiary


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @Binding var selectedTab: TabItem
    @State private var pulseScale: CGFloat = 1.0
    @State private var showingSettings = false
    @State private var editingEntry: TimeEntry?

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
                    // Header with gradient and effect
                    headerSection
                        .id(themeManager.currentTheme)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)

                    // Active timer with unique design
                    if viewModel.hasActiveTimer {
                        activeTimerSection
                            .id("timer_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.lg)
                    }

                    // Stats in unusual format
                    quickStatsSection
                        .id("stats_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    // Recent activities with custom design
                    recentActivitiesSection
                        .id("recent_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    // Quick actions
                    quickActionsSection
                        .id("actions_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                    
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
            viewModel.loadData()
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(item: $editingEntry) { entry in
            EntryNoteEditView(entry: entry) { notes in
                var updatedEntry = entry
                updatedEntry.notes = notes
                viewModel.updateEntry(updatedEntry)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Gradient header
                    Text("Time")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)

                    Text("Today")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Settings button
                Button(action: {
                    HapticsService.shared.impact(.light)
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 50, height: 50)
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
            }

            Text(Date().formatted(as: "EEEE, d MMMM"))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textTertiary)
                .padding(.top, 4)
        }
    }

    private var activeTimerSection: some View {
        ZStack {
            // Background with glow effect
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.accent1.opacity(0.2),
                            AppColors.accent6.opacity(0.15),
                            AppColors.accent1.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.accent1.opacity(0.6), AppColors.accent6.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: AppColors.accent1.opacity(0.3), radius: 20, x: 0, y: 10)

            VStack(spacing: AppSpacing.lg) {
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppColors.accent1)
                            .frame(width: 10, height: 10)
                            .scaleEffect(pulseScale)

                        Text("Active Timer")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()
                }

                TimerDisplayView(
                    elapsedTime: viewModel.elapsedTime,
                    status: viewModel.timerState.status
                )

                if let categoryName = viewModel.timerState.categoryName {
                    HStack {
                        Text(categoryName)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                }

                Button(action: {
                    HapticsService.shared.impact(.light)
                    selectedTab = .tracking
                }) {
                    HStack {
                        Text("Go to Tracking")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.accent1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.accent1.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            .padding(AppSpacing.lg)
        }
    }

    private var quickStatsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Section header
            HStack {
                Text("Stats")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            // Stats layout with equal sizes
            HStack(spacing: AppSpacing.md) {
                // Today card
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.accent1)
                        Spacer()
                    }

                    Text(viewModel.formattedTodayTime)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 4)

                    Text("Today")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
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

                // Week card
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.accent2)
                        Spacer()
                    }

                    Text(viewModel.formattedWeekTime)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 4)

                    Text("Week")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
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

    private var recentActivitiesSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Recent Activities")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: {
                    HapticsService.shared.impact(.light)
                    selectedTab = .history
                }) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.accent1)
                }
            }

            if viewModel.recentEntries.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textTertiary.opacity(0.5))
                    Text("No entries yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(Array(viewModel.recentEntries.enumerated()), id: \.element.id) { index, entry in
                        Button(action: {
                            HapticsService.shared.impact(.light)
                            editingEntry = entry
                        }) {
                            RecentEntryRow(entry: entry, index: index)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Start tracking button with gradient
            Button(action: {
                HapticsService.shared.impact(.medium)
                selectedTab = .tracking
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                    Text("Start Tracking")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        colors: [AppColors.accent1, AppColors.accent6],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(18)
                .shadow(color: AppColors.accent1.opacity(0.4), radius: 15, x: 0, y: 8)
            }

            // Analytics button with border
            Button(action: {
                HapticsService.shared.impact(.light)
                selectedTab = .analytics
            }) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                    Text("Analytics")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
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
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.accent2.opacity(0.5), AppColors.accent3.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                )
            }
        }
    }
}

struct RecentEntryRow: View {
    let entry: TimeEntry
    let index: Int

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Entry number with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.accent1.opacity(0.3),
                                AppColors.accent6.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Text("\(index + 1)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.accent1)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.categoryName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text(entry.formattedTimeRange)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                if let notes = entry.notes, !notes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.system(size: 11))
                        Text(notes)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .lineLimit(1)
                    }
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    .padding(.top, 2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.formattedDuration)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(AppSpacing.md)
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
                .stroke(AppColors.borderPrimary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
