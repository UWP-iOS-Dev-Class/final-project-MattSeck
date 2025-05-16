///Users/matthewsecketa/Documents/GitHub/final-project-MattSeck/MileMark/MileMark.xcodeproj
//  NotificationManager.swift
//  MileMark
//
//  Created by Matthew Secketa on 5/15/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}


    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Notifications authorized by user." : "❌ Notifications denied by user.")
            }
        }
    }


    func scheduleMileageReminder(for carName: String, in days: Int) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("🔕 Notifications are disabled in system settings.")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Mileage Update Reminder"
            content.body = "Don't forget to log mileage for your \(carName)."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(days * 86400), // 86400 = seconds per day
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("📅 Reminder scheduled for \(carName) in \(days) day(s).")
                }
            }
        }
    }
}
