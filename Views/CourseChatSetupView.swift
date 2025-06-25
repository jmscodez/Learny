//
//  CourseChatSetupView.swift
//  Learny
//

import SwiftUI

struct CourseChatSetupView: View {
    @StateObject private var viewModel: CourseChatViewModel
    @State private var isFinalizing = false
    
    // Controls the presentation of this modal view
    @Binding var isPresented: Bool
    
    // Holds the suggestion for the info sheet
    @State private var suggestionForDetail: LessonSuggestion?
    
    // Advanced configuration
    let advancedConfig: AdvancedCourseConfig
    
    init(topic: String, difficulty: Difficulty, pace: Pace, advancedConfig: AdvancedCourseConfig = AdvancedCourseConfig(), isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: CourseChatViewModel(topic: topic, difficulty: difficulty, pace: pace))
        self.advancedConfig = advancedConfig
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            // Enhanced gradient background matching LessonPlayerView
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
                // Modern Header
                modernHeaderView
                
                // Current Lessons Summary (if applicable)
                if viewModel.canShowSuggestions {
                    modernCurrentLessonsView
                }
                
                // Chat Messages Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                ModernMessageView(
                                    message: message,
                                    lessonSuggestions: viewModel.lessonSuggestions,
                                    swappingLessonID: viewModel.swappingLessonID,
                                    advancedConfig: advancedConfig,
                                    onOptionSelected: viewModel.selectLessonCount,
                                    onToggleLesson: viewModel.toggleLessonSelection,
                                    onGenerateMore: viewModel.generateMoreSuggestions,
                                    onClarificationResponse: viewModel.handleClarificationResponse,
                                    onShowSuggestionInfo: { suggestion in
                                        suggestionForDetail = suggestion
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages) { _ in
                        guard let last = viewModel.messages.last else { return }
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
                
                // Modern Input Bar
                modernInputBarView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isFinalizing) {
            FinalizeCourseView(
                lessons: viewModel.selectedLessons.sorted { $0.title < $1.title },
                topic: viewModel.topic,
                difficulty: viewModel.difficulty,
                pace: viewModel.pace,
                onCancel: {
                    isFinalizing = false
                },
                onGenerate: {
                    isFinalizing = false
                    isPresented = false
                }
            )
        }
        .sheet(item: $suggestionForDetail) { suggestion in
            NavigationView {
                LessonChatView(lesson: suggestion)
            }
        }
    }
    
    // MARK: - Modern Header View
    private var modernHeaderView: some View {
        VStack(spacing: 16) {
            // Top navigation bar
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("AI Course Builder")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.topic)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.validateAndProceed { shouldFinalize in
                        if shouldFinalize {
                            isFinalizing = true
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("Generate")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: viewModel.selectedLessons.count > 0 ? [.blue, .purple] : [Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: viewModel.selectedLessons.count > 0 ? .purple.opacity(0.3) : .clear, radius: 4)
                }
                .disabled(viewModel.selectedLessons.count == 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Course configuration summary
            courseConfigSummaryView
        }
        .padding(.bottom, 8)
        .background(
            Color.black.opacity(0.3)
                .background(.ultraThinMaterial, in: Rectangle())
        )
    }
    
    // MARK: - Course Config Summary
    private var courseConfigSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Difficulty
                ConfigChip(
                    icon: difficultyIcon(for: viewModel.difficulty),
                    text: viewModel.difficulty.rawValue.capitalized,
                    color: .blue
                )
                
                // Pace
                ConfigChip(
                    icon: paceIcon(for: viewModel.pace),
                    text: viewModel.pace.displayName,
                    color: .purple
                )
                
                // Learning Style
                ConfigChip(
                    icon: advancedConfig.learningStyle.icon,
                    text: advancedConfig.learningStyle.displayName,
                    color: .green
                )
                
                // Sessions
                ConfigChip(
                    icon: "clock.fill",
                    text: "\(advancedConfig.numberOfSessions) sessions",
                    color: .orange
                )
                
                // Time commitment
                ConfigChip(
                    icon: "timer",
                    text: "\(Int(advancedConfig.estimatedTimeCommitment))min",
                    color: .cyan
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Modern Current Lessons View  
    private var modernCurrentLessonsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected Lessons")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.selectedLessons.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            if viewModel.selectedLessons.isEmpty {
                Text("Select lessons below to build your course")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.selectedLessons.sorted { $0.title < $1.title }) { lesson in
                            SelectedLessonChip(lesson: lesson)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Modern Input Bar
    private var modernInputBarView: some View {
        HStack(spacing: 12) {
            TextField("Ask about your course or request changes...", text: $viewModel.userInput)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
            
            Button(action: { viewModel.addUserMessage() }) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty ? 
                                [Color.gray.opacity(0.3)] : [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty ? 
                        .clear : .purple.opacity(0.3), radius: 4)
            }
            .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Color.black.opacity(0.3)
                .background(.ultraThinMaterial, in: Rectangle())
        )
    }
    
    // MARK: - Helper Functions
    private func difficultyIcon(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .beginner: return "star.fill"
        case .intermediate: return "star.circle.fill"
        case .advanced: return "crown.fill"
        }
    }
    
    private func paceIcon(for pace: Pace) -> String {
        switch pace {
        case .quickReview: return "bolt.fill"
        case .balanced: return "scale.3d"
        case .deepDive: return "magnifyingglass"
        }
    }
}

