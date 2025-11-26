//  ThemeManager.swift
//  TimeDiary


import SwiftUI

enum ColorTheme: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    case system = "system"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }
    
    var displayName: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .system:
            return "System"
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ColorTheme = .dark {
        didSet {
            saveTheme()
            updateColorScheme()
        }
    }
    
    private let storage = StorageService.shared
    
    private init() {
        loadTheme()
    }
    
    private func loadTheme() {
        if let savedTheme = storage.loadString(forKey: UserDefaultsKeys.appTheme),
           let theme = ColorTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            // Always default to dark theme on first launch
            currentTheme = .dark
            saveTheme()
        }
    }
    
    private func saveTheme() {
        storage.saveString(currentTheme.rawValue, forKey: UserDefaultsKeys.appTheme)
    }
    
    private func updateColorScheme() {
        // Force view update
        objectWillChange.send()
    }
}

