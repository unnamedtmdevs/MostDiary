//  HistoryView.swift
//  TimeDiary


import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var searchText = ""
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
                    headerSection
                        .id("header_\(themeManager.currentTheme)")

                    // Calendar section
                    calendarSection
                        .id("calendar_\(themeManager.currentTheme)")
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)

                    if viewModel.filteredEntries.isEmpty {
                        emptyState
                            .id("empty_\(themeManager.currentTheme)")
                            .frame(minHeight: 300)
                    } else {
                        LazyVStack(spacing: AppSpacing.lg, pinnedViews: [.sectionHeaders]) {
                            ForEach(viewModel.groupedEntries, id: \.0) { section in
                                Section(header: sectionHeader(section.0)) {
                                    VStack(spacing: AppSpacing.sm) {
                                        ForEach(section.1) { entry in
                                            HistoryEntryRow(
                                                entry: entry,
                                                categoryColor: viewModel.getCategoryColor(for: entry),
                                                onDelete: {
                                                    viewModel.deleteEntry(entry)
                                                },
                                                onEdit: {
                                                    editingEntry = entry
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                    
                    // Statistics footer
                    statisticsFooter
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.lg)
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
            viewModel.loadEntries()
        }
        .onChange(of: searchText) { newValue in
            viewModel.searchText = newValue
            viewModel.applyFilters()
        }
        .onChange(of: viewModel.selectedDate) { _ in
            viewModel.applyFilters()
        }
        .sheet(item: $editingEntry) { entry in
            EntryNoteEditView(entry: entry) { notes in
                var updatedEntry = entry
                updatedEntry.notes = notes
                viewModel.updateEntry(updatedEntry)
            }
        }
    }
    
    private var calendarSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Calendar")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if viewModel.selectedDate != nil {
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        viewModel.selectedDate = nil
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Clear")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(AppColors.accent1)
                    }
                }
            }
            
            CalendarView(selectedDate: $viewModel.selectedDate, entries: viewModel.entries)
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("History")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)
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

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)

                TextField("Search entries...", text: $searchText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.backgroundInput,
                        AppColors.backgroundInput.opacity(0.8)
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
        }
        .padding(AppSpacing.md)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundPrimary,
                    AppColors.backgroundPrimary.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppSpacing.sm)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.backgroundPrimary,
                        AppColors.backgroundPrimary.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary.opacity(0.5))

            Text("No entries yet")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("Start tracking your time to see history")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var statisticsFooter: some View {
        HStack(spacing: AppSpacing.xl) {
            VStack(spacing: 4) {
                Text("\(viewModel.totalEntries)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Total Entries")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Divider()
                .background(AppColors.borderPrimary.opacity(0.3))
                .frame(height: 30)

            VStack(spacing: 4) {
                Text(viewModel.totalTimeTracked)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Total Time")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Divider()
                .background(AppColors.borderPrimary.opacity(0.3))
                .frame(height: 30)

            VStack(spacing: 4) {
                Text(viewModel.averageEntryDuration)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Avg Duration")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
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
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.borderPrimary.opacity(0.5), AppColors.borderPrimary.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct HistoryEntryRow: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let entry: TimeEntry
    let categoryColor: Color
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [categoryColor, categoryColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5)

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.categoryName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text(entry.formattedTimeRange)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let notes = entry.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary.opacity(0.8))
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(entry.formattedDuration)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        onEdit()
                    }) {
                        Image(systemName: entry.notes != nil && !entry.notes!.isEmpty ? "note.text" : "note.text.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.accent1)
                            .padding(8)
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
                            .cornerRadius(8)
                    }
                }
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
                .stroke(
                    LinearGradient(
                        colors: [categoryColor.opacity(0.3), AppColors.borderPrimary.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .id("row_\(entry.id)_\(themeManager.currentTheme)")
    }
}
