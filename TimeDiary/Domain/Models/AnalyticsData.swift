//  AnalyticsData.swift
//  TimeDiary


import Foundation

struct AnalyticsData {
    var totalTime: TimeInterval
    var averageTimePerDay: TimeInterval
    var numberOfEntries: Int
    var mostActiveCategory: CategoryStatistic?
    var categoryBreakdown: [CategoryStatistic]
    var dailyBreakdown: [DailyStatistic]
    var workRestRatio: Double

    init(
        totalTime: TimeInterval = 0,
        averageTimePerDay: TimeInterval = 0,
        numberOfEntries: Int = 0,
        mostActiveCategory: CategoryStatistic? = nil,
        categoryBreakdown: [CategoryStatistic] = [],
        dailyBreakdown: [DailyStatistic] = [],
        workRestRatio: Double = 0
    ) {
        self.totalTime = totalTime
        self.averageTimePerDay = averageTimePerDay
        self.numberOfEntries = numberOfEntries
        self.mostActiveCategory = mostActiveCategory
        self.categoryBreakdown = categoryBreakdown
        self.dailyBreakdown = dailyBreakdown
        self.workRestRatio = workRestRatio
    }

    var formattedTotalTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedAverageTime: String {
        let hours = Int(averageTimePerDay) / 3600
        let minutes = (Int(averageTimePerDay) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CategoryStatistic: Identifiable {
    let id: UUID
    let categoryId: UUID
    let categoryName: String
    let categoryColorHex: String
    var totalTime: TimeInterval
    var numberOfEntries: Int
    var percentage: Double
    var averageDuration: TimeInterval

    var formattedTotalTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedPercentage: String {
        String(format: "%.1f%%", percentage * 100)
    }
}

struct DailyStatistic: Identifiable {
    let id: UUID
    let date: Date
    var totalTime: TimeInterval
    var numberOfEntries: Int

    init(id: UUID = UUID(), date: Date, totalTime: TimeInterval, numberOfEntries: Int) {
        self.id = id
        self.date = date
        self.totalTime = totalTime
        self.numberOfEntries = numberOfEntries
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    var formattedTotalTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

enum TimePeriod {
    case today
    case thisWeek
    case thisMonth
    case custom(start: Date, end: Date)

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return (start, end)

        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? now
            return (start, end)

        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
            return (start, end)

        case .custom(let start, let end):
            return (start, end)
        }
    }

    var displayName: String {
        switch self {
        case .today:
            return "Today"
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        case .custom:
            return "Custom Range"
        }
    }
}
