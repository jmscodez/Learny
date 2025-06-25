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
    @State private var showFeedback = false
    @State private var answeredQuestions: Set<Int> = []
    
    private var currentQuestion: QuizQuestion {
        quiz[currentQuestionIndex]
    }
    
    private var passingScore: Int {
        max(1, Int(ceil(Double(quiz.count) * 0.8))) // 80% to pass
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced gradient background matching the lesson map
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),  // Dark navy
                        Color(red: 0.2, green: 0.2, blue: 0.4),  // Deeper blue
                        Color(red: 0.1, green: 0.3, blue: 0.5)   // Rich blue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if showResults {
                    QuizResultsView(
                        correctAnswers: correctAnswers,
                        totalQuestions: quiz.count,
                        onContinue: onComplete
                    )
                } else {
                    VStack(spacing: 0) {
                        // Enhanced Header
                        QuizHeader(
                            currentQuestion: currentQuestionIndex + 1,
                            totalQuestions: quiz.count,
                            correctAnswers: correctAnswers
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Question Content in ScrollView
                        ScrollView {
                            VStack(spacing: 24) {
                                // Question Card
                                QuestionCard(question: currentQuestion.prompt)
                                    .padding(.horizontal, 20)
                                
                                // Options
                                VStack(spacing: 16) {
                                    ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                                        OptionRow(
                                            text: currentQuestion.options[index],
                                            isSelected: selectedOptionIndex == index,
                                            isCorrect: index == currentQuestion.correctIndex,
                                            selectionState: getSelectionState(for: index),
                                            showFeedback: showFeedback
                                        )
                                        .onTapGesture {
                                            if selectedOptionIndex == nil {
                                                handleSelection(index)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Feedback Section
                                if showFeedback {
                                    FeedbackSection(
                                        isCorrect: selectedOptionIndex == currentQuestion.correctIndex,
                                        correctAnswer: currentQuestion.options[currentQuestion.correctIndex]
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                }
                                
                                // Spacer to ensure button is always visible
                                Spacer(minLength: 100)
                            }
                            .padding(.top, 20)
                        }
                        
                        // Fixed bottom button
                        VStack(spacing: 0) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            nextButton
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.black.opacity(0.3))
                        }
                    }
                }
            }
            .foregroundColor(.white)
        }
        .navigationBarHidden(true)
    }
    
    private var nextButton: some View {
        Button(action: handleNext) {
            HStack(spacing: 12) {
                if currentQuestionIndex == quiz.count - 1 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Complete Lesson")
                        .font(.system(size: 18, weight: .semibold))
                } else {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundColor(canProceed ? .black : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(canProceed ? Color.yellow : Color.gray.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(!canProceed)
        .animation(.easeInOut(duration: 0.2), value: canProceed)
    }
    
    private var canProceed: Bool {
        showFeedback
    }
    
    private func getSelectionState(for index: Int) -> SelectionState {
        guard let selectedOptionIndex = selectedOptionIndex else { return .unselected }
        
        if !showFeedback {
            return index == selectedOptionIndex ? .selected : .unselected
        }
        
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
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Show feedback after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showFeedback = true
            }
            
            if index == currentQuestion.correctIndex {
                correctAnswers += 1
                // Success haptic
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            } else {
                // Error haptic
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
    
    private func handleNext() {
        if currentQuestionIndex < quiz.count - 1 {
            currentQuestionIndex += 1
            selectedOptionIndex = nil
            showFeedback = false
        } else {
            // Check if passing score is met
            if correctAnswers >= passingScore {
                showResults = true
            } else {
                // Show failure state - could restart quiz or provide remedial content
                showResults = true
            }
        }
    }
}

// MARK: - Enhanced UI Components

private struct QuizHeader: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let correctAnswers: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress and question indicator
            HStack {
                Text("Question \(currentQuestion) of \(totalQuestions)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                // Question dots
                HStack(spacing: 6) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        Circle()
                            .fill(index < currentQuestion - 1 ? Color.green :
                                  index == currentQuestion - 1 ? Color.yellow :
                                  Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(currentQuestion) / Double(totalQuestions)), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentQuestion)
                }
            }
            .frame(height: 6)
        }
    }
}

private struct QuestionCard: View {
    let question: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

private struct FeedbackSection: View {
    let isCorrect: Bool
    let correctAnswer: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Not quite right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Spacer()
            }
            
            if !isCorrect {
                HStack(alignment: .top, spacing: 12) {
                    Text("The correct answer is:")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(correctAnswer)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Updated Selection States and Option Row

private enum SelectionState {
    case unselected, selected, correct, incorrect
}

private struct OptionRow: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let selectionState: SelectionState
    let showFeedback: Bool
    
    private var backgroundColor: Color {
        switch selectionState {
        case .correct: return .green.opacity(0.3)
        case .incorrect: return .red.opacity(0.3)
        case .selected: return .blue.opacity(0.3)
        case .unselected: return Color.white.opacity(0.1)
        }
    }
    
    private var strokeColor: Color {
        switch selectionState {
        case .correct: return .green
        case .incorrect: return .red
        case .selected: return .blue
        case .unselected: return .white.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        switch selectionState {
        case .correct, .incorrect: return 3
        case .selected: return 2
        case .unselected: return 1
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            if showFeedback {
                if selectionState == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else if selectionState == .incorrect {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(strokeColor, lineWidth: strokeWidth)
        )
        .scaleEffect(isSelected && !showFeedback ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: selectionState)
        .animation(.easeInOut(duration: 0.2), value: showFeedback)
    }
}



// MARK: - Preview

struct QuizView_Previews: PreviewProvider {
    static let sampleQuiz = [
        QuizQuestion(id: UUID(), prompt: "What was the name of the treaty that officially ended World War I?", options: ["Treaty of Versailles", "Treaty of Berlin", "Treaty of Paris", "Treaty of London"], correctIndex: 0),
        QuizQuestion(id: UUID(), prompt: "Which of these was a major feature of warfare on the Western Front?", options: ["Guerilla warfare", "Naval battles", "Trench warfare", "Aerial dogfights"], correctIndex: 2),
        QuizQuestion(id: UUID(), prompt: "What event triggered the start of World War I?", options: ["The signing of the Treaty of Versailles", "The assassination of Archduke Franz Ferdinand", "The invasion of Poland", "The sinking of the Lusitania"], correctIndex: 1)
    ]
    
    static var previews: some View {
        QuizView(quiz: sampleQuiz, onComplete: {})
    }
}
