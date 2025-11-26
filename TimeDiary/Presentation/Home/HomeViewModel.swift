//  HomeViewModel.swift
//  TimeDiary


import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayTotalTime: TimeInterval = 0
    @Published var weekTotalTime: TimeInterval = 0
    @Published var recentEntries: [TimeEntry] = []
    @Published var mostUsedCategory: Category?
    @Published var timerState: TimerState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var todayAnalytics: AnalyticsData?

    private let timeTrackingService = TimeTrackingService.shared
    private let analyticsService = AnalyticsService.shared
    private let categoryService = CategoryService.shared
    private let timerService = TimerService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        loadData()
        setupCategoryNotifications()
    }
    
    private func setupCategoryNotifications() {
        NotificationCenter.default.publisher(for: .categoriesDidChange)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }

    private func setupBindings() {
        timerService.$currentState
            .assign(to: &$timerState)

        timerService.$elapsedTime
            .assign(to: &$elapsedTime)
    }

    func loadData() {
        let todayEntries = timeTrackingService.getTodayEntries()
        todayTotalTime = todayEntries.reduce(0) { $0 + $1.duration }

        let weekStart = Date().startOfWeek
        let weekEnd = Date().endOfWeek
        let weekEntries = timeTrackingService.getEntries(from: weekStart, to: weekEnd)
        weekTotalTime = weekEntries.reduce(0) { $0 + $1.duration }

        recentEntries = timeTrackingService.getRecentEntries(limit: 5)

        todayAnalytics = analyticsService.getTodayAnalytics()
        mostUsedCategory = todayAnalytics?.mostActiveCategory.flatMap {
            categoryService.getCategory(byId: $0.categoryId)
        }
    }

    var formattedTodayTime: String {
        formatTime(todayTotalTime)
    }

    var formattedWeekTime: String {
        formatTime(weekTotalTime)
    }

    var formattedElapsedTime: String {
        formatTime(elapsedTime)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var averageTimePerDay: String {
        todayAnalytics?.formattedAverageTime ?? "0m"
    }

    var hasActiveTimer: Bool {
        timerState.status == .running || timerState.status == .paused
    }
    
    func updateEntry(_ entry: TimeEntry) {
        timeTrackingService.updateEntry(entry)
        loadData()
    }
}
