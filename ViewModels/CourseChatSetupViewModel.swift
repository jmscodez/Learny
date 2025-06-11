//
//  CourseChatSetupViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

@MainActor
final class CourseChatSetupViewModel: ObservableObject {
    @Published var topic: String = ""
    @Published var difficulty: Difficulty = .beginner
    @Published var pace: Pace = .balanced
    @Published var isLoading = false

    private let stats: LearningStatsManager

    init(stats: LearningStatsManager) {
        self.stats = stats
    }

    func generateCourse() async {
        guard !topic.isEmpty else { return }
        isLoading = true

        let course = Course(
            id: UUID(),
            title: topic,
            topic: topic,
            difficulty: difficulty,
            pace: pace,
            creationMethod: .aiAssistant,
            lessons: [],
            createdAt: Date()
        )

        do {
            let lessons = try await OpenAIService.shared.generateLessons(for: course)
            var newCourse = course
            newCourse.lessons = lessons
            stats.addCourse(newCourse)
        } catch {
            print("❌ \(error)")
        }

        isLoading = false
    }
}
