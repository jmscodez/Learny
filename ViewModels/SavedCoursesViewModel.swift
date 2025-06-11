//
//  SavedCoursesViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import SwiftUI

@MainActor
final class SavedCoursesViewModel: ObservableObject {
    @Published var editMode: EditMode = .inactive
    private let stats: LearningStatsManager

    init(stats: LearningStatsManager) {
        self.stats = stats
    }

    func delete(at offsets: IndexSet) {
        stats.deleteCourses(at: offsets)
    }
}
