//  HapticsService.swift
//  TimeDiary


import UIKit

final class HapticsService {
    static let shared = HapticsService()
    private let storage = StorageService.shared

    private init() {}
    
    private var isEnabled: Bool {
        storage.loadBool(forKey: UserDefaultsKeys.hapticsEnabled, defaultValue: true)
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
