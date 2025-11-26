//  TimeTrackingService.swift
//  TimeDiary


import Foundation

final class TimeTrackingService {
    static let shared = TimeTrackingService()
    private let storage = StorageService.shared

    private init() {}

    func getAllEntries() -> [TimeEntry] {
        storage.load(forKey: UserDefaultsKeys.timeEntries, as: [TimeEntry].self) ?? []
    }

    func getEntries(for date: Date) -> [TimeEntry] {
        let entries = getAllEntries()
        return entries.filter { $0.startTime.isSameDay(as: date) }
    }

    func getEntries(from startDate: Date, to endDate: Date) -> [TimeEntry] {
        let entries = getAllEntries()
        return entries.filter { entry in
            entry.startTime >= startDate && entry.startTime <= endDate
        }
    }

    func getEntries(for categoryId: UUID) -> [TimeEntry] {
        let entries = getAllEntries()
        return entries.filter { $0.categoryId == categoryId }
    }

    func createEntry(_ entry: TimeEntry) {
        var entries = getAllEntries()
        entries.append(entry)
        entries.sort { $0.startTime > $1.startTime }
        storage.save(entries, forKey: UserDefaultsKeys.timeEntries)

        updateFirstEntryDate(entry.startTime)
        updateTotalTimeTracked(entry.duration)
    }

    func updateEntry(_ entry: TimeEntry) {
        var entries = getAllEntries()
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            let oldDuration = entries[index].duration
            entries[index] = entry
            storage.save(entries, forKey: UserDefaultsKeys.timeEntries)

            let durationDifference = entry.duration - oldDuration
            updateTotalTimeTracked(durationDifference)
        }
    }

    func deleteEntry(id: UUID) {
        var entries = getAllEntries()
        if let index = entries.firstIndex(where: { $0.id == id }) {
            let duration = entries[index].duration
            entries.remove(at: index)
            storage.save(entries, forKey: UserDefaultsKeys.timeEntries)

            updateTotalTimeTracked(-duration)
        }
    }

    func searchEntries(query: String) -> [TimeEntry] {
        let entries = getAllEntries()
        return entries.filter { entry in
            entry.categoryName.localizedCaseInsensitiveContains(query)
        }
    }

    func getTodayEntries() -> [TimeEntry] {
        getEntries(for: Date())
    }

    func getTodayTotalTime() -> TimeInterval {
        let entries = getTodayEntries()
        return entries.reduce(0) { $0 + $1.duration }
    }

    func getRecentEntries(limit: Int = 5) -> [TimeEntry] {
        let entries = getAllEntries()
        return Array(entries.prefix(limit))
    }

    private func updateTotalTimeTracked(_ duration: TimeInterval) {
        let currentTotal = storage.loadDouble(forKey: UserDefaultsKeys.totalTimeTracked)
        storage.saveDouble(currentTotal + duration, forKey: UserDefaultsKeys.totalTimeTracked)
    }

    private func updateFirstEntryDate(_ date: Date) {
        if let existingDate = storage.loadDate(forKey: UserDefaultsKeys.firstEntryDate) {
            if date < existingDate {
                storage.saveDate(date, forKey: UserDefaultsKeys.firstEntryDate)
            }
        } else {
            storage.saveDate(date, forKey: UserDefaultsKeys.firstEntryDate)
        }
    }
}
