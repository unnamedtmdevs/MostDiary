//  CategoriesViewModel.swift
//  TimeDiary


import SwiftUI

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var categoryStatistics: [UUID: CategoryStatistic] = [:]
    @Published var showingAddCategory = false
    @Published var editingCategory: Category?

    private let categoryService = CategoryService.shared
    private let timeTrackingService = TimeTrackingService.shared

    init() {
        loadData()
    }

    func loadData() {
        categories = categoryService.getAllCategories()
        loadStatistics()
    }

    private func loadStatistics() {
        let allEntries = timeTrackingService.getAllEntries()
        for category in categories {
            if let stats = categoryService.getCategoryStatistics(categoryId: category.id, entries: allEntries) {
                categoryStatistics[category.id] = stats
            }
        }
    }

    func addCategory(name: String, iconName: String, colorHex: String) {
        let newCategory = Category(
            name: name,
            iconName: iconName,
            colorHex: colorHex,
            isDefault: false
        )
        categoryService.createCategory(newCategory)
        loadData()
    }

    func updateCategory(_ category: Category) {
        categoryService.updateCategory(category)
        loadData()
    }

    func deleteCategory(_ category: Category) {
        // Check if category is used in active timer
        let timerService = TimerService.shared
        if let activeCategoryId = timerService.currentState.categoryId,
           activeCategoryId == category.id {
            // Stop the timer if it's using this category
            _ = timerService.stop()
        }
        
        categoryService.deleteCategory(id: category.id)
        loadData()
    }
    
    func canDeleteCategory(_ category: Category) -> Bool {
        return !category.isDefault
    }

    func getStatistics(for category: Category) -> CategoryStatistic? {
        categoryStatistics[category.id]
    }

    func getTotalTime(for category: Category) -> String {
        if let stats = categoryStatistics[category.id] {
            return stats.formattedTotalTime
        }
        return "0m"
    }

    func getEntryCount(for category: Category) -> Int {
        categoryStatistics[category.id]?.numberOfEntries ?? 0
    }

    var sortedCategories: [Category] {
        categories.sorted { cat1, cat2 in
            let time1 = categoryStatistics[cat1.id]?.totalTime ?? 0
            let time2 = categoryStatistics[cat2.id]?.totalTime ?? 0
            return time1 > time2
        }
    }
}
