//  TrackingViewModel.swift
//  TimeDiary


import SwiftUI
import Combine

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var timerState: TimerState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var todayTotalTime: TimeInterval = 0
    @Published var todayEntries: [TimeEntry] = []

    private let categoryService = CategoryService.shared
    private let timeTrackingService = TimeTrackingService.shared
    private let timerService = TimerService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadCategories()
        setupBindings()
        loadTodayData()
        setupCategoryNotifications()
    }
    
    private func setupCategoryNotifications() {
        NotificationCenter.default.publisher(for: .categoriesDidChange)
            .sink { [weak self] _ in
                self?.loadCategories()
            }
            .store(in: &cancellables)
    }

    private func setupBindings() {
        timerService.$currentState
            .sink { [weak self] state in
                self?.timerState = state
                if let categoryId = state.categoryId {
                    self?.selectedCategory = self?.categoryService.getCategory(byId: categoryId)
                }
            }
            .store(in: &cancellables)

        timerService.$elapsedTime
            .assign(to: &$elapsedTime)
    }

    func loadCategories() {
        categories = categoryService.getAllCategories()
    }

    func loadTodayData() {
        todayEntries = timeTrackingService.getTodayEntries()
        todayTotalTime = todayEntries.reduce(0) { $0 + $1.duration }
    }

    func selectCategory(_ category: Category) {
        selectedCategory = category
    }

    func startTimer() {
        guard let category = selectedCategory else { return }
        timerService.start(category: category)
        categoryService.updateLastUsed(categoryId: category.id)
    }

    func stopTimer() {
        if let entry = timerService.stop() {
            timeTrackingService.createEntry(entry)
            selectedCategory = nil
            loadTodayData()
        }
    }

    func pauseTimer() {
        timerService.pause()
    }

    func resumeTimer() {
        timerService.resume()
    }

    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var formattedTodayTime: String {
        let hours = Int(todayTotalTime) / 3600
        let minutes = (Int(todayTotalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var canStartTimer: Bool {
        selectedCategory != nil && timerState.status == .idle
    }

    var isTimerRunning: Bool {
        timerState.status == .running
    }

    var isTimerPaused: Bool {
        timerState.status == .paused
    }

    var mostUsedCategories: [Category] {
        categories
            .filter { $0.lastUsedAt != nil }
            .sorted { ($0.lastUsedAt ?? Date.distantPast) > ($1.lastUsedAt ?? Date.distantPast) }
            .prefix(4)
            .map { $0 }
    }
}
