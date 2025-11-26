//  CategoryDetailView.swift
//  TimeDiary


import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    let onCategoryUpdated: () -> Void
    let onCategoryDeleted: () -> Void
    @StateObject private var viewModel: CategoryDetailViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var editingCategory: Category?
    @State private var showingDeleteAlert = false
    @State private var currentCategory: Category
    @State private var editingEntry: TimeEntry?
    
    private let categoriesViewModel = CategoriesViewModel()
    
    init(category: Category, onCategoryUpdated: @escaping () -> Void, onCategoryDeleted: @escaping () -> Void) {
        self.category = category
        self.onCategoryUpdated = onCategoryUpdated
        self.onCategoryDeleted = onCategoryDeleted
        _currentCategory = State(initialValue: category)
        _viewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category))
    }
    
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
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.sm)
                    
                    // Header section
                    headerSection
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                    
                    // Statistics section
                    statisticsSection
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.lg)
                    
                    // Entries section
                    entriesSection
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                    
                    // Extra padding for deeper scroll
                    Spacer()
                        .frame(height: 120)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var backButton: some View {
        HStack {
            Button(action: {
                HapticsService.shared.impact(.light)
                dismiss()
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
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: currentCategory.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(currentCategory.color)
                            .frame(width: 60, height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        currentCategory.color.opacity(0.3),
                                        currentCategory.color.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentCategory.name)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Category Details")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: AppSpacing.sm) {
                    // Edit button
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        editingCategory = currentCategory
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.accent1)
                            .frame(width: 44, height: 44)
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
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.accent1.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Delete button
                    Button(action: {
                        HapticsService.shared.impact(.medium)
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.error)
                            .frame(width: 44, height: 44)
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
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.error.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .sheet(item: $editingCategory) { category in
            CategoryEditView(category: category) { updatedCategory in
                categoriesViewModel.updateCategory(updatedCategory)
                currentCategory = updatedCategory
                viewModel.loadData()
                onCategoryUpdated()
            }
        }
        .onChange(of: currentCategory) { _ in
            viewModel.loadData()
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = false
            }
            Button("Delete", role: .destructive) {
                HapticsService.shared.impact(.heavy)
                categoriesViewModel.deleteCategory(currentCategory)
                onCategoryDeleted()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(currentCategory.name)\"? All entries in this category will be removed. This action cannot be undone.")
        }
        .sheet(item: $editingEntry) { entry in
            EntryNoteEditView(entry: entry) { notes in
                var updatedEntry = entry
                updatedEntry.notes = notes
                viewModel.updateEntry(updatedEntry)
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Statistics")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: AppSpacing.md) {
                // Total time card
                VStack(spacing: AppSpacing.sm) {
                    Text(viewModel.totalTime)
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
                            currentCategory.color.opacity(0.2),
                            currentCategory.color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(currentCategory.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: currentCategory.color.opacity(0.2), radius: 15, x: 0, y: 8)
                
                // Entries count card
                VStack(spacing: AppSpacing.sm) {
                    Text("\(viewModel.entryCount)")
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
            
            // Average duration card
            if viewModel.entryCount > 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Average Duration")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(viewModel.averageDuration)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
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
    }
    
    private var entriesSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("All Entries")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.entries.isEmpty {
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
                    ForEach(viewModel.groupedEntries, id: \.0) { section in
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(section.0)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.top, AppSpacing.md)
                            
                            ForEach(section.1) { entry in
                                Button(action: {
                                    editingEntry = entry
                                }) {
                                    CategoryEntryRow(entry: entry, categoryColor: currentCategory.color)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CategoryEntryRow: View {
    let entry: TimeEntry
    let categoryColor: Color
    
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
                    Text(entry.formattedTimeRange)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(entry.formattedDate)
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
    }
}

@MainActor
final class CategoryDetailViewModel: ObservableObject {
    @Published var entries: [TimeEntry] = []
    @Published var statistics: CategoryStatistic?
    
    let category: Category
    private let timeTrackingService = TimeTrackingService.shared
    private let categoryService = CategoryService.shared
    
    init(category: Category) {
        self.category = category
    }
    
    func loadData() {
        entries = timeTrackingService.getEntries(for: category.id)
        entries.sort { $0.startTime > $1.startTime }
        
        let allEntries = timeTrackingService.getAllEntries()
        statistics = categoryService.getCategoryStatistics(categoryId: category.id, entries: allEntries)
    }
    
    func updateEntry(_ entry: TimeEntry) {
        timeTrackingService.updateEntry(entry)
        loadData()
    }
    
    var totalTime: String {
        statistics?.formattedTotalTime ?? "0m"
    }
    
    var entryCount: Int {
        statistics?.numberOfEntries ?? 0
    }
    
    var averageDuration: String {
        guard let stats = statistics, stats.numberOfEntries > 0 else {
            return "0m"
        }
        let hours = Int(stats.averageDuration) / 3600
        let minutes = (Int(stats.averageDuration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var groupedEntries: [(String, [TimeEntry])] {
        let calendar = Calendar.current
        var grouped: [String: [TimeEntry]] = [:]
        
        for entry in entries {
            let key: String
            if calendar.isDateInToday(entry.startTime) {
                key = "Today"
            } else if calendar.isDateInYesterday(entry.startTime) {
                key = "Yesterday"
            } else if calendar.isDate(entry.startTime, equalTo: Date(), toGranularity: .weekOfYear) {
                key = "This Week"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                key = formatter.string(from: entry.startTime)
            }
            
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(entry)
        }
        
        let sortOrder = ["Today", "Yesterday", "This Week"]
        return grouped.sorted { pair1, pair2 in
            if let index1 = sortOrder.firstIndex(of: pair1.key),
               let index2 = sortOrder.firstIndex(of: pair2.key) {
                return index1 < index2
            } else if sortOrder.contains(pair1.key) {
                return true
            } else if sortOrder.contains(pair2.key) {
                return false
            } else {
                return pair1.key > pair2.key
            }
        }
    }
}

