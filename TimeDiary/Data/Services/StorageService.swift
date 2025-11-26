//  StorageService.swift
//  TimeDiary


import Foundation

final class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard

    private init() {}

    func save<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key)
        }
    }

    func load<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func saveBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func loadBool(forKey key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }
    
    func loadBool(forKey key: String, defaultValue: Bool) -> Bool {
        if userDefaults.object(forKey: key) == nil {
            return defaultValue
        }
        return userDefaults.bool(forKey: key)
    }

    func saveDouble(_ value: Double, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func loadDouble(forKey key: String) -> Double {
        userDefaults.double(forKey: key)
    }

    func saveDate(_ value: Date, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func loadDate(forKey key: String) -> Date? {
        userDefaults.object(forKey: key) as? Date
    }
    
    func saveString(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }
    }

    func exportToCSV(entries: [TimeEntry], categories: [Category]) -> String {
        var csv = "Date,Category,Start Time,End Time,Duration (minutes)\n"

        for entry in entries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: entry.startTime)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            let startTime = timeFormatter.string(from: entry.startTime)
            let endTime = timeFormatter.string(from: entry.endTime)

            let durationMinutes = Int(entry.duration / 60)

            csv += "\(date),\(entry.categoryName),\(startTime),\(endTime),\(durationMinutes)\n"
        }

        return csv
    }
}
