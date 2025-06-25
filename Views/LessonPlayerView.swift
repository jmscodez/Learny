import SwiftUI

// MARK: - Screen States
// These structs hold the state for each interactive screen type.
// They are defined at the top level to be accessible by all views in this file.
struct TapToRevealState { var isRevealed = false }
struct MultipleChoiceState { var selectedIndex: Int? = nil; var showExplanation = false }
struct TrueFalseState { var selectedAnswer: Bool? = nil; var showExplanation = false }
struct DragToOrderState { var currentOrder: [Int] = []; var isCorrect: Bool? = nil }
struct CardSortState { var cardPlacements: [UUID: Int] = [:]; var isComplete = false }
struct MatchingGameState { var selectedTermId: UUID? = nil; var matchedPairs: [UUID: UUID] = [:] }
struct QuizState { var isFinished = false }

struct LessonPlayerView: View {
    @State var lesson: Lesson
    @EnvironmentObject var lessonMapViewModel: LessonMapViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentScreenIndex = 0
    @State private var screenStates: [UUID: Any] = [:]
    @State private var showCelebration = false
    @State private var lessonCompletionProgress: Double = 0

    private var isCurrentScreenCompleted: Bool {
        guard let screen = lesson.screens[safe: currentScreenIndex] else { return false }
        
        switch screen {
        case .tapToReveal:
            return (screenStates[screen.id] as? TapToRevealState)?.isRevealed ?? false
        case .multipleChoice:
            return (screenStates[screen.id] as? MultipleChoiceState)?.showExplanation ?? false
        case .trueFalse:
            return (screenStates[screen.id] as? TrueFalseState)?.showExplanation ?? false
        case .dragToOrder:
            return (screenStates[screen.id] as? DragToOrderState)?.isCorrect ?? false
        case .cardSort:
            return (screenStates[screen.id] as? CardSortState)?.isComplete ?? false
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
    
    private var progressPercentage: Double {
        guard !lesson.screens.isEmpty else { return 0.0 }
        return Double(currentScreenIndex + 1) / Double(lesson.screens.count)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.08, green: 0.1, blue: 0.2),
                        Color(red: 0.1, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header with Progress
                    headerView
                    
                    if lesson.screens.isEmpty {
                        loadingView
                    } else {
                        // Main Content Area
                        TabView(selection: $currentScreenIndex) {
                            ForEach(lesson.screens.indices, id: \.self) { index in
                                EnhancedScreenView(
                                    screen: lesson.screens[index], 
                                    screenIndex: index,
                                    totalScreens: lesson.screens.count,
                                    state: Binding(
                                        get: { screenStates[lesson.screens[index].id] },
                                        set: { screenStates[lesson.screens[index].id] = $0 }
                                    )
                                )
                                .tag(index)
                                .id(lesson.screens[index].id)
                                .padding(.horizontal, 20)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onChange(of: currentScreenIndex) { newIndex in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                lessonCompletionProgress = Double(newIndex + 1) / Double(lesson.screens.count)
                            }
                        }
                        
                        // Enhanced Action Button
                        actionButtonView
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if lesson.screens.isEmpty {
                Task {
                    let generatedScreens = await OpenAIService.shared.generateLessonScreens(for: lesson.title, topic: lessonMapViewModel.course.topic, difficulty: lessonMapViewModel.course.difficulty, pace: lessonMapViewModel.course.pace)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.lesson.screens = generatedScreens
                    }
                }
            }
        }
        .overlay(
            // Celebration overlay
            celebrationOverlay
        )
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top Bar with Close and Navigation
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Lesson Title
                Text(lesson.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: {
                    if currentScreenIndex > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreenIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(currentScreenIndex > 0 ? .white : .gray)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(currentScreenIndex > 0 ? 0.1 : 0.05))
                        .clipShape(Circle())
                }
                .disabled(currentScreenIndex == 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Enhanced Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(currentScreenIndex + 1) of \(lesson.screens.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progressPercentage, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                        
                        // Progress indicators
                        HStack(spacing: 0) {
                            ForEach(0..<lesson.screens.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentScreenIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentScreenIndex ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: currentScreenIndex)
                                
                                if index < lesson.screens.count - 1 {
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            // Animated loading rings
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 60 + CGFloat(index * 20))
                        .rotationEffect(.degrees(Double(index * 120)))
                        .animation(
                            Animation.linear(duration: 2 + Double(index))
                                .repeatForever(autoreverses: false),
                            value: 1
                        )
                }
            }
            .frame(width: 120, height: 120)
            
            VStack(spacing: 8) {
                Text("Crafting Your Lesson")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Creating personalized content just for you...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Action Button
    private var actionButtonView: some View {
        Button(action: advanceScreen) {
            HStack {
                Text(currentScreenIndex == lesson.screens.count - 1 ? "Complete Lesson" : "Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Image(systemName: currentScreenIndex == lesson.screens.count - 1 ? "checkmark.circle.fill" : "arrow.right")
                    .font(.title2)
            }
            .foregroundColor(isCurrentScreenCompleted ? .black : .gray)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isCurrentScreenCompleted ?
                LinearGradient(
                    colors: [Color.yellow, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isCurrentScreenCompleted ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.2), value: isCurrentScreenCompleted)
            .shadow(
                color: isCurrentScreenCompleted ? Color.yellow.opacity(0.4) : Color.clear,
                radius: isCurrentScreenCompleted ? 8 : 0,
                x: 0,
                y: 4
            )
        }
        .disabled(!isCurrentScreenCompleted)
    }
    
    // MARK: - Celebration Overlay
    @ViewBuilder
    private var celebrationOverlay: some View {
        if showCelebration {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Success Animation
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(showCelebration ? 1.0 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCelebration)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(showCelebration ? 1.0 : 0.5)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showCelebration)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Lesson Complete! 🎉")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Great job! You're making excellent progress.")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showCelebration ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: showCelebration)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCelebration = false
                    }
                    lessonMapViewModel.markComplete(lesson: lesson)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func advanceScreen() {
        if currentScreenIndex < lesson.screens.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentScreenIndex += 1
            }
        } else {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showCelebration = true
            }
        }
    }
}

// MARK: - Enhanced Screen View
private struct EnhancedScreenView: View {
    let screen: LessonScreen
    let screenIndex: Int
    let totalScreens: Int
    @Binding var state: Any?
    
