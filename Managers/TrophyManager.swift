//
//  TrophyManager.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

final class TrophyManager: ObservableObject {
    @Published var unlockedTrophies: Set<String> = []

    func evaluate(courses: [Course], streak: Int) {
        if courses.contains(where: { $0.lessons.allSatisfy(\.isComplete) }) {
            unlockedTrophies.insert("First Course Complete")
        }
        if streak >= 3 {
            unlockedTrophies.insert("3-Day Streak")
        }
        // TODO: add more trophies
    }
}
