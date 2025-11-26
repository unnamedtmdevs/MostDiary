//  TimerService.swift
//  TimeDiary


import Foundation
import Combine

final class TimerService: ObservableObject {
    static let shared = TimerService()

    @Published var currentState: TimerState = .idle
    @Published var elapsedTime: TimeInterval = 0

    private var timer: Timer?
    private let storage = StorageService.shared

    private init() {
        loadState()
        if currentState.status == .running {
            startTimerUpdates()
        }
    }

    func start(category: Category) {
        currentState = TimerState(
            status: .running,
            categoryId: category.id,
            categoryName: category.name,
            startTime: Date(),
            elapsedTime: 0
        )
        saveState()
        startTimerUpdates()
        HapticsService.shared.notification(.success)
    }

    func stop() -> TimeEntry? {
        guard currentState.status == .running || currentState.status == .paused,
              let categoryId = currentState.categoryId,
              let categoryName = currentState.categoryName,
              let startTime = currentState.startTime else {
            return nil
        }

        stopTimerUpdates()

        let endTime = Date()
        _ = currentState.elapsedTime + (currentState.status == .running ? Date().timeIntervalSince(startTime) : 0)

        let entry = TimeEntry(
            categoryId: categoryId,
            categoryName: categoryName,
            startTime: startTime,
            endTime: endTime
        )

        currentState = .idle
        elapsedTime = 0
        saveState()
        HapticsService.shared.notification(.success)

        return entry
    }

    func pause() {
        guard currentState.status == .running,
              let startTime = currentState.startTime else {
            return
        }

        stopTimerUpdates()
        currentState.elapsedTime += Date().timeIntervalSince(startTime)
        currentState.status = .paused
        currentState.pausedTime = Date()
        elapsedTime = currentState.elapsedTime
        saveState()
        HapticsService.shared.impact(.medium)
    }

    func resume() {
        guard currentState.status == .paused else {
            return
        }

        currentState.status = .running
        currentState.startTime = Date()
        currentState.pausedTime = nil
        saveState()
        startTimerUpdates()
        HapticsService.shared.impact(.medium)
    }

    func getCurrentElapsedTime() -> TimeInterval {
        if currentState.status == .running, let startTime = currentState.startTime {
            return currentState.elapsedTime + Date().timeIntervalSince(startTime)
        } else {
            return currentState.elapsedTime
        }
    }

    private func startTimerUpdates() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }

    private func stopTimerUpdates() {
        timer?.invalidate()
        timer = nil
    }

    private func updateElapsedTime() {
        guard currentState.status == .running,
              let startTime = currentState.startTime else {
            return
        }

        elapsedTime = currentState.elapsedTime + Date().timeIntervalSince(startTime)
    }

    private func saveState() {
        storage.save(currentState, forKey: UserDefaultsKeys.currentTimerState)
    }

    private func loadState() {
        if let savedState = storage.load(forKey: UserDefaultsKeys.currentTimerState, as: TimerState.self) {
            currentState = savedState
            if currentState.status == .running {
                elapsedTime = getCurrentElapsedTime()
            } else {
                elapsedTime = currentState.elapsedTime
            }
        }
    }
}
