//  SettingsViewModel.swift
//  TimeDiary


import SwiftUI
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var use24HourFormat: Bool = false
    @Published var enableNotifications: Bool = false
    @Published var hapticsEnabled: Bool = true
    @Published var selectedTheme: ColorTheme = .dark
    @Published var notificationTime: Date = {
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @Published var showingClearDataAlert = false
    @Published var showingClearDataSuccess = false
    @Published var showingExportSheet = false
    @Published var showingNotificationTimePicker = false
    @Published var exportedCSV: String = ""
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined

    private let storage = StorageService.shared
    private let timeTrackingService = TimeTrackingService.shared
    private let categoryService = CategoryService.shared
    private let notificationService = NotificationService.shared
    private let themeManager = ThemeManager.shared

    init() {
        selectedTheme = themeManager.currentTheme
        loadSettings()
        checkNotificationStatus()
    }
    
    func checkNotificationStatus() {
        Task {
            let status = await notificationService.checkAuthorizationStatus()
            await MainActor.run {
                notificationAuthorizationStatus = status
            }
        }
    }

    func loadSettings() {
        use24HourFormat = storage.loadBool(forKey: UserDefaultsKeys.use24HourFormat)
        enableNotifications = storage.loadBool(forKey: UserDefaultsKeys.enableNotifications)
        hapticsEnabled = storage.loadBool(forKey: UserDefaultsKeys.hapticsEnabled, defaultValue: true)
        selectedTheme = themeManager.currentTheme
        
        if let savedTime = storage.loadDate(forKey: UserDefaultsKeys.notificationTime) {
            notificationTime = savedTime
        }
        
        // Schedule notification if enabled
        if enableNotifications {
            scheduleNotification()
        }
    }

    func saveSettings() {
        storage.saveBool(use24HourFormat, forKey: UserDefaultsKeys.use24HourFormat)
        storage.saveBool(enableNotifications, forKey: UserDefaultsKeys.enableNotifications)
        storage.saveBool(hapticsEnabled, forKey: UserDefaultsKeys.hapticsEnabled)
        storage.saveDate(notificationTime, forKey: UserDefaultsKeys.notificationTime)
        
        if selectedTheme != themeManager.currentTheme {
            themeManager.currentTheme = selectedTheme
        }
    }
    
    func requestNotificationPermission() async {
        let granted = await notificationService.requestAuthorization()
        await MainActor.run {
            if granted {
                enableNotifications = true
                saveSettings()
                scheduleNotification()
            }
            checkNotificationStatus()
        }
    }
    
    func scheduleNotification() {
        if enableNotifications {
            notificationService.scheduleDailyNotification(at: notificationTime)
        } else {
            notificationService.cancelNotifications()
        }
    }

    func exportData() {
        let entries = timeTrackingService.getAllEntries()
        let categories = categoryService.getAllCategories()
        exportedCSV = storage.exportToCSV(entries: entries, categories: categories)
        showingExportSheet = true
    }

    func clearAllData() {
        storage.clearAll()
        showingClearDataSuccess = true
        HapticsService.shared.notification(.success)
    }

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    var totalTimeTracked: String {
        let total = storage.loadDouble(forKey: UserDefaultsKeys.totalTimeTracked)
        let hours = Int(total) / 3600
        if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = (Int(total) % 3600) / 60
            return "\(minutes)m"
        }
    }

    var totalEntries: Int {
        timeTrackingService.getAllEntries().count
    }

    var firstEntryDate: String {
        if let date = storage.loadDate(forKey: UserDefaultsKeys.firstEntryDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return "No entries yet"
    }
    
    var formattedNotificationTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: notificationTime)
    }
}
