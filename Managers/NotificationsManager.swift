//
//  NotificationsManager.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation
import UserNotifications

final class NotificationsManager: ObservableObject {
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
