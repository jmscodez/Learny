//
//  CourseChatSetupView.swift
//  Learny
//

import SwiftUI

extension ChatMessage.ContentType {
    var isBubble: Bool {
        switch self {
        case .text, .lessonSuggestions, .infoText, .inlineLessonSuggestions: return true
        default: return false
        }
    }
}

struct CourseChatSetupView: View {
    @StateObject private var viewModel: CourseChatViewModel
    @State private var userInput: String = ""
    @State private var isFinalizing = false
    @State private var generatedCourse: Course? = nil
    
    @AppStorage("hasSeenAIWalkthrough") var hasSeenAIWalkthrough: Bool = false
    @State private var showWalkthrough: Bool = false
    
    // Holds the suggestion for the info sheet
    @State private var suggestionForDetail: LessonSuggestion?
    
    init(topic: String) {
        _viewModel = StateObject(wrappedValue: CourseChatViewModel(topic: topic))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView(
                    selectedCount: viewModel.selectedLessons.count,
                    onGenerate: {
                        viewModel.validateAndProceed { shouldFinalize in
                            if shouldFinalize {
                                isFinalizing = true
                            }
                        }
                    }
                )
                
                if viewModel.canShowSuggestions {
                    CurrentLessonsView(lessons: viewModel.selectedLessons)
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                MessageView(
                                    message: message,
                                    lessonSuggestions: viewModel.lessonSuggestions,
                                    swappingLessonID: viewModel.swappingLessonID,
                                    onOptionSelected: viewModel.selectLessonCount,
                                    onToggleLesson: viewModel.toggleLessonSelection,
                                    onGenerateMore: viewModel.generateMoreSuggestions,
                                    onClarificationResponse: viewModel.handleClarificationResponse,
                                    onShowSuggestionInfo: { suggestion in
                                        self.suggestionForDetail = suggestion
                                    },
                                    onSwapSuggestion: viewModel.swapSuggestion,
                                    onRetry: {
                                        Task {
                                            await viewModel.generateAndDisplayInitialSuggestions()
                                        }
                                    }
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages) { _ in
                        guard let last = viewModel.messages.last else { return }
                        // Only auto-scroll for single-bubble updates (e.g., text messages) so the user can read large suggestion blocks.
                        switch last.content {
                        case .text, .thinkingIndicator, .descriptiveLoading, .lessonCountOptions, .clarificationOptions, .infoText, .generateMoreIdeasButton, .finalPrompt:
                            withAnimation(.spring()) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        default:
                            break
                        }
                    }
                }
                
                InputBarView(userInput: $userInput) {
                    viewModel.addUserMessage(userInput)
                    userInput = ""
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .sheet(isPresented: $isFinalizing) {
            FinalizeCourseView(
                lessons: viewModel.selectedLessons.sorted { $0.title < $1.title },
                topic: viewModel.topic,
                onComplete: { course in
                    // Close finalize sheet and show course map
                    isFinalizing = false
                    generatedCourse = course
                }
            )
        }
        .sheet(item: $suggestionForDetail) { suggestion in
            NavigationView {
                LessonChatView(lesson: suggestion)
            }
        }
        .fullScreenCover(item: $generatedCourse) { course in
            LessonMapView(course: course)
                .environmentObject(LearningStatsManager()) // or use same stats
                .environmentObject(StreakManager())
                .environmentObject(TrophyManager())
                .environmentObject(NotificationsManager())
                .environmentObject(UserPreferencesManager())
        }
        .onAppear {
            if !hasSeenAIWalkthrough {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showWalkthrough = true
                    }
                }
            }
        }
        .overlay(
            VStack {
                if showWalkthrough {
                    AIWalkthroughView(isPresented: $showWalkthrough)
                }
            }
        )
    }
    
    
    // MARK: - Subviews
    private struct HeaderView: View {
        @Environment(\.presentationMode) var presentationMode
        let selectedCount: Int
        let onGenerate: () -> Void
        
        private var canGenerate: Bool { selectedCount > 0 }
        
        var body: some View {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark").font(.headline)
                }
                Spacer()
                Text("Create with AI").font(.headline)
                Spacer()
                Button(action: onGenerate) {
                    Text("Generate")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(canGenerate ? Color.purple : Color.gray.opacity(0.5))
                        .clipShape(Capsule())
                }
                .disabled(!canGenerate)
            }
            .padding()
            .background(Color(white: 0.05))
            .foregroundColor(.white)
        }
    }
    
    private struct CurrentLessonsView: View {
        let lessons: [LessonSuggestion]
        
        var body: some View {
            DisclosureGroup("Current Lessons (\(lessons.count))") {
                if lessons.isEmpty {
                    Text("Select lessons below to add them to your course.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(lessons.sorted { $0.title < $1.title }) { lesson in
                            Text("• \(lesson.title)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .background(Color(white: 0.1))
            .foregroundColor(.white)
        }
    }
    
    private struct MessageView: View {
        let message: ChatMessage
        let lessonSuggestions: [LessonSuggestion]
        let swappingLessonID: UUID?
        let onOptionSelected: (String) -> Void
        let onToggleLesson: (UUID) -> Void
        let onGenerateMore: () -> Void
        let onClarificationResponse: (String, String) -> Void
        let onShowSuggestionInfo: (LessonSuggestion) -> Void
        let onSwapSuggestion: (LessonSuggestion) -> Void
        let onRetry: () -> Void
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                if message.role == .assistant {
                    Image(systemName: "sparkle")
                        .font(.title)
                        .foregroundColor(.cyan)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        switch message.content {
                        case .text(let text), .infoText(let text):
                            TextBubble(text: text)
                        case .lessonSuggestions:
                            LessonSuggestionsView(
                                suggestions: lessonSuggestions,
                                swappingLessonID: swappingLessonID,
                                onToggleLesson: onToggleLesson,
                                onShowInfo: onShowSuggestionInfo,
                                onSwap: onSwapSuggestion
                            )
                        case .lessonCountOptions:
                            VStack(alignment: .leading, spacing: 12) {
                                TextBubble(text: "To start, about how many lessons should we create for your course?")
                                LessonCountOptionsView(onOptionSelected: onOptionSelected)
                            }
                        case .thinkingIndicator:
                            ThinkingIndicatorView()
                        case .descriptiveLoading(let text):
                            DescriptiveLoadingView(text: text)
                        case .inlineLessonSuggestions(let suggestionIDs):
                            let suggestions = lessonSuggestions.filter { suggestionIDs.contains($0.id) }
                            LessonSuggestionsView(
                                suggestions: suggestions,
                                swappingLessonID: swappingLessonID,
                                onToggleLesson: onToggleLesson,
                                onShowInfo: onShowSuggestionInfo,
                                onSwap: onSwapSuggestion
                            )
                        case .clarificationOptions(let originalQuery, let options):
                            ClarificationOptionsView(originalQuery: originalQuery, options: options, onResponse: onClarificationResponse)
                        case .finalPrompt:
                            FinalPromptView()
                        case .generateMoreIdeasButton:
                            GenerateMoreButtonView(onGenerate: onGenerateMore)
                        case .aiError(let message):
                            ErrorBubbleView(message: message, onRetry: onRetry)
                        }
                    }
                } else { // User role
                    Spacer()
                    if case .text(let text) = message.content {
                        Text(text)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    private struct FinalPromptView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Now, let's customize!")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text("You can type your own ideas in the chat below, or ask me to generate more suggestions.")
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private struct LessonCountOptionsView: View {
        let options: [String] = ["3-5 lessons", "5-10 lessons", "10-20 lessons", "20-30 lessons"]
        let icons: [String] = ["leaf.fill", "book.fill", "books.vertical.fill", "square.stack.3d.up.fill"]
        let colors: [Color] = [.green, .blue, .purple, .orange]
        
        let onOptionSelected: (String) -> Void
        
        var body: some View {
            VStack(spacing: 12) {
                ForEach(Array(zip(options, zip(icons, colors))), id: \.0) { option, details in
                    Button(action: { onOptionSelected(option) }) {
                        HStack {
                            Image(systemName: details.0)
                            Text(option)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(details.1.opacity(0.5))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private struct LessonSuggestionsView: View {
        let suggestions: [LessonSuggestion]
        let swappingLessonID: UUID?
        let onToggleLesson: (UUID) -> Void
        let onShowInfo: (LessonSuggestion) -> Void
        let onSwap: (LessonSuggestion) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Here are some initial lesson ideas:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(suggestions) { suggestion in
                    LessonSuggestionRow(
                        suggestion: suggestion,
                        isSwapping: swappingLessonID == suggestion.id,
                        onToggle: onToggleLesson,
                        onShowInfo: onShowInfo,
                        onSwap: onSwap
                    )
                }
            }
        }
    }
    
    private struct LessonSuggestionRow: View {
        let suggestion: LessonSuggestion
        let isSwapping: Bool
        let onToggle: (UUID) -> Void
        let onShowInfo: (LessonSuggestion) -> Void
        let onSwap: (LessonSuggestion) -> Void
        @State private var isInfoButtonPressed = false
        @State private var isSwapButtonPressed = false
        
        var body: some View {
            Button(action: { onToggle(suggestion.id) }) {
                HStack(spacing: 12) {
                    // Title and Description
                    VStack(alignment: .leading, spacing: 5) {
                        Text(suggestion.title)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if isSwapping {
                        ProgressView()
                            .tint(.orange)
                            .padding(.horizontal, 20)
                    } else {
                        // Swap Button
                        Button(action: { onSwap(suggestion) }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title3)
                                .foregroundColor(.orange)
                                .padding(8)
                                .background(Color.orange.opacity(isSwapButtonPressed ? 0.3 : 0))
                                .clipShape(Circle())
                        }
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isSwapButtonPressed = pressing
                            }
                        }, perform: {})

                        // Info Button
                        Button(action: { onShowInfo(suggestion) }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.cyan)
                                .padding(8)
                                .background(Color.blue.opacity(isInfoButtonPressed ? 0.3 : 0))
                                .clipShape(Circle())
                        }
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isInfoButtonPressed = pressing
                            }
                        }, perform: {})
                    }
                }
            }
            .padding()
            .background(
                suggestion.isSelected
                    ? Color.blue.opacity(0.2)
                    : Color.black.opacity(0.3)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        suggestion.isSelected
                            ? LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: suggestion.isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: suggestion.isSelected ? .blue.opacity(0.5) : .clear,
                radius: 8, x: 0, y: 0
            )
            .animation(.spring(), value: suggestion.isSelected)
        }
    }
    
    private struct InfoTextView: View {
        let text: String
        
        var body: some View {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.cyan)
                Text(text)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
    
    private struct ThinkingIndicatorView: View {
        @State private var scale: CGFloat = 1.0
        
        var body: some View {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 8, height: 8)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.2), value: scale)
                }
            }
            .foregroundColor(.white.opacity(0.5))
            .onAppear { scale = 0.5 }
        }
    }
    
    private struct GenerateMoreButtonView: View {
        let onGenerate: () -> Void
        
        var body: some View {
            Button(action: onGenerate) {
                Text("Generate more ideas")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.8))
                    .clipShape(Capsule())
            }
        }
    }
    
    private struct InputBarView: View {
        @Binding var userInput: String
        let onSend: () -> Void
        
        @State private var currentPlaceholder: String = ""
        private let placeholders = [
            "Suggest a new lesson idea...",
            "Ask a clarifying question...",
            "Tell me more about a topic...",
            "Refine the current lesson plan..."
        ]
        
        var body: some View {
            HStack {
                TextField("", text: $userInput, prompt: Text(currentPlaceholder).foregroundColor(.white.opacity(0.7)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .onAppear(perform: setupPlaceholderAnimation)
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(userInput.isEmpty ? .gray : .purple)
                }
                .disabled(userInput.isEmpty)
            }
            .padding()
            .background(Color(white: 0.05))
        }
        
        private func setupPlaceholderAnimation() {
            currentPlaceholder = placeholders[0]
            
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                let currentIndex = placeholders.firstIndex(of: currentPlaceholder) ?? 0
                let nextIndex = (currentIndex + 1) % placeholders.count
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentPlaceholder = placeholders[nextIndex]
                }
            }
        }
    }
    
    private struct ClarificationOptionsView: View {
        let originalQuery: String
        let options: [String]
        let onResponse: (String, String) -> Void
        
        var body: some View {
            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: { onResponse(originalQuery, option) }) {
                        Text(option)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private struct DescriptiveLoadingView: View {
        let text: String
        
        var body: some View {
            HStack(spacing: 8) {
                ProgressView()
                    .tint(.gray)
                Text(text)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
    
    private struct ErrorBubbleView: View {
        let message: String
        let onRetry: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("AI Generation Failed")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text(message)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.8))

                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color.red.opacity(0.3))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Extracted Message Content Views
    
    private struct TextBubble: View {
        let text: String
        var body: some View {
            Text(text)
                .font(.callout)
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
        }
    }
    
    // MARK: - Previews
    struct CourseChatSetupView_Previews: PreviewProvider {
        static var previews: some View {
            CourseChatSetupView(topic: "The History of Rome")
                .preferredColorScheme(.dark)
        }
    }
}
