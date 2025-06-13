import SwiftUI

@main
struct LearnyApp: App {
    @StateObject private var stats    = LearningStatsManager()
    @StateObject private var streak   = StreakManager()
    @StateObject private var trophies = TrophyManager()
    @StateObject private var notes    = NotificationsManager()
    @StateObject private var prefs    = UserPreferencesManager()

    init() {
        // --- Navigation Bar Appearance ---
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.black
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // --- Tab Bar Appearance ---
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black

        // Set color for unselected items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Set color for selected items
        let selectedColor = UIColor.cyan
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
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