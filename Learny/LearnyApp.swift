import SwiftUI

@main
struct LearnyApp: App {
    @StateObject private var stats    = LearningStatsManager()
    @StateObject private var streak   = StreakManager()
    @StateObject private var trophies = TrophyManager()
    @StateObject private var notes    = NotificationsManager()
    @StateObject private var prefs    = UserPreferencesManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(stats)
                .environmentObject(streak)
                .environmentObject(trophies)
                .environmentObject(notes)
                .environmentObject(prefs)
        }
    }
}
