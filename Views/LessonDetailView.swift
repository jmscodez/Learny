import SwiftUI

struct LessonDetailView: View {
    @StateObject private var viewModel: LessonDetailViewModel
    
    // This environment object will be injected from LessonMapView.
    // It's crucial for marking lessons as complete.
    @EnvironmentObject var lessonMapViewModel: LessonMapViewModel
    
    // We pass the lesson to initialize the view, but the primary source of truth
    // for dynamic data (like quiz answers) is the viewModel.
    init(lesson: Lesson) {
        // The onLessonComplete closure will be set in .onAppear
        _viewModel = StateObject(wrappedValue: LessonDetailViewModel(lesson: lesson))
    }

    var body: some View {
        ZStack {
            // Use a dark theme background
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Loop through the content blocks of the lesson
                    ForEach(viewModel.lesson.contentBlocks.indices, id: \.self) { index in
                        let block = viewModel.lesson.contentBlocks[index]
                        viewForContentBlock(block)
                            .padding(.horizontal)
                    }
                    
                    // Display the quiz if it exists
                    if !viewModel.lesson.quiz.isEmpty {
                        QuizView(
                            questions: viewModel.lesson.quiz,
                            userAnswers: $viewModel.userAnswers,
                            onSubmit: {
                                viewModel.submitQuiz()
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(viewModel.lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(.white)
        // Present the quiz results as a full-screen cover
        .fullScreenCover(isPresented: $viewModel.isQuizSubmitted) {
            QuizResultsView(
                score: viewModel.quizScore,
                total: viewModel.lesson.quiz.count,
                onDismiss: {
                    // The view model handles the completion logic,
                    // we just need to dismiss the view.
                    viewModel.isQuizSubmitted = false
                }
            )
        }
        .onAppear {
            // When the view appears, we set the completion handler on the view model.
            // This handler will call the method on the environment object from the parent view.
            viewModel.onLessonComplete = {
                lessonMapViewModel.markComplete(lesson: viewModel.lesson)
            }
        }
    }
    
    /// A helper view builder to render the correct view for each content block type.
    @ViewBuilder
    private func viewForContentBlock(_ block: ContentBlock) -> some View {
        switch block {
        case .text(let text):
            Text(text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white.opacity(0.9))
            
        case .dialogue(let lines):
            VStack(spacing: 10) {
                ForEach(lines.indices, id: \.self) { index in
                    // Use the dedicated bubble view, alternating sides
                    DialogueBubbleView(line: lines[index], isCurrentUser: index % 2 != 0)
                }
            }
            
        case .matching(let game):
            // Use the dedicated matching game view
            MatchingGameView(game: game)
        }
    }
}
 
