//  SettingsView.swift
//  TimeDiary


import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
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

                    preferencesSection
                        .id("preferences_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    statisticsSection
                        .id("statistics_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    dataManagementSection
                        .id("data_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    aboutSection
                        .id("about_\(themeManager.currentTheme)")
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
        .alert("Clear All Data", isPresented: $viewModel.showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.clearAllData()
            }
        } message: {
            Text("This will permanently delete all your time entries and settings. This action cannot be undone.")
        }
        .alert("Data Cleared", isPresented: $viewModel.showingClearDataSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All data has been successfully cleared.")
        }
        .sheet(isPresented: $viewModel.showingNotificationTimePicker) {
            notificationTimePickerSheet
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)

            Text("Manage app preferences and data")
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

    private var preferencesSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Preferences")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                SettingToggleRow(
                    title: "Haptics Feedback",
                    isOn: $viewModel.hapticsEnabled
                )
                .onChange(of: viewModel.hapticsEnabled) { _ in
                    viewModel.saveSettings()
                }

                Divider()
                    .background(AppColors.borderPrimary.opacity(0.3))
                    .padding(.leading, AppSpacing.md)
                
                // Theme Selection
                themeSelectionRow
                
                Divider()
                    .background(AppColors.borderPrimary.opacity(0.3))
                    .padding(.leading, AppSpacing.md)

                SettingToggleRow(
                    title: "Enable Notifications",
                    isOn: $viewModel.enableNotifications
                )
                .onChange(of: viewModel.enableNotifications) { newValue in
                    if newValue {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    } else {
                        viewModel.scheduleNotification()
                    }
                    viewModel.saveSettings()
                }
                
                if viewModel.enableNotifications && viewModel.notificationAuthorizationStatus == .authorized {
                    Divider()
                        .background(AppColors.borderPrimary.opacity(0.3))
                        .padding(.leading, AppSpacing.md)
                    
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        viewModel.showingNotificationTimePicker = true
                    }) {
                        HStack {
                            Text("Notification Time")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Text(viewModel.formattedNotificationTime)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.accent1)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
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
    
    private var themeSelectionRow: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("App Theme")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            
            // Theme preview cards
            HStack(spacing: AppSpacing.md) {
                ForEach(ColorTheme.allCases, id: \.self) { theme in
                    ThemePreviewCard(
                        theme: theme,
                        isSelected: viewModel.selectedTheme == theme
                    ) {
                        HapticsService.shared.impact(.light)
                        viewModel.selectedTheme = theme
                        viewModel.saveSettings()
                    }
                    .id("theme_\(theme)_\(themeManager.currentTheme)")
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
        }
        .id("themeSelection_\(themeManager.currentTheme)")
    }
    
    private var notificationTimePickerSheet: some View {
        NavigationView {
            ZStack {
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
                
                VStack(spacing: AppSpacing.xl) {
                    Text("Select Notification Time")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, AppSpacing.xl)
                    
                    DatePicker(
                        "Time",
                        selection: $viewModel.notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.backgroundCard,
                                AppColors.backgroundCard.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.borderPrimary.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, AppSpacing.md)
                    
                    Button(action: {
                        HapticsService.shared.impact(.medium)
                        viewModel.saveSettings()
                        viewModel.scheduleNotification()
                        viewModel.showingNotificationTimePicker = false
                    }) {
                        Text("Save")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
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
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        HapticsService.shared.impact(.light)
                        viewModel.showingNotificationTimePicker = false
                    }
                    .foregroundColor(AppColors.accent1)
                }
            }
        }
    }

    private var statisticsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Statistics")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppSpacing.sm) {
                StatisticRow(title: "Total Time Tracked", value: viewModel.totalTimeTracked)
                StatisticRow(title: "Total Entries", value: "\(viewModel.totalEntries)")
                StatisticRow(title: "First Entry", value: viewModel.firstEntryDate)
            }
        }
    }

    private var dataManagementSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Data Management")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppSpacing.md) {
                SecondaryButton(title: "Export Data as CSV") {
                    viewModel.exportData()
                }

                Button(action: {
                    HapticsService.shared.impact(.medium)
                    viewModel.showingClearDataAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 18))
                    Text("Clear All Data")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                        .foregroundColor(AppColors.error)
                        .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.error.opacity(0.2),
                                AppColors.error.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.error.opacity(0.5), lineWidth: 1.5)
                    )
                    .shadow(color: AppColors.error.opacity(0.2), radius: 10, x: 0, y: 5)
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("About")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                SettingRow(title: "App Version", value: viewModel.appVersion)

                Divider()
                    .background(AppColors.borderPrimary.opacity(0.3))
                    .padding(.leading, AppSpacing.md)

                SettingRow(title: "App Name", value: "TimeDiary")
            }
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
}

struct SettingRow: View {
    let title: String
    let value: String
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
    }
}

struct SettingToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.accent1)
        }
        .padding(AppSpacing.lg)
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.accent1)
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
                .stroke(AppColors.borderPrimary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
