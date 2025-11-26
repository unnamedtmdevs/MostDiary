//  HistoryViewModel.swift
//  TimeDiary


import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var entries: [TimeEntry] = []
    @Published var filteredEntries: [TimeEntry] = []
    @Published var selectedCategories: Set<UUID> = []
    @Published var searchText: String = ""
    @Published var selectedEntry: TimeEntry?
    @Published var selectedDate: Date?

    private let timeTrackingService = TimeTrackingService.shared
    private let categoryService = CategoryService.shared
    private let calendar = Calendar.current

    init() {
        loadEntries()
    }

    func loadEntries() {
        entries = timeTrackingService.getAllEntries()
        applyFilters()
    }

    func applyFilters() {
        var result = entries

        if !selectedCategories.isEmpty {
            result = result.filter { selectedCategories.contains($0.categoryId) }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.categoryName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedDate = selectedDate {
            result = result.filter { entry in
                calendar.isDate(entry.startTime, inSameDayAs: selectedDate)
            }
        }

        filteredEntries = result
    }

    func toggleCategoryFilter(_ categoryId: UUID) {
        if selectedCategories.contains(categoryId) {
            selectedCategories.remove(categoryId)
        } else {
            selectedCategories.insert(categoryId)
        }
        applyFilters()
    }

    func clearFilters() {
        selectedCategories.removeAll()
        searchText = ""
        applyFilters()
    }

    func deleteEntry(_ entry: TimeEntry) {
        timeTrackingService.deleteEntry(id: entry.id)
        loadEntries()
    }

    func updateEntry(_ entry: TimeEntry) {
        timeTrackingService.updateEntry(entry)
        loadEntries()
    }

    var groupedEntries: [(String, [TimeEntry])] {
        let calendar = Calendar.current
        var grouped: [String: [TimeEntry]] = [:]

        for entry in filteredEntries {
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

    var totalEntries: Int {
        entries.count
    }

    var totalTimeTracked: String {
        let total = entries.reduce(0) { $0 + $1.duration }
        let hours = Int(total) / 3600
        if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = (Int(total) % 3600) / 60
            return "\(minutes)m"
        }
    }

    var averageEntryDuration: String {
        guard !entries.isEmpty else { return "0m" }
        let average = entries.reduce(0) { $0 + $1.duration } / Double(entries.count)
        let hours = Int(average) / 3600
        let minutes = (Int(average) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    func getCategoryColor(for entry: TimeEntry) -> Color {
        if let category = categoryService.getCategory(byId: entry.categoryId) {
            return category.color
        }
        return AppColors.accent5
    }
}
