//
//  QuizView.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//
 
import SwiftUI

struct QuizView: View {
    let quiz: [QuizQuestion]
    let onComplete: () -> Void
    
    @State private var currentQuestionIndex = 0
    @State private var selectedOptionIndex: Int?
    @State private var correctAnswers = 0
    @State private var showResults = false
    
    private var currentQuestion: QuizQuestion {
        quiz[currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showResults {
                QuizResultsView(
                    correctAnswers: correctAnswers,
                    totalQuestions: quiz.count,
                    onContinue: onComplete
                )
            } else {
                VStack(spacing: 32) {
                    Text("Checkpoint Quiz")
                        .font(.largeTitle).bold()
                    
                    Text("Question \(currentQuestionIndex + 1) of \(quiz.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text(currentQuestion.prompt)
                            .font(.title2).bold()
                            .lineLimit(nil)
                        
                        ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                            OptionRow(
                                text: currentQuestion.options[index],
                                isSelected: selectedOptionIndex == index,
                                isCorrect: index == currentQuestion.correctIndex,
                                selectionState: getSelectionState(for: index)
                            )
                            .onTapGesture {
                                if selectedOptionIndex == nil {
                                    handleSelection(index)
                                }
                            }
                        }
                    }
                    
                    nextButton
                }
                .padding()
            }
        }
        .foregroundColor(.white)
        .navigationBarHidden(true)
    }
    
    private var nextButton: some View {
        Button(action: handleNext) {
            Text(currentQuestionIndex == quiz.count - 1 ? "Finish Quiz" : "Next Question")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedOptionIndex != nil ? Color.yellow : Color.gray)
                .cornerRadius(16)
        }
        .disabled(selectedOptionIndex == nil)
    }
    
    private func getSelectionState(for index: Int) -> SelectionState {
        guard let selectedOptionIndex = selectedOptionIndex else { return .unselected }
        
        if index == currentQuestion.correctIndex {
            return .correct
        } else if index == selectedOptionIndex {
            return .incorrect
        } else {
            return .unselected
        }
    }
    
    private func handleSelection(_ index: Int) {
        selectedOptionIndex = index
        if index == currentQuestion.correctIndex {
            correctAnswers += 1
            // TODO: Play correct sound/haptic
        } else {
            // TODO: Play incorrect sound/haptic
        }
    }
    
    private func handleNext() {
        if currentQuestionIndex < quiz.count - 1 {
            currentQuestionIndex += 1
            selectedOptionIndex = nil
        } else {
            showResults = true
        }
    }
}

// MARK: - Subviews & Helpers

private enum SelectionState {
    case unselected, correct, incorrect
}

private struct OptionRow: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let selectionState: SelectionState
    
    private var backgroundColor: Color {
        switch selectionState {
        case .correct: return .green.opacity(0.3)
        case .incorrect: return .red.opacity(0.3)
        case .unselected: return .gray.opacity(0.2)
        }
    }
    
    private var strokeColor: Color {
        switch selectionState {
        case .correct: return .green
        case .incorrect: return .red
        case .unselected: return .gray
        }
    }
    
    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
            Spacer()
            if selectionState == .correct {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            } else if selectionState == .incorrect {
                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeColor, lineWidth: 2)
        )
        .animation(.easeInOut, value: selectionState)
    }
}

// MARK: - Preview

struct QuizView_Previews: PreviewProvider {
    static let sampleQuiz = [
        QuizQuestion(id: UUID(), prompt: "What event triggered the start of World War I?", options: ["The signing of the Treaty of Versailles", "The assassination of Archduke Franz Ferdinand", "The invasion of Poland", "The sinking of the Lusitania"], correctIndex: 1),
        QuizQuestion(id: UUID(), prompt: "Which of these was a major feature of warfare on the Western Front?", options: ["Guerilla warfare", "Naval battles", "Trench warfare", "Aerial dogfights"], correctIndex: 2)
    ]
    
    static var previews: some View {
        QuizView(quiz: sampleQuiz, onComplete: {})
    }
}
