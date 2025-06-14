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
    @Published var isGeneratingContent: Bool = false
    
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
    
    /// Generates detailed content blocks for each lesson in the background, logging progress.
    func generateLessonContent() {
        isGeneratingContent = true
        Task {
            let total = lessons.count
            // Generate first two lessons in order
            for idx in 0..<min(2, total) {
                let title = lessons[idx].title
                print("[CourseGen] Generating content for lesson \(idx+1)/\(total): \(title)")
                let blocks = await OpenAIService.shared.generateLessonContent(for: title, topic: course.topic)
                lessons[idx].contentBlocks = blocks
                print("[CourseGen] Completed generation for lesson \(idx+1)/\(total): \(title)")
            }
            // Generate the rest in background tasks
            await withTaskGroup(of: Void.self) { group in
                for idx in 2..<total {
                    let title = lessons[idx].title
                    let topic = course.topic
                    group.addTask {
                        print("[CourseGen] (BG) Generating content for lesson \(idx+1)/\(total): \(title)")
                        let blocks = await OpenAIService.shared.generateLessonContent(for: title, topic: topic)
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.lessons[idx].contentBlocks = blocks
                        }
                        print("[CourseGen] (BG) Completed generation for lesson \(idx+1)/\(total): \(title)")
                    }
                }
            }
            isGeneratingContent = false
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
