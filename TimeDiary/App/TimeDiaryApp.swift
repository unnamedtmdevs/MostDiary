//  TimeDiaryApp.swift
//  TimeDiary


import SwiftUI

@main
struct TimeDiaryApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        NavAppearance.applyTransparentBars()
    }

    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environmentObject(themeManager)
        }
    }
}
