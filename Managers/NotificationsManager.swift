//
//  NotificationsManager.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation
import UserNotifications

final class NotificationsManager: ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleCourseReadyNotification(courseName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Your Course is Ready!"
        content.body = "Your new course, '\(courseName)', has been generated and is ready for you to start."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            var comps = DateComponents()
            comps.hour = hour; comps.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = "Time to Learn!"
            content.body  = "Open Learny and continue your course."
            let req = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
            center.add(req)
        }
    }
}
