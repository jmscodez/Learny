//
//  CourseChatSetupView.swift
//  Learny
//

import SwiftUI

// MARK: - Enhanced Course Builder Types

enum OnboardingStep: Int, CaseIterable {
    case experience = 0
    case topicSelection = 1
    case timeCommitment = 2
    case chatCustomization = 3
    case generating = 4
    case customization = 5
}

struct LearningGoal: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct InterestArea: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    var isSelected: Bool = false
}

// Using AdvancedCourseConfig from TopicInputView.swift

// MARK: - Enhanced Course Builder View

struct CourseChatSetupView: View {
    @StateObject private var viewModel: EnhancedCourseChatViewModel
    @State private var currentStep: OnboardingStep = .experience
    @State private var isFinalizing = false
    @State private var showingChat = false
    @State private var suggestionForDetail: LessonSuggestion?
    @State private var animationProgress: Double = 0
    
    @Binding var isPresented: Bool
    
    let advancedConfig: AdvancedCourseConfig
    
    init(topic: String, difficulty: Difficulty, pace: Pace, advancedConfig: AdvancedCourseConfig = AdvancedCourseConfig(), isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: EnhancedCourseChatViewModel(topic: topic, difficulty: difficulty, pace: pace))
        self.advancedConfig = advancedConfig
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            // Dynamic Finance-themed background
            AnimatedBackgroundView(topic: viewModel.topic, progress: animationProgress)
            
