//  NotificationService.swift
//  TimeDiary

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleDailyNotification(at time: Date) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "MostDiary Reminder"
        content.body = "Don't forget to track your time today!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { _ in
        }
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

