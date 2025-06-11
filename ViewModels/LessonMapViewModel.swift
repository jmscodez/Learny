//
//  LessonMapViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

@MainActor
final class LessonMapViewModel: ObservableObject {
    @Published var lessons: [Lesson]
    private let course: Course
    private let stats: LearningStatsManager

    init(course: Course, stats: LearningStatsManager) {
        self.course = course
        self.lessons = course.lessons
        self.stats = stats
    }

    func markComplete(_ lesson: Lesson) {
        guard
            let idx = lessons.firstIndex(where: { $0.id == lesson.id }),
            idx + 1 < lessons.count
        else { return }

        lessons[idx].isComplete = true
        lessons[idx + 1].isUnlocked = true

        var updated = course
        updated.lessons = lessons
        stats.updateCourse(updated)
    }
}