// MARK: - Supporting Views

struct ConfigChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                )
        )
        .foregroundColor(color)
    }
}

struct SelectedLessonChip: View {
    let lesson: LessonSuggestion
    
    var body: some View {
        Text(lesson.title)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                    )
            )
            .foregroundColor(.blue)
    }
}

struct ModernMessageView: View {
    let message: ChatMessage
    let lessonSuggestions: [LessonSuggestion]
    let swappingLessonID: UUID?
    let advancedConfig: AdvancedCourseConfig
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
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    messageContentView
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 0) {
                    messageContentView
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                // User Avatar
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
        }
    }
    
    @ViewBuilder
    private var messageContentView: some View {
        Group {
            switch message.content {
            case .text(let text):
                ModernTextBubble(text: text, isUser: message.role == .user)
                
            case .lessonSuggestions(let suggestions):
                ModernLessonSuggestionsView(
                    suggestions: suggestions,
                    swappingLessonID: swappingLessonID,
                    onToggleLesson: onToggleLesson,
                    onShowInfo: onShowSuggestionInfo,
                    onSwap: onSwapSuggestion
                )
                
            case .lessonCountOptions(let options):
                ModernOptionsView(options: options, onOptionSelected: onOptionSelected)
                
            case .clarificationOptions(let options):
                ModernClarificationView(options: options, onResponse: onClarificationResponse)
                
            case .thinkingIndicator:
                ModernThinkingIndicator()
                
            case .descriptiveLoading(let message):
                ModernLoadingView(message: message)
                
            case .generateMoreIdeasButton:
                ModernGenerateMoreButton(onTap: onGenerateMore)
                
            case .errorMessage(let error):
                ModernErrorView(error: error, onRetry: onRetry)
                
            case .infoText(let text):
                ModernInfoBubble(text: text)
                
            case .inlineLessonSuggestions(let suggestions):
                ModernInlineLessonSuggestions(
                    suggestions: suggestions,
                    onToggleLesson: onToggleLesson,
                    onShowInfo: onShowSuggestionInfo
                )
                
            case .finalPrompt(let prompt):
                ModernFinalPromptView(prompt: prompt)
            }
        }
    }
}

// MARK: - Modern Message Components

struct ModernTextBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isUser ? 
                        LinearGradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }
}

