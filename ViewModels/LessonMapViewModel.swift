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
    
    /// Generates detailed content blocks for each lesson in the background if they don't already exist.
    func generateLessonContent() {
        // Only generate content if there's at least one lesson that needs it.
        let needsGeneration = lessons.contains { $0.contentBlocks.isEmpty }
        guard needsGeneration else {
            print("[CourseGen] All lessons have content. Skipping generation.")
            return
        }
        
        isGeneratingContent = true
        Task {
            let total = lessons.count
            // Using a task group to generate content for all empty lessons concurrently.
            await withTaskGroup(of: (Int, [ContentBlock]).self) { group in
                for (index, lesson) in lessons.enumerated() {
                    // Only generate if content is missing.
                    guard lesson.contentBlocks.isEmpty else { continue }
                    
                    let title = lesson.title
                    let topic = course.topic
                    
                    group.addTask {
                        print("[CourseGen] Generating content for lesson \(index + 1)/\(total): \(title)")
                        let blocks = await OpenAIService.shared.generateLessonContent(for: title, topic: topic)
                        print("[CourseGen] Completed generation for lesson \(index + 1)/\(total): \(title)")
                        return (index, blocks)
                    }
                }
                
                // As tasks finish, update the lessons on the main thread.
                for await (index, blocks) in group {
                    if lessons.indices.contains(index) {
                        lessons[index].contentBlocks = blocks
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
