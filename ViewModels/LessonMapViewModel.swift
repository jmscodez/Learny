//
//  LessonMapViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation
import SwiftUI

@MainActor
class LessonMapViewModel: ObservableObject {
    @Published var course: Course
    @Published var lessons: [Lesson]
    
    // TODO: Potentially replace with a more sophisticated unlocking logic
    // For now, we assume lessons are unlocked sequentially.
    
    init(course: Course) {
        self.course = course
        self.lessons = course.lessons.map { lesson in
            var mutableLesson = lesson
            // For the purpose of this view model, let's ensure the first lesson is always unlocked.
            if lesson.id == course.lessons.first?.id {
                mutableLesson.isUnlocked = true
            }
            return mutableLesson
        }
    }
    
    func markComplete(lesson: Lesson) {
        guard let lessonIndex = lessons.firstIndex(where: { $0.id == lesson.id }) else { return }
        
        // Mark the current lesson as complete
        lessons[lessonIndex].isComplete = true
        
        // Unlock the next lesson
        let nextIndex = lessonIndex + 1
        if lessons.indices.contains(nextIndex) {
            lessons[nextIndex].isUnlocked = true
        }
        
        // This is a good place to notify other services about progress
        // For example: LearningStatsManager, StreakManager, etc.
        // TODO: Add calls to managers to update stats, streaks, etc.
    }
}
