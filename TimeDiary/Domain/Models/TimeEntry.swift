//  TimeEntry.swift
//  TimeDiary


import Foundation

struct TimeEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var categoryId: UUID
    var categoryName: String
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var createdAt: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        categoryName: String,
        startTime: Date,
        endTime: Date,
        createdAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.createdAt = createdAt
        self.notes = notes
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(startTime) {
            return "Today"
        } else if calendar.isDateInYesterday(startTime) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: startTime)
        }
    }
}
