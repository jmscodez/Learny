import SwiftUI

@main
struct LearnyApp: App {
    @StateObject private var stats    = LearningStatsManager()
    @StateObject private var streak   = StreakManager()
    @StateObject private var trophies = TrophyManager()
    @StateObject private var notes    = NotificationsManager()
    @StateObject private var prefs    = UserPreferencesManager()
    @StateObject private var nav      = NavigationManager()
    @StateObject private var generator = CourseGenerationManager()
    
    init() {
        // --- Tab Bar Appearance ---
        let appearance = UITabBarAppearance()
        
        // Set background to opaque and black
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Set color for unselected items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Set color for selected items
        let selectedColor = UIColor.cyan // The same blue from before
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        // Apply the appearance
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
                .environmentObject(nav)
                .environmentObject(generator)
        }
    }
}
