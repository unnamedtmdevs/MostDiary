//  AppCoordinator.swift
//  TimeDiary


import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isLoading = true
    @Published var showOnboarding = false
    @Published var currentOnboardingPage = 0
    @Published var selectedTab: TabItem = .home
    @Published var showServerCheck = false
    @Published var isServerBlocked = true

    private let storage = StorageService.shared

    init() {
        checkServerStatus()
    }

    private func checkServerStatus() {
        Task {
            await MainActor.run {
                self.isLoading = false
                // Всегда показываем проверку сервера при запуске
                self.showServerCheck = true
            }
        }
    }
    
    private func checkOnboardingStatus() {
        let hasSeenOnboarding = storage.loadBool(forKey: UserDefaultsKeys.hasSeenOnboarding)
        self.showOnboarding = !hasSeenOnboarding
    }

    func completeOnboarding() {
        storage.saveBool(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
        showOnboarding = false
    }

    func nextOnboardingPage() {
        if currentOnboardingPage < 2 {
            currentOnboardingPage += 1
        } else {
            completeOnboarding()
        }
    }
}
