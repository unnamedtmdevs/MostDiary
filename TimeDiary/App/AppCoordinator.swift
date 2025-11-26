//  AppCoordinator.swift
//  TimeDiary


import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isLoading = true
    @Published var showOnboarding = false
    @Published var currentOnboardingPage = 0
    @Published var selectedTab: TabItem = .home

    private let storage = StorageService.shared

    init() {
        checkOnboardingStatus()
    }

    private func checkOnboardingStatus() {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            let hasSeenOnboarding = storage.loadBool(forKey: UserDefaultsKeys.hasSeenOnboarding)

            await MainActor.run {
                self.isLoading = false
                self.showOnboarding = !hasSeenOnboarding
            }
        }
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