struct ModernLessonSuggestionsView: View {
    let suggestions: [LessonSuggestion]
    let swappingLessonID: UUID?
    let onToggleLesson: (UUID) -> Void
    let onShowInfo: (LessonSuggestion) -> Void
    let onSwap: (LessonSuggestion) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Lessons")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            LazyVStack(spacing: 12) {
                ForEach(suggestions) { suggestion in
                    ModernLessonCard(
                        lesson: suggestion,
                        isSwapping: swappingLessonID == suggestion.id,
                        onToggle: { onToggleLesson(suggestion.id) },
                        onShowInfo: { onShowInfo(suggestion) },
                        onSwap: { onSwap(suggestion) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ModernLessonCard: View {
    let lesson: LessonSuggestion
    let isSwapping: Bool
    let onToggle: () -> Void
    let onShowInfo: () -> Void
    let onSwap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            Button(action: onToggle) {
                Image(systemName: lesson.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(lesson.isSelected ? .green : .white.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(lesson.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                HStack {
                    Label(lesson.estimatedMinutes, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    if lesson.hasPractice {
                        Label("Interactive", systemImage: "gamecontroller")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 8) {
                        Button(action: onShowInfo) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                        
                        if lesson.isSelected {
                            Button(action: onSwap) {
                                Image(systemName: isSwapping ? "arrow.2.circlepath" : "arrow.triangle.2.circlepath")
                                    .font(.caption)
                                    .foregroundColor(.orange.opacity(0.8))
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(lesson.isSelected ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            lesson.isSelected ? Color.green.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: lesson.isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isSwapping ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSwapping)
    }
}

struct ModernOptionsView: View {
    let options: [String]
    let onOptionSelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How many lessons would you like?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button(action: { onOptionSelected(option) }) {
                        Text(option)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ModernClarificationView: View {
    let options: [ClarificationOption]
    let onResponse: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("I need some clarification...")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            VStack(spacing: 8) {
                ForEach(options, id: \.key) { option in
                    Button(action: { onResponse(option.key, option.value) }) {
                        HStack {
                            Text(option.value)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.blue.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ModernThinkingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
            
            Text("Thinking...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            animationPhase = 0
            withAnimation {
                animationPhase = 1
            }
        }
    }
}

struct ModernLoadingView: View {
    let message: String
    @State private var rotation = 0.0
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            rotation = 360
        }
    }
}

struct ModernGenerateMoreButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Generate More Ideas")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: .purple.opacity(0.3), radius: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.8))
                
                Text("Something went wrong")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.3))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ModernInfoBubble: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundColor(.blue.opacity(0.8))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ModernInlineLessonSuggestions: View {
    let suggestions: [LessonSuggestion]
    let onToggleLesson: (UUID) -> Void
    let onShowInfo: (LessonSuggestion) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(suggestions) { suggestion in
                Button(action: { onToggleLesson(suggestion.id) }) {
                    HStack {
                        Image(systemName: suggestion.isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(suggestion.isSelected ? .green : .white.opacity(0.5))
                        
                        Text(suggestion.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { onShowInfo(suggestion) }) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundColor(.blue.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(suggestion.isSelected ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        suggestion.isSelected ? Color.green.opacity(0.3) : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct ModernFinalPromptView: View {
    let prompt: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Course Ready!")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text(prompt)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Legacy Support (Keep existing MessageView for backward compatibility if needed)

private struct HeaderView: View {
    let selectedCount: Int
    let onGenerate: () -> Void
    let onCancel: () -> Void
    
    private var canGenerate: Bool { selectedCount > 0 }
    
    var body: some View {
        HStack {
            Button(action: onCancel) {
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
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 0) {
                    // Message content would go here - keeping legacy structure
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 0) {
                    // User message content would go here
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
        }
    }
}

private struct InputBarView: View {
    @Binding var userInput: String
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 12) {
                TextField("Type your message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit(onSubmit)
                
                Button(action: onSubmit) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color(white: 0.05))
        }
    }
}
