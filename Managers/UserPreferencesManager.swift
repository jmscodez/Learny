//
//  UserPreferencesManager.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

final class UserPreferencesManager: ObservableObject {
    @Published var reminderHour: Int = UserDefaults.standard.integer(forKey: "reminderHour") {
        didSet { UserDefaults.standard.set(reminderHour, forKey: "reminderHour") }
    }
    @Published var reminderMinute: Int = UserDefaults.standard.integer(forKey: "reminderMinute") {
        didSet { UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute") }
    }
}
