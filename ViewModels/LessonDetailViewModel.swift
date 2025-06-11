//
//  LessonDetailViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

@MainActor
final class LessonDetailViewModel: ObservableObject {
    let lesson: Lesson
    @Published var userScore = 0

    init(lesson: Lesson) {
        self.lesson = lesson
    }

    func submitQuiz(answers: [Int]) {
        userScore = zip(lesson.quiz, answers).reduce(0) { score, pair in
            score + (pair.0.correctIndex == pair.1 ? 1 : 0)
        }
    }
}
