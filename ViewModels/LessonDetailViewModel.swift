//
//  LessonDetailViewModel.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation
import Combine

@MainActor
class LessonDetailViewModel: ObservableObject {
    let lesson: Lesson
    
    @Published var userAnswers: [Int?]
    @Published var quizScore: Int = 0
    @Published var isQuizSubmitted: Bool = false
    
    var onLessonComplete: (() -> Void)?

    init(lesson: Lesson, onLessonComplete: (() -> Void)? = nil) {
        self.lesson = lesson
        self.userAnswers = Array(repeating: nil, count: lesson.quiz.count)
        self.onLessonComplete = onLessonComplete
    }
    
    func selectAnswer(for questionIndex: Int, answerIndex: Int) {
        guard questionIndex < userAnswers.count else { return }
        userAnswers[questionIndex] = answerIndex
    }

    func submitQuiz() {
        var score = 0
        for (index, question) in lesson.quiz.enumerated() {
            if let userAnswerIndex = userAnswers[index], userAnswerIndex == question.correctIndex {
                score += 1
            }
        }
        self.quizScore = score
        self.isQuizSubmitted = true
        
        // Passing score is >= 80%
        if Double(score) / Double(lesson.quiz.count) >= 0.8 {
            onLessonComplete?()
        }
    }
}