            VStack(spacing: 0) {
                // Enhanced Header with Progress
                enhancedHeaderView
                
                // Main Content Area
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                        stepContentView(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentStep)
                
                // Floating Chat Button (when appropriate)
                if currentStep.rawValue >= OnboardingStep.chatCustomization.rawValue {
                    floatingChatButton
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                animationProgress = 1.0
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatOverlayView(viewModel: viewModel)
        }
        .sheet(isPresented: $isFinalizing) {
            FinalizeCourseView(
                lessons: viewModel.selectedLessons.sorted { $0.title < $1.title },
                topic: viewModel.topic,
                difficulty: viewModel.difficulty,
                pace: viewModel.pace,
                onCancel: { isFinalizing = false },
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
}

// MARK: - Step Content Views

extension CourseChatSetupView {
    
    @ViewBuilder
    private func stepContentView(for step: OnboardingStep) -> some View {
        switch step {
        case .experience:
            ExperienceStepView(
                selectedExperience: $viewModel.userExperience,
                onContinue: { nextStep() }
            )
        case .topicSelection:
            TopicSelectionStepView(
                topic: viewModel.topic,
                selectedTopics: $viewModel.selectedTopics,
                onContinue: { nextStep() }
            )
        case .timeCommitment:
            TimeCommitmentStepView(
                selectedTime: $viewModel.preferredLessonTime,
                selectedFrequency: $viewModel.studyFrequency,
                onContinue: { nextStep() }
            )
        case .chatCustomization:
            ChatCustomizationStepView(
                viewModel: viewModel,
                onContinue: { generateCourse() }
            )
        case .generating:
            GeneratingStepView(
                topic: viewModel.topic,
                progress: viewModel.generationProgress
            )
        case .customization:
            CustomizationStepView(
                viewModel: viewModel,
                onShowDetail: { suggestion in
                    suggestionForDetail = suggestion
                },
                onFinalize: {
                    isFinalizing = true
                }
            )
        }
    }
    
    private func nextStep() {
        withAnimation(.spring()) {
            if currentStep.rawValue < OnboardingStep.allCases.count - 1 {
                currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? currentStep
            }
        }
    }
    
    private func generateCourse() {
        withAnimation(.spring()) {
            currentStep = .generating
        }
        
        Task {
            await viewModel.generatePersonalizedCourse()
            
            await MainActor.run {
                withAnimation(.spring()) {
                    currentStep = .customization
                }
            }
        }
    }
}

// MARK: - Enhanced Header

extension CourseChatSetupView {
    private var enhancedHeaderView: some View {
        VStack(spacing: 16) {
            // Navigation and Title
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("AI Course Builder")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.topic)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Step indicator
                HStack(spacing: 4) {
                    ForEach(0..<OnboardingStep.allCases.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentStep.rawValue ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentStep.rawValue ? 1.2 : 1.0)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .frame(width: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Progress Bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: CGFloat(Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)) * (UIScreen.main.bounds.width - 40), height: 4)
                    .animation(.easeInOut, value: currentStep)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
    
    private var floatingChatButton: some View {
        HStack {
            Spacer()
            
            Button(action: { showingChat = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .font(.title3)
                    Text("Chat with AI")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Supporting Views

// Note: Individual step views are implemented in separate files:
// - WelcomeStepView.swift
// - ExperienceStepView.swift  
// - InterestsStepView.swift
// - TimeCommitmentStepView.swift
// - GoalsStepView.swift
// - GeneratingStepView.swift
// - CustomizationStepView.swift
// - ChatOverlayView.swift

struct AnimatedBackgroundView: View {
    let topic: String
    let progress: Double
    
    var body: some View {
        // Finance-themed animated background
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.05, blue: 0.2),
                Color(red: 0.05, green: 0.1, blue: 0.3),
                Color(red: 0.08, green: 0.15, blue: 0.4),
                Color(red: 0.1, green: 0.2, blue: 0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Subtle animated elements
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: Double.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(progress)
                    .animation(.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true), value: progress)
            }
        )
        .ignoresSafeArea()
    }
}

// MARK: - Enhanced View Model

@MainActor
final class EnhancedCourseChatViewModel: ObservableObject {
    @Published var userExperience: String = ""
    @Published var selectedTopics: [String] = []
    @Published var preferredLessonTime: Int = 15
    @Published var studyFrequency: String = ""
    @Published var chatMessages: [ChatMessage] = []
    @Published var userCustomizations: String = ""
    @Published var generationProgress: Double = 0.0
    @Published var suggestedLessons: [LessonSuggestion] = []
    @Published var selectedLessons: [LessonSuggestion] = []
    @Published var isGenerating: Bool = false
    
    // Legacy properties for compatibility
    let topic: String
    let difficulty: Difficulty
    let pace: Pace
    
    private let aiService = OpenAIService.shared
    
    init(topic: String, difficulty: Difficulty, pace: Pace) {
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
    }
    
    func generatePersonalizedCourse() async {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
        }
        
        // Create a background task for lesson generation
        let generationTask = Task {
            return await aiService.generatePersonalizedLessonIdeas(
                for: topic,
                difficulty: difficulty,
                pace: pace,
                experience: userExperience,
                interests: selectedTopics,
                goals: [],
                timeCommitment: preferredLessonTime
            )
        }
        
        // Progress simulation task
        let progressTask = Task {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await MainActor.run {
                    generationProgress = Double(i) / 10.0
                }
            }
        }
        
        // Wait for lesson generation with timeout
        let lessons: [LessonSuggestion]?
        do {
            lessons = try await withThrowingTaskGroup(of: [LessonSuggestion]?.self) { group in
                group.addTask { await generationTask.value }
                
                // Add timeout task
                group.addTask {
                    try await Task.sleep(nanoseconds: 30_000_000_000) // 30 second timeout
                    throw NSError(domain: "GenerationTimeout", code: -1)
                }
                
                for try await result in group {
                    group.cancelAll()
                    return result
                }
                return nil
            }
        } catch {
            print("Course generation failed: \(error)")
            lessons = nil
        }
        
        // Wait for progress animation to complete
        await progressTask.value
        
        await MainActor.run {
            if let lessons = lessons {
                suggestedLessons = lessons
            } else {
                // Provide fallback lessons on failure
                suggestedLessons = generateFallbackLessons()
            }
            isGenerating = false
        }
    }
    
    private func generateFallbackLessons() -> [LessonSuggestion] {
        return [
            LessonSuggestion(title: "Introduction to \(topic)", description: "A foundational overview to get you started with the basics"),
            LessonSuggestion(title: "Core Concepts", description: "Essential principles and ideas you need to understand"),
            LessonSuggestion(title: "Practical Applications", description: "How to apply what you've learned in real-world situations"),
            LessonSuggestion(title: "Advanced Techniques", description: "Taking your knowledge to the next level"),
            LessonSuggestion(title: "Historical Context", description: "Understanding the background and evolution of the topic")
        ]
    }
    
    func addChatMessage(_ message: String) {
        let chatMessage = ChatMessage(role: .user, content: .text(message))
        chatMessages.append(chatMessage)
        
        // Simple AI response for now
        let aiResponse = ChatMessage(role: .assistant, content: .text("I'll incorporate that into your course design: \(message)"))
        chatMessages.append(aiResponse)
    }
}
