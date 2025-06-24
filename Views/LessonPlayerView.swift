import SwiftUI

// MARK: - Screen States
// These structs hold the state for each interactive screen type.
// They are defined at the top level to be accessible by all views in this file.
struct TapToRevealState { var isRevealed = false }
struct FillInTheBlankState { var submission: String = ""; var isCorrect: Bool?; var isRevealed = false }
struct MatchingGameState { var selectedTermId: UUID? = nil; var matchedPairs: [UUID: UUID] = [:] }
struct QuizState { var isFinished = false }

struct LessonPlayerView: View {
    @State var lesson: Lesson
    @EnvironmentObject var lessonMapViewModel: LessonMapViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentScreenIndex = 0
    @State private var screenStates: [UUID: Any] = [:]

    private var isCurrentScreenCompleted: Bool {
        guard let screen = lesson.screens[safe: currentScreenIndex] else { return false }
        
        switch screen {
        case .tapToReveal:
            return (screenStates[screen.id] as? TapToRevealState)?.isRevealed ?? false
        case .fillInTheBlank:
            return (screenStates[screen.id] as? FillInTheBlankState)?.isCorrect ?? false
        case .matching:
            guard let state = screenStates[screen.id] as? MatchingGameState,
                  case .matching(let payload) = screen else { return false }
            return state.matchedPairs.count == payload.pairs.count
        case .quiz:
            return (screenStates[screen.id] as? QuizState)?.isFinished ?? false
        default:
            return true
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

            VStack {
                if lesson.screens.isEmpty {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Building your lesson...")
                        .foregroundColor(.white)
                        .padding()
                } else {
                    ProgressBar(value: Double(currentScreenIndex), maxValue: Double(lesson.screens.count))
                        .padding()

                    TabView(selection: $currentScreenIndex) {
                        ForEach(lesson.screens.indices, id: \.self) { index in
                            ScreenView(screen: lesson.screens[index], state: Binding(
                                get: { screenStates[lesson.screens[index].id] },
                                set: { screenStates[lesson.screens[index].id] = $0 }
                            ))
                            .tag(index)
                            .id(lesson.screens[index].id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    Button(action: advanceScreen) {
                        Text(currentScreenIndex == lesson.screens.count - 1 ? "Finish Lesson" : "Continue")
                            .foregroundColor(isCurrentScreenCompleted ? .black : .gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isCurrentScreenCompleted ? Color.yellow : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                    .disabled(!isCurrentScreenCompleted)
                    .padding()
                }
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark").foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    if currentScreenIndex > 0 {
                        withAnimation {
                            currentScreenIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "arrow.left").foregroundColor(.white)
                }
                .disabled(currentScreenIndex == 0)
            }
        }
        .onAppear {
            if lesson.screens.isEmpty {
                Task {
                    let generatedScreens = await OpenAIService.shared.generateLessonScreens(for: lesson.title, topic: lessonMapViewModel.course.topic)
                    self.lesson.screens = generatedScreens
                }
            }
        }
    }

    private func advanceScreen() {
        if currentScreenIndex < lesson.screens.count - 1 {
            withAnimation {
                currentScreenIndex += 1
            }
        } else {
            lessonMapViewModel.markComplete(lesson: lesson)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

private struct ScreenView: View {
    let screen: LessonScreen
    @Binding var state: Any?

    var body: some View {
        VStack {
            switch screen {
            case .title(let payload):
                TitleScreenView(payload: payload)
            case .info(let payload):
                InfoScreenView(payload: payload)
            case .tapToReveal(let payload):
                TapToRevealScreenView(payload: payload, state: Binding(
                    get: { (state as? TapToRevealState) ?? TapToRevealState() },
                    set: { state = $0 }
                ))
            case .fillInTheBlank(let payload):
                FillInTheBlankScreenView(payload: payload, state: Binding(
                    get: { (state as? FillInTheBlankState) ?? FillInTheBlankState() },
                    set: { state = $0 }
                ))
            case .matching(let payload):
                MatchingGameView(payload: payload, state: Binding(
                    get: { (state as? MatchingGameState) ?? MatchingGameState() },
                    set: { state = $0 }
                ))
            case .dialogue(let payload):
                DialogueScreenView(payload: payload)
            case .quiz(let payload):
                QuizView(quiz: payload.questions, onComplete: {
                    var quizState = (state as? QuizState) ?? QuizState()
                    quizState.isFinished = true
                    state = quizState
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct TitleScreenView: View {
    let payload: TitleScreen
    
    var body: some View {
        VStack(spacing: 20) {
            Text(payload.title)
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            if let subtitle = payload.subtitle {
                Text(subtitle)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(payload.hook)
                .font(.title2)
                .italic()
                .multilineTextAlignment(.center)
            Spacer()
        }
        .foregroundColor(.white)
    }
}

private struct InfoScreenView: View {
    let payload: InfoScreen
    
    var body: some View {
        ScrollView {
            Text(payload.text)
                .font(.title3)
                .lineSpacing(8)
        }
        .foregroundColor(.white)
    }
}

private struct TapToRevealScreenView: View {
    let payload: TapToRevealScreen
    @Binding var state: TapToRevealState
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                CardView(text: payload.answer, color: .green)
                    .opacity(state.isRevealed ? 1 : 0)
                    .rotation3DEffect(.degrees(state.isRevealed ? 0 : 180), axis: (x: 0, y: 1, z: 0))

                CardView(text: payload.question, color: .blue)
                    .opacity(state.isRevealed ? 0 : 1)
                    .rotation3DEffect(.degrees(state.isRevealed ? -180 : 0), axis: (x: 0, y: 1, z: 0))
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    state.isRevealed = true
                }
            }
            Spacer()
        }
    }
    
    private struct CardView: View {
        let text: String
        let color: Color
        
        var body: some View {
            VStack {
                Text(text)
                    .font(.title2).bold()
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(color.opacity(0.3))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(color, lineWidth: 2))
            .foregroundColor(.white)
        }
    }
}

private struct FillInTheBlankScreenView: View {
    let payload: FillInTheBlankScreen
    @Binding var state: FillInTheBlankState
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(payload.promptStart).font(.title2)

                if state.isRevealed {
                    Text(payload.correctAnswer)
                        .font(.title2).bold()
                        .foregroundColor(.yellow)
                } else {
                    TextField("type here", text: $state.submission, onCommit: checkAnswer)
                        .font(.title2)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .disabled(state.isCorrect == true)
                }

                Text(payload.promptEnd).font(.title2)
            }
            .multilineTextAlignment(.center)
            
            if let isCorrect = state.isCorrect {
                if isCorrect {
                    Text("Correct!").foregroundColor(.green).font(.headline)
                } else {
                    Text("Not quite!").foregroundColor(.red).font(.headline)
                    HStack(spacing: 20) {
                        Button("Try Again") {
                            state.submission = ""
                            state.isCorrect = nil
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Show Answer") {
                            state.isRevealed = true
                            state.isCorrect = true // Mark as complete
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .foregroundColor(.white)
        .padding()
    }
    
    private func checkAnswer() {
        state.isCorrect = state.submission.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == payload.correctAnswer.lowercased()
    }
}

private struct DialogueScreenView: View {
    let payload: DialogueScreen
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(payload.lines.indices, id: \.self) { index in
                    DialogueBubbleView(line: payload.lines[index], isCurrentUser: index % 2 != 0)
                }
            }
        }
    }
}

struct ProgressBar: View {
    var value: Double
    var maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().frame(width: geometry.size.width, height: 10)
                    .foregroundColor(Color.gray.opacity(0.5))
                
                Capsule().frame(width: geometry.size.width * CGFloat(value / maxValue), height: 10)
                    .foregroundColor(.yellow)
                    .animation(.spring(), value: value)
            }
        }
        .frame(height: 10)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 