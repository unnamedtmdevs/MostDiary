//  AnalyticsService.swift
//  TimeDiary


import Foundation

final class AnalyticsService {
    static let shared = AnalyticsService()
    private let timeTrackingService = TimeTrackingService.shared
    private let categoryService = CategoryService.shared

    private init() {}

    func getAnalytics(for period: TimePeriod) -> AnalyticsData {
        let dateRange = period.dateRange
        let entries = timeTrackingService.getEntries(from: dateRange.start, to: dateRange.end)

        guard !entries.isEmpty else {
            return AnalyticsData()
        }

        let totalTime = entries.reduce(0) { $0 + $1.duration }
        let numberOfDays = Calendar.current.dateComponents([.day], from: dateRange.start, to: dateRange.end).day ?? 1
        let averageTimePerDay = totalTime / Double(max(numberOfDays, 1))

        let categoryBreakdown = calculateCategoryBreakdown(entries: entries)
        let mostActiveCategory = categoryBreakdown.max(by: { $0.totalTime < $1.totalTime })

        let dailyBreakdown = calculateDailyBreakdown(entries: entries, from: dateRange.start, to: dateRange.end)

        let workRestRatio = calculateWorkRestRatio(categoryBreakdown: categoryBreakdown)

        return AnalyticsData(
            totalTime: totalTime,
            averageTimePerDay: averageTimePerDay,
            numberOfEntries: entries.count,
            mostActiveCategory: mostActiveCategory,
            categoryBreakdown: categoryBreakdown,
            dailyBreakdown: dailyBreakdown,
            workRestRatio: workRestRatio
        )
    }

    private func calculateCategoryBreakdown(entries: [TimeEntry]) -> [CategoryStatistic] {
        let allCategories = categoryService.getAllCategories()
        var statistics: [CategoryStatistic] = []

        let totalTime = entries.reduce(0) { $0 + $1.duration }

        for category in allCategories {
            let categoryEntries = entries.filter { $0.categoryId == category.id }
            guard !categoryEntries.isEmpty else { continue }

            let categoryTotalTime = categoryEntries.reduce(0) { $0 + $1.duration }
            let percentage = totalTime > 0 ? categoryTotalTime / totalTime : 0
            let averageDuration = categoryTotalTime / Double(categoryEntries.count)

            statistics.append(CategoryStatistic(
                id: UUID(),
                categoryId: category.id,
                categoryName: category.name,
                categoryColorHex: category.colorHex,
                totalTime: categoryTotalTime,
                numberOfEntries: categoryEntries.count,
                percentage: percentage,
                averageDuration: averageDuration
            ))
        }

        return statistics.sorted(by: { $0.totalTime > $1.totalTime })
    }

    private func calculateDailyBreakdown(entries: [TimeEntry], from startDate: Date, to endDate: Date) -> [DailyStatistic] {
        var dailyStats: [DailyStatistic] = []
        let calendar = Calendar.current

        var currentDate = startDate
        while currentDate <= endDate {
            let dayEntries = entries.filter { $0.startTime.isSameDay(as: currentDate) }
            let totalTime = dayEntries.reduce(0) { $0 + $1.duration }

            dailyStats.append(DailyStatistic(
                date: currentDate,
                totalTime: totalTime,
                numberOfEntries: dayEntries.count
            ))

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dailyStats
    }

    private func calculateWorkRestRatio(categoryBreakdown: [CategoryStatistic]) -> Double {
        let workCategories = ["Work", "Learning"]
        let restCategories = ["Rest", "Sleep", "Hobby", "Social"]

        let workTime = categoryBreakdown
            .filter { workCategories.contains($0.categoryName) }
            .reduce(0) { $0 + $1.totalTime }

        let restTime = categoryBreakdown
            .filter { restCategories.contains($0.categoryName) }
            .reduce(0) { $0 + $1.totalTime }

        return restTime > 0 ? workTime / restTime : 0
    }

    func getTodayAnalytics() -> AnalyticsData {
        getAnalytics(for: .today)
    }

    func getWeekAnalytics() -> AnalyticsData {
        getAnalytics(for: .thisWeek)
    }

    func getMonthAnalytics() -> AnalyticsData {
        getAnalytics(for: .thisMonth)
    }
}
