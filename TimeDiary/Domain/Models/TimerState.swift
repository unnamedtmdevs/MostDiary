//  TimerState.swift
//  TimeDiary


import Foundation

enum TimerStatus: String, Codable {
    case idle
    case running
    case paused
}

struct TimerState: Codable {
    var status: TimerStatus
    var categoryId: UUID?
    var categoryName: String?
    var startTime: Date?
    var pausedTime: Date?
    var elapsedTime: TimeInterval

    init(
        status: TimerStatus = .idle,
        categoryId: UUID? = nil,
        categoryName: String? = nil,
        startTime: Date? = nil,
        pausedTime: Date? = nil,
        elapsedTime: TimeInterval = 0
    ) {
        self.status = status
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.startTime = startTime
        self.pausedTime = pausedTime
        self.elapsedTime = elapsedTime
    }

    static let idle = TimerState()
}
