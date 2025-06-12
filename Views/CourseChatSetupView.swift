//
//  CourseChatSetupView.swift
//  Learny
//

import SwiftUI

struct CourseChatSetupView: View {
    @StateObject private var viewModel: CourseChatViewModel
    @State private var userInput: String = ""
    @State private var isFinalizing = false
    
    @AppStorage("hasSeenAIWalkthrough") var hasSeenAIWalkthrough: Bool = false
    @State private var showWalkthrough: Bool = false

    init(topic: String) {
        _viewModel = StateObject(wrappedValue: CourseChatViewModel(topic: topic))
    }

    var body: some View {
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
                                onOptionSelected: viewModel.selectLessonCount,
                                onToggleLesson: viewModel.toggleLessonSelection,
                                onGenerateMore: viewModel.generateMoreSuggestions,
                                onClarificationResponse: viewModel.handleClarificationResponse
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) { _ in
                    withAnimation(.spring()) {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            InputBarView(userInput: $userInput) {
                viewModel.addUserMessage(userInput)
                userInput = ""
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $isFinalizing) {
            FinalizeCourseView(
                lessons: viewModel.selectedLessons.sorted { $0.title < $1.title },
                topic: viewModel.topic
            )
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
    let onOptionSelected: (String) -> Void
    let onToggleLesson: (UUID) -> Void
    let onGenerateMore: () -> Void
    let onClarificationResponse: (String, String) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                Image(systemName: "sparkle")
                    .font(.title)
                    .foregroundColor(.cyan)
                
                VStack(alignment: .leading, spacing: 10) {
                    switch message.content {
                    case .text(let text):
                        Text(text).foregroundColor(.white)
                    case .lessonCountOptions:
                        LessonCountOptionsView(onOptionSelected: onOptionSelected)
                    case .thinkingIndicator:
                        ThinkingIndicatorView()
                    case .descriptiveLoading(let text):
                        DescriptiveLoadingView(text: text)
                    case .lessonSuggestions:
                        LessonSuggestionsView(suggestions: lessonSuggestions, onToggleLesson: onToggleLesson)
                    case .inlineLessonSuggestions(let suggestionIDs):
                        let suggestions = lessonSuggestions.filter { suggestionIDs.contains($0.id) }
                        LessonSuggestionsView(suggestions: suggestions, onToggleLesson: onToggleLesson)
                    case .clarificationOptions(let originalQuery, let options):
                        ClarificationOptionsView(originalQuery: originalQuery, options: options, onResponse: onClarificationResponse)
                    case .infoText(let text):
                        InfoTextView(text: text)
                    case .finalPrompt:
                        FinalPromptView()
                    case .generateMoreIdeasButton:
                        GenerateMoreButtonView(onGenerate: onGenerateMore)
                    }
                }
                .padding(message.content.isBubble ? 16 : 0)
                .background(message.content.isBubble ? Color.gray.opacity(0.2) : .clear)
                .cornerRadius(16)
                .frame(maxWidth: .infinity, alignment: .leading)

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
    let onToggleLesson: (UUID) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Here are some initial lesson ideas:")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(suggestions) { suggestion in
                LessonSuggestionRow(suggestion: suggestion, onToggle: onToggleLesson)
            }
        }
    }
}

private struct LessonSuggestionRow: View {
    let suggestion: LessonSuggestion
    let onToggle: (UUID) -> Void
    @State private var showInfoPopover: Bool = false
    
    var body: some View {
        Button(action: { onToggle(suggestion.id) }) {
            HStack {
                Image(systemName: suggestion.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(suggestion.isSelected ? .purple : .gray)
                
                Text(suggestion.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: { showInfoPopover = true }) {
                    Image(systemName: "info.circle.fill").foregroundColor(.gray)
                }
                .popover(isPresented: $showInfoPopover) {
                    Text(suggestion.description)
                        .padding()
                        .frame(idealWidth: 250)
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
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

extension ChatMessage.ContentType {
    var isBubble: Bool {
        switch self {
        case .text, .lessonSuggestions, .infoText, .inlineLessonSuggestions: return true
        default: return false
        }
    }
}

// MARK: - Previews
struct CourseChatSetupView_Previews: PreviewProvider {
    static var previews: some View {
        CourseChatSetupView(topic: "The History of Rome")
            .preferredColorScheme(.dark)
    }
}
