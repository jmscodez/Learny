//
//  LessonMapViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class LessonMapViewModel: ObservableObject {
    @Published var course: Course
    @Published var lessons: [Lesson]
    
    // Publishes the amount of XP gained when a lesson is completed
    let xpGainedPublisher = PassthroughSubject<Int, Never>()
    
    private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // TODO: Potentially replace with a more sophisticated unlocking logic
    // For now, we assume lessons are unlocked sequentially.
    
    init(course: Course) {
        self.course = course
        // Set the initial state of lessons. The first non-completed lesson is the current one.
        var tempLessons = course.lessons
        if let firstIncompleteIndex = tempLessons.firstIndex(where: { !$0.isCompleted }) {
            tempLessons[firstIncompleteIndex].isCurrent = true
        }
        self.lessons = tempLessons
    }
    
    func markComplete(lesson: Lesson) {
        guard let lessonIndex = lessons.firstIndex(where: { $0.id == lesson.id }) else { return }
        
        // Mark the current lesson as complete and no longer current.
        lessons[lessonIndex].isCompleted = true
        lessons[lessonIndex].isCurrent = false
        
        let xpGained = 10
        xpGainedPublisher.send(xpGained)
        hapticGenerator.impactOccurred()
        
        // Unlock and set the next lesson as current.
        let nextIndex = lessonIndex + 1
        if lessons.indices.contains(nextIndex) {
            lessons[nextIndex].isCurrent = true
        }
        
        // This is a good place to notify other services about progress
        // For example: LearningStatsManager, StreakManager, etc.
        // TODO: Add calls to managers to update stats, streaks, etc.
    }
}