    var body: some View {
        ScrollView {
            VStack {
                switch screen {
                case .title(let payload):
                    EnhancedTitleScreenView(payload: payload, screenIndex: screenIndex, totalScreens: totalScreens)
                case .info(let payload):
                    EnhancedInfoScreenView(payload: payload)
                case .tapToReveal(let payload):
                    EnhancedTapToRevealScreenView(payload: payload, state: Binding(
                        get: { (state as? TapToRevealState) ?? TapToRevealState() },
                        set: { state = $0 }
                    ))
                case .multipleChoice(let payload):
                    EnhancedMultipleChoiceScreenView(payload: payload, state: Binding(
                        get: { (state as? MultipleChoiceState) ?? MultipleChoiceState() },
                        set: { state = $0 }
                    ))
                case .trueFalse(let payload):
                    EnhancedTrueFalseScreenView(payload: payload, state: Binding(
                        get: { (state as? TrueFalseState) ?? TrueFalseState() },
                        set: { state = $0 }
                    ))
                case .dragToOrder(let payload):
                    EnhancedDragToOrderScreenView(payload: payload, state: Binding(
                        get: { (state as? DragToOrderState) ?? DragToOrderState() },
                        set: { state = $0 }
                    ))
                case .cardSort(let payload):
                    EnhancedCardSortScreenView(payload: payload, state: Binding(
                        get: { (state as? CardSortState) ?? CardSortState() },
                        set: { state = $0 }
                    ))
                case .matching(let payload):
                    EnhancedMatchingGameView(payload: payload, state: Binding(
                        get: { (state as? MatchingGameState) ?? MatchingGameState() },
                        set: { state = $0 }
                    ))
                case .dialogue(let payload):
                    EnhancedDialogueScreenView(payload: payload)
                case .quiz(let payload):
                    EnhancedQuizView(quiz: payload.questions, onComplete: {
                        var quizState = (state as? QuizState) ?? QuizState()
                        quizState.isFinished = true
                        state = quizState
                    })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 24)
        }
    }
}

// MARK: - Enhanced Screen Components
private struct EnhancedTitleScreenView: View {
    let payload: TitleScreen
    let screenIndex: Int
    let totalScreens: Int
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero Section
            VStack(spacing: 16) {
                Text(payload.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                if let subtitle = payload.subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Hook section with enhanced styling
            VStack(spacing: 16) {
                Text("💡")
                    .font(.system(size: 48))
                
                Text(payload.hook)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
        }
    }
}

private struct EnhancedInfoScreenView: View {
    let payload: InfoScreen
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerIcon
                contentSection
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
            
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.yellow)
        }
        .padding(.top, 20)
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            mainContent
            decorativeElements
            callToAction
        }
    }
    
    private var mainContent: some View {
        Text(payload.text)
            .font(.title3)
            .fontWeight(.regular)
            .lineSpacing(12)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .background(contentBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var contentBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private var decorativeElements: some View {
        HStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                
                if index < 2 {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 30, height: 2)
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    private var callToAction: some View {
        HStack {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Tap continue when ready")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 10)
    }
}

private struct EnhancedTapToRevealScreenView: View {
    let payload: TapToRevealScreen
    @Binding var state: TapToRevealState
    
    var body: some View {
        VStack(spacing: 24) {
            // Question
            Text(payload.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            Spacer()
            
            // Tap to reveal card
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    state.isRevealed = true
                }
            }) {
                VStack(spacing: 16) {
                    if state.isRevealed {
                        Text(payload.answer)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    } else {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Tap to reveal")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(
                    state.isRevealed ?
                    LinearGradient(
                        colors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(state.isRevealed ? 1.02 : 1.0)
                .shadow(
                    color: state.isRevealed ? Color.green.opacity(0.3) : Color.clear,
                    radius: state.isRevealed ? 8 : 0,
                    x: 0,
                    y: 4
                )
            }
            .disabled(state.isRevealed)
            
            Spacer()
        }
    }
}

private struct EnhancedMultipleChoiceScreenView: View {
    let payload: MultipleChoiceScreen
    @Binding var state: MultipleChoiceState
    
    var body: some View {
        VStack(spacing: 24) {
            // Question
            Text(payload.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            Spacer()
            
            // Multiple choice options
            VStack(spacing: 12) {
                ForEach(payload.options.indices, id: \.self) { index in
                    Button(action: {
                        state.selectedIndex = index
                    }) {
                        HStack {
                            Text(payload.options[index])
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if state.selectedIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    state.selectedIndex == index ?
                                    Color.blue.opacity(0.2) :
                                    Color.white.opacity(0.05)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            state.selectedIndex == index ?
                                            Color.blue :
                                            Color.white.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
            }
            
            // Submit button
            Button(action: {
                state.showExplanation = true
            }) {
                Text("Submit")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(state.selectedIndex == nil)
            
            // Feedback
            if let selectedIndex = state.selectedIndex {
                Text(payload.options[selectedIndex])
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            Spacer()
        }
    }
}

private struct EnhancedTrueFalseScreenView: View {
    let payload: TrueFalseScreen
    @Binding var state: TrueFalseState
    
    var body: some View {
        VStack(spacing: 24) {
            // Statement
            Text(payload.statement)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            Spacer()
            
            // True/False options
            HStack(spacing: 20) {
                Button(action: {
                    state.selectedAnswer = true
                    state.showExplanation = true
                }) {
                    VStack {
                        Text("TRUE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        state.selectedAnswer == true ?
                        Color.green.opacity(0.3) :
                        Color.white.opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Button(action: {
                    state.selectedAnswer = false
                    state.showExplanation = true
                }) {
                    VStack {
                        Text("FALSE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        state.selectedAnswer == false ?
                        Color.red.opacity(0.3) :
                        Color.white.opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            
            // Explanation
            if state.showExplanation {
                VStack(spacing: 12) {
                    let isCorrect = state.selectedAnswer == payload.isTrue
                    
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Text(isCorrect ? "Correct!" : "Incorrect")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((isCorrect ? Color.green : Color.red).opacity(0.1))
                    )
                    
                    Text(payload.explanation)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            
            Spacer()
        }
    }
}

private struct EnhancedDragToOrderScreenView: View {
    let payload: DragToOrderScreen
    @Binding var state: DragToOrderState
    
    @State private var draggedItem: Int?
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        VStack(spacing: 24) {
            instructionView
            Spacer()
            helpText
            initializeOrderIfNeeded
            draggableOrderingInterface
            Spacer()
            checkOrderButton
            feedbackView
            Spacer()
        }
    }
    
    private var instructionView: some View {
        Text(payload.instruction)
            .font(.title2)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
    }
    
    private var helpText: some View {
        Text("Drag to reorder the items chronologically")
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
    }
    
    @ViewBuilder
    private var initializeOrderIfNeeded: some View {
        if state.currentOrder.isEmpty {
            let _ = DispatchQueue.main.async {
                state.currentOrder = Array(0..<payload.items.count)
            }
        }
    }
    
    private var draggableOrderingInterface: some View {
        VStack(spacing: 16) {
            ForEach(state.currentOrder.indices, id: \.self) { position in
                dragItemRow(position: position)
            }
        }
    }
    
    private func dragItemRow(position: Int) -> some View {
        let itemIndex = state.currentOrder[position]
        let isDragging = draggedItem == itemIndex
        
        return HStack(spacing: 16) {
            positionNumberView(position: position)
            itemContentView(itemIndex: itemIndex)
            dragHandleView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(dragItemBackground(isDragging: isDragging))
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .shadow(color: isDragging ? Color.blue.opacity(0.3) : Color.clear, radius: isDragging ? 8 : 0)
        .offset(y: isDragging ? dragOffset.height : 0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .zIndex(isDragging ? 1 : 0)
        .gesture(createDragGesture(itemIndex: itemIndex, position: position))
    }
    
    private func positionNumberView(position: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 32, height: 32)
            
            Text("\(position + 1)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private func itemContentView(itemIndex: Int) -> some View {
        Text(payload.items[itemIndex])
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dragHandleView: some View {
        Image(systemName: "line.horizontal.3")
            .font(.body)
            .foregroundColor(.white.opacity(0.6))
    }
    
    private var checkOrderButton: some View {
        Button(action: {
            state.isCorrect = state.currentOrder == payload.correctOrder
        }) {
            Text("Check Order")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(checkOrderButtonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.yellow.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
    
    private var checkOrderButtonBackground: some View {
        LinearGradient(
            colors: [Color.yellow, Color.orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    @ViewBuilder
    private var feedbackView: some View {
        if let isCorrect = state.isCorrect {
            feedbackContent(isCorrect: isCorrect)
        }
    }
    
    private func feedbackContent(isCorrect: Bool) -> some View {
        VStack(spacing: 12) {
            feedbackHeader(isCorrect: isCorrect)
            
            if !isCorrect {
                resetOrderButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(feedbackBackground(isCorrect: isCorrect))
    }
    
    private func feedbackHeader(isCorrect: Bool) -> some View {
        HStack {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(isCorrect ? .green : .red)
            
            Text(isCorrect ? "Perfect order! 🎉" : "Not quite right. Try again!")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isCorrect ? .green : .red)
            
            Spacer()
        }
    }
    
    private var resetOrderButton: some View {
        Button("Reset Order") {
            withAnimation(.easeInOut(duration: 0.5)) {
                state.currentOrder = Array(0..<payload.items.count)
                state.isCorrect = nil
            }
        }
        .font(.body)
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(resetOrderButtonBackground)
    }
    
    private var resetOrderButtonBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    private func feedbackBackground(isCorrect: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill((isCorrect ? Color.green : Color.red).opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCorrect ? Color.green : Color.red, lineWidth: 1)
            )
    }
    
    private func dragItemBackground(isDragging: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isDragging ? Color.blue.opacity(0.4) : Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDragging ? Color.blue : Color.white.opacity(0.2), lineWidth: isDragging ? 2 : 1)
            )
    }
    
    private func createDragGesture(itemIndex: Int, position: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if draggedItem == nil {
                    draggedItem = itemIndex
                }
                dragOffset = value.translation
            }
            .onEnded { value in
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Calculate where to drop the item based on drag distance
                    let dragDistance = value.translation.height
                    let itemHeight: CGFloat = 70 // Approximate height of each item
                    let targetPosition = max(0, min(state.currentOrder.count - 1, position + Int(dragDistance / itemHeight)))
                    
                    // Reorder the array
                    if targetPosition != position {
                        let item = state.currentOrder.remove(at: position)
                        state.currentOrder.insert(item, at: targetPosition)
                    }
                    
                    draggedItem = nil
                    dragOffset = .zero
                }
            }
    }
}

private struct EnhancedCardSortScreenView: View {
    let payload: CardSortScreen
    @Binding var state: CardSortState
    
    var body: some View {
        VStack(spacing: 24) {
            instructionText
            Spacer()
            categoriesSection
            availableCardsSection
            Spacer()
        }
        .onAppear {
            checkCompletion()
        }
    }
    
    private var instructionText: some View {
        Text(payload.instruction)
            .font(.title2)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
    }
    
    private var categoriesSection: some View {
        VStack(spacing: 16) {
            ForEach(payload.categories.indices, id: \.self) { categoryIndex in
                categoryView(categoryIndex: categoryIndex)
            }
        }
    }
    
    private func categoryView(categoryIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(payload.categories[categoryIndex])
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            cardsInCategory(categoryIndex: categoryIndex)
            dropZone
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func cardsInCategory(categoryIndex: Int) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(payload.cards.filter { card in
                state.cardPlacements[card.id] == categoryIndex
            }, id: \.id) { card in
                Text(card.text)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
    
    private var dropZone: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(height: 60)
            .overlay(
                Text("Drop cards here")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            )
    }
    
    @ViewBuilder
    private var availableCardsSection: some View {
        if !payload.cards.allSatisfy({ state.cardPlacements[$0.id] != nil }) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cards to Sort:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                availableCardsGrid
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var availableCardsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(payload.cards.filter { card in
                state.cardPlacements[card.id] == nil
            }, id: \.id) { card in
                Button(action: {
                    state.cardPlacements[card.id] = 0
                }) {
                    Text(card.text)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }
    
    private func checkCompletion() {
        if payload.cards.allSatisfy({ state.cardPlacements[$0.id] != nil }) {
            state.isComplete = true
        }
    }
}

// Continue with other enhanced views...
private struct EnhancedMatchingGameView: View {
    let payload: MatchingGame
    @Binding var state: MatchingGameState
    
    @State private var draggedItem: UUID? = nil
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            matchingPairs
            if state.matchedPairs.count == payload.pairs.count {
                successFeedback
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }
    
    private var headerView: some View {
        Text("Match the terms with their definitions")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
    
    private var matchingPairs: some View {
        VStack(spacing: 20) {
            ForEach(payload.pairs, id: \.id) { pair in
                matchingPairRow(for: pair)
            }
        }
    }
    
    private func matchingPairRow(for pair: MatchingPair) -> some View {
        let isMatched = state.matchedPairs[pair.id] != nil
        
        return HStack(spacing: 16) {
            termView(for: pair, isMatched: isMatched)
            connectionLine(isMatched: isMatched)
            definitionView(for: pair, isMatched: isMatched)
        }
    }
    
    private func termView(for pair: MatchingPair, isMatched: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isMatched ? 
                      LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .leading, endPoint: .trailing) :
                      LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isMatched ? Color.green : Color.blue, lineWidth: 2)
                )
                .scaleEffect(isMatched ? 1.05 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isMatched)
            
            Text(pair.term)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
        }
        .frame(width: 140, height: 80)
        .onDrop(of: [.text], delegate: TermDropDelegate(
            termId: pair.id,
            matchedPairs: $state.matchedPairs,
            correctPairs: Dictionary(uniqueKeysWithValues: payload.pairs.map { ($0.id, $0.id) })
        ))
    }
    
    private func connectionLine(isMatched: Bool) -> some View {
        if isMatched {
            return AnyView(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 20))
                    path.addLine(to: CGPoint(x: 60, y: 20))
                }
                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 60, height: 40)
                .animation(.easeInOut(duration: 0.5), value: isMatched)
            )
        } else {
            return AnyView(
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 2)
                    .frame(height: 40)
            )
        }
    }
    
    private func definitionView(for pair: MatchingPair, isMatched: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isMatched ? 
                      LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .leading, endPoint: .trailing) :
                      LinearGradient(colors: [.purple.opacity(0.3), .purple.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isMatched ? Color.green : Color.purple, lineWidth: 2)
                )
                .scaleEffect(draggedItem == pair.id ? 1.1 : (isMatched ? 1.05 : 1.0))
                .rotationEffect(.degrees(draggedItem == pair.id ? 5 : 0))
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: draggedItem == pair.id)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isMatched)
            
            Text(pair.definition)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .lineLimit(4)
        }
        .frame(width: 140, height: 80)
        .offset(draggedItem == pair.id ? dragOffset : .zero)
        .opacity(isMatched ? 0.7 : 1.0)
        .disabled(isMatched)
        .onDrag {
            draggedItem = pair.id
            return NSItemProvider(object: pair.id.uuidString as NSString)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if draggedItem == pair.id {
                        dragOffset = value.translation
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        dragOffset = .zero
                        draggedItem = nil
                    }
                }
        )
    }
    
    private var successFeedback: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
                .scaleEffect(1.2)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: state.matchedPairs.count)
            
            Text("Perfect! All matches complete! 🎉")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green, lineWidth: 2)
                )
        )
    }
}

struct TermDropDelegate: DropDelegate {
    let termId: UUID
    @Binding var matchedPairs: [UUID: UUID]
    let correctPairs: [UUID: UUID]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadItem(forTypeIdentifier: "public.text") { (data, error) in
            if let data = data as? Data,
               let uuidString = String(data: data, encoding: .utf8),
               let droppedId = UUID(uuidString: uuidString) {
                
                DispatchQueue.main.async {
                    // Check if this is a correct match
                    if droppedId == termId {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            matchedPairs[termId] = droppedId
                        }
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                }
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Visual feedback when hovering over a valid drop target
    }
}

private struct EnhancedDialogueScreenView: View {
    let payload: DialogueScreen
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(payload.lines.indices, id: \.self) { index in
                let line = payload.lines[index]
                
                HStack {
                    if index % 2 == 0 {
                        VStack(alignment: .leading, spacing: 4) {
                                                         Text(line.speaker)
                                 .font(.caption)
                                 .fontWeight(.semibold)
                                 .foregroundColor(.blue.opacity(0.8))
                             
                             Text(line.text)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Spacer()
                    } else {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                                                         Text(line.speaker)
                                 .font(.caption)
                                 .fontWeight(.semibold)
                                 .foregroundColor(.purple.opacity(0.8))
                             
                             Text(line.text)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.purple.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }
        }
    }
}

private struct EnhancedQuizView: View {
    let quiz: [QuizQuestion]
    let onComplete: () -> Void
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int?] = []
    @State private var answeredQuestions: Set<Int> = []
    @State private var showResults = false
    @State private var showQuestionFeedback = false
    
    private var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < quiz.count else { return nil }
        return quiz[currentQuestionIndex]
    }
    
    private var correctAnswersCount: Int {
        var correct = 0
        for (index, selectedAnswer) in selectedAnswers.enumerated() {
            if let selected = selectedAnswer, selected == quiz[index].correctIndex {
                correct += 1
            }
        }
        return correct
    }
    
    private var isPassing: Bool {
        correctAnswersCount >= 4 // Need 4 out of 5 to pass
    }
    
    init(quiz: [QuizQuestion], onComplete: @escaping () -> Void) {
        self.quiz = quiz
        self.onComplete = onComplete
        _selectedAnswers = State(initialValue: Array(repeating: nil, count: quiz.count))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if !showResults {
                // Quiz Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Question \(currentQuestionIndex + 1) of \(quiz.count)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        // Score indicator
                        HStack(spacing: 4) {
                            ForEach(0..<quiz.count, id: \.self) { index in
                                Circle()
                                    .fill(getScoreIndicatorColor(for: index))
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * (Double(currentQuestionIndex + 1) / Double(quiz.count)), height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                }
                
                if let question = currentQuestion {
                    VStack(spacing: 24) {
                        // Question
                        Text(question.prompt)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        // Answer options
                        VStack(spacing: 12) {
                            ForEach(question.options.indices, id: \.self) { index in
                                let isSelected = selectedAnswers[currentQuestionIndex] == index
                                let isAnswered = answeredQuestions.contains(currentQuestionIndex)
                                let isCorrect = index == question.correctIndex
                                
                                Button(action: {
                                    if !isAnswered {
                                        selectedAnswers[currentQuestionIndex] = index
                                        answeredQuestions.insert(currentQuestionIndex)
                                        showQuestionFeedback = true
                                    }
                                }) {
                                    HStack {
                                        Text(question.options[index])
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if isAnswered {
                                            if isSelected {
                                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(isCorrect ? .green : .red)
                                            } else if isCorrect {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.green)
                                            }
                                        } else if isSelected {
                                            Image(systemName: "circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(getButtonBackgroundColor(isAnswered: isAnswered, isSelected: isSelected, isCorrect: isCorrect))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(getButtonBorderColor(isAnswered: isAnswered, isSelected: isSelected, isCorrect: isCorrect), lineWidth: 2)
                                            )
                                    )
                                    .scaleEffect(isSelected && !isAnswered ? 1.02 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                                }
                                .disabled(isAnswered)
                            }
                        }
                        
                        // Immediate feedback after answering
                        if showQuestionFeedback && answeredQuestions.contains(currentQuestionIndex) {
                            let isCorrect = selectedAnswers[currentQuestionIndex] == question.correctIndex
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(isCorrect ? .green : .red)
                                    
                                    Text(isCorrect ? "Correct! 🎉" : "Not quite right")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(isCorrect ? .green : .red)
                                    
                                    Spacer()
                                }
                                
                                if !isCorrect {
                                    Text("The correct answer is: \(question.options[question.correctIndex])")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill((isCorrect ? Color.green : Color.red).opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isCorrect ? Color.green : Color.red, lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Next/Finish button
                        if answeredQuestions.contains(currentQuestionIndex) {
                            Button(action: nextQuestion) {
                                HStack {
                                    Text(currentQuestionIndex == quiz.count - 1 ? "See Results" : "Next Question")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: currentQuestionIndex == quiz.count - 1 ? "flag.checkered" : "arrow.right")
                                        .font(.title3)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.yellow.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                }
            } else {
                // Results view
                VStack(spacing: 24) {
                    // Results header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isPassing ? [.green, .blue] : [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: isPassing ? "trophy.fill" : "exclamationmark.triangle.fill")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(isPassing ? "Quiz Passed! 🎉" : "Quiz Failed")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(isPassing ? .green : .orange)
                            
                            Text("You scored \(correctAnswersCount) out of \(quiz.count)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(isPassing ? "Great job! You can continue." : "You need 4 out of 5 to pass. Try again!")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Score breakdown
                    VStack(spacing: 12) {
                        Text("Question Results:")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            ForEach(0..<quiz.count, id: \.self) { index in
                                let isCorrect = selectedAnswers[index] == quiz[index].correctIndex
                                
                                HStack {
                                    Text("Question \(index + 1)")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isCorrect ? .green : .red)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    if !isPassing {
                        Button(action: retakeQuiz) {
                            Text("Retake Quiz")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .onAppear {
            if showResults && isPassing {
                onComplete()
            }
        }
    }
    
    private func nextQuestion() {
        showQuestionFeedback = false
        
        if currentQuestionIndex < quiz.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                showResults = true
            }
            if isPassing {
                onComplete()
            }
        }
    }
    
    private func retakeQuiz() {
        currentQuestionIndex = 0
        selectedAnswers = Array(repeating: nil, count: quiz.count)
        answeredQuestions.removeAll()
        showResults = false
        showQuestionFeedback = false
    }
    
    private func getButtonBackgroundColor(isAnswered: Bool, isSelected: Bool, isCorrect: Bool) -> Color {
        if isAnswered {
            if isSelected {
                return isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
            } else {
                return isCorrect ? Color.green.opacity(0.2) : Color.white.opacity(0.05)
            }
        } else {
            return isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05)
        }
    }
    
    private func getButtonBorderColor(isAnswered: Bool, isSelected: Bool, isCorrect: Bool) -> Color {
        if isAnswered {
            if isSelected {
                return isCorrect ? Color.green : Color.red
            } else {
                return isCorrect ? Color.green : Color.white.opacity(0.2)
            }
        } else {
            return isSelected ? Color.blue : Color.white.opacity(0.2)
        }
    }
    
    private func getScoreIndicatorColor(for index: Int) -> Color {
        if answeredQuestions.contains(index) {
            if selectedAnswers[index] == quiz[index].correctIndex {
                return Color.green
            } else {
                return Color.red
            }
        } else {
            return Color.white.opacity(0.3)
        }
    }
}

// MARK: - Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 