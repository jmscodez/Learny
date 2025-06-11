//
//  ProgressViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var streak: Int
    @Published var trophies: Set<String>

    private let streakManager: StreakManager
    private let trophyManager: TrophyManager

    init(streakManager: StreakManager, trophyManager: TrophyManager) {
        self.streakManager = streakManager
        self.trophyManager = trophyManager
        self.streak = streakManager.currentStreak
        self.trophies = trophyManager.unlockedTrophies
    }
}
