//
//  CourseChatSetupView.swift
//  Learny
//

import SwiftUI

// MARK: - Enhanced Course Builder Types

enum OnboardingStep: Int, CaseIterable {
    case experience = 0
    case interests = 1
    case timeCommitment = 2
    case lessonCount = 3
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
    @State private var selectedInterests: [InterestArea] = []
    @State private var customInterestDetails: String = ""
    @State private var isDismissing = false
    
    @Binding var isPresented: Bool
    @EnvironmentObject private var generationManager: CourseGenerationManager
    
    init(topic: String, difficulty: Difficulty, pace: Pace, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: EnhancedCourseChatViewModel(topic: topic, difficulty: difficulty, pace: pace))
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
                if !isDismissing {
                    TabView(selection: $currentStep) {
                        ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                            stepContentView(for: step)
                                .tag(step)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentStep)
                } else {
                    // Show empty view while dismissing
                    Color.clear
                }
            }
        }
        .onChange(of: isPresented) {
            // This handles cases where the sheet is dismissed by dragging down
            if !isPresented && !isDismissing {
                performDismissal()
            }
        }
        .onAppear {
            // Reset dismissing state when view appears
            isDismissing = false
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
        .onDisappear {
            // This is a final safeguard. If the view disappeared for a reason
            // other than our explicit dismissal flow (e.g., parent view changed),
            // this ensures the generation is cancelled.
            if !isDismissing {
                viewModel.cancelGeneration()
            }
        }
    }
    
    private func performDismissal() {
        // Ensure dismissal logic only runs once
        guard !isDismissing else { return }
        isDismissing = true
        
        // 1. Dismiss the keyboard to prevent constraint errors
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // 2. Cancel both generation systems
        viewModel.cancelGeneration()
        generationManager.cancelGeneration()
        
        // 3. Dismiss the sheet
        isPresented = false
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
        case .interests:
            InterestsStepView(
                topic: viewModel.topic,
                selectedInterests: $selectedInterests,
                customDetails: $customInterestDetails,
                onContinue: { 
                    // Pass selected interests and custom details to viewModel
                    viewModel.selectedTopics = selectedInterests.filter(\.isSelected).map(\.title)
                    viewModel.customInterestDetails = customInterestDetails
                    nextStep() 
                }
            )
        case .timeCommitment:
                            TimeCommitmentStepView(
                    minutesPerLesson: $viewModel.preferredLessonTime,
                    studyFrequency: $viewModel.studyFrequency,
                    onNext: { nextStep() }
                )
        case .lessonCount:
            LessonCountStepView(
                selectedLessonCount: $viewModel.desiredLessonCount,
                timeCommitment: viewModel.preferredLessonTime,
                onContinue: { generateCourse() }
            )
        case .generating:
            GeneratingStepView(
                topic: viewModel.topic,
                selectedLessons: viewModel.selectedLessons,
                progress: $viewModel.generationProgress,
                isVisible: .constant(true),
                isFrozen: isDismissing,
                onComplete: {
                    withAnimation(.spring()) {
                        currentStep = .customization
                    }
                },
                onCancel: {
                    // Cancel generation and go back to lesson count step
                    viewModel.cancelGeneration()
                    withAnimation(.spring()) {
                        currentStep = .lessonCount
                    }
                }
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
            
            // Only transition to customization if generation completed successfully
            await MainActor.run {
                // Check if we're still in generating step and generation completed successfully
                // (not cancelled and has generated lessons)
                if currentStep == .generating && 
                   !viewModel.isGenerating && 
                   viewModel.generationProgress >= 1.0 &&
                   !viewModel.suggestedLessons.isEmpty {
                    withAnimation(.spring()) {
                        currentStep = .customization
                    }
                }
                // If we're not in generating step anymore, it means user cancelled
                // so we don't transition to customization
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
                Button(action: {
                    performDismissal()
                }) {
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
        .background(Color.white.opacity(0.05))
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
        // Simple gradient background without animations to prevent NaN errors
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
        .ignoresSafeArea()
    }
}

// MARK: - Enhanced View Model
// Note: EnhancedCourseChatViewModel is now defined in ViewModels/CourseChatViewModel.swift
