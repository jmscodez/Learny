import SwiftUI

// Custom progress bar for course generation
private struct CourseProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(.gray.opacity(0.3))
                Capsule()
                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                    .foregroundColor(.cyan)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct FinalizeCourseView: View {
    @EnvironmentObject private var generationManager: CourseGenerationManager
    @EnvironmentObject private var statsManager: LearningStatsManager
    @EnvironmentObject private var notesManager: NotificationsManager
    @EnvironmentObject private var navManager: NavigationManager
    
    @State var lessons: [LessonSuggestion]
    let topic: String
    let difficulty: Difficulty
    let pace: Pace
    
    let onCancel: () -> Void
    let onGenerate: () -> Void
    
    @State private var animationProgress: Double = 0
    @State private var floatingParticles: [FloatingParticle] = []
    @State private var pulseAnimation = false
    @State private var generationStarted = false
    
    // Floating background particles
    private struct FloatingParticle {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        let color: Color
        let opacity: Double
        let duration: Double
        let delay: Double
    }
    
    init(lessons: [LessonSuggestion], topic: String, difficulty: Difficulty, pace: Pace, onCancel: @escaping () -> Void, onGenerate: @escaping () -> Void) {
        self._lessons = State(initialValue: lessons)
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
        self.onCancel = onCancel
        self.onGenerate = onGenerate
    }
    
    // Supports swipe-to-delete
    private func deleteLesson(at offsets: IndexSet) {
        lessons.remove(atOffsets: offsets)
    }
    
    var body: some View {
        ZStack {
            if generationStarted && generationManager.isGenerating {
                // Full-screen generation theater mode
                GenerationTheaterView(
                    topic: topic,
                    totalLessons: lessons.count,
                    generationManager: generationManager
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                    removal: .opacity
                ))
            } else {
                // Normal finalize course view
                mainContentView
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: generationStarted && generationManager.isGenerating)
        .onAppear {
            setupFloatingParticles()
            startAnimations()
        }
        .onChange(of: generationManager.errorMessage) { _, errorMessage in
            // If there's an error, reset the generation started state
            if errorMessage != nil {
                generationStarted = false
            }
        }
        .onChange(of: generationManager.generatedCourse) { _, course in
            // When course generation completes successfully, dismiss the view
            if course != nil && !generationManager.isGenerating {
                onGenerate()
            }
        }
        .onChange(of: generationManager.isGenerating) { _, isGenerating in
            // If generation stops without a course being created, reset state
            if !isGenerating && generationManager.generatedCourse == nil && generationManager.errorMessage != nil {
                generationStarted = false
            }
        }
    }
    
    private var mainContentView: some View {
        ZStack {
            // Enhanced background with floating particles
            backgroundView
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    headerSection
                    
                    // Course summary section
                    courseSummarySection
                    
                    // Generate button
                    generateButtonSection
                    
                    // Lessons section
                    lessonsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            // Base gradient background
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
            
            // Floating background particles
            ForEach(Array(floatingParticles.enumerated()), id: \.offset) { index, particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .blur(radius: 1)
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: true)
                        .delay(particle.delay),
                        value: pulseAnimation
                    )
            }
            
            // Subtle geometric patterns
            GeometryReader { geometry in
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Enhanced cancel button
            HStack {
                Button(action: onCancel) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .padding(.top, 60)
                
                Spacer()
            }
            
            // Enhanced title section
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.yellow.opacity(0.9), .cyan.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Text("Finalize Your Course")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .cyan.opacity(0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Text("Review and customize your personalized learning journey")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var courseSummarySection: some View {
        VStack(spacing: 16) {
            // Topic badge with enhanced styling
            Text(topic)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .blue.opacity(0.6),
                                    .purple.opacity(0.4),
                                    .cyan.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.cyan.opacity(0.8), .blue.opacity(0.6)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            
            // Course metadata
            HStack(spacing: 24) {
                MetadataItem(
                    icon: "book.closed",
                    title: "\(lessons.count) Lessons",
                    subtitle: "Interactive"
                )
                
                MetadataItem(
                    icon: "clock",
                    title: estimatedTime,
                    subtitle: "Duration"
                )
                
                MetadataItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: difficulty.rawValue.capitalized,
                    subtitle: "Level"
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    private var estimatedTime: String {
        let baseTime = lessons.count * 15 // 15 minutes per lesson
        let adjustedTime = Int(Double(baseTime) * pace.timeMultiplier)
        return "\(adjustedTime) min"
    }
    
    private var lessonsSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                Text("Your Learning Path")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(lessons.count) lessons")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            // Enhanced lesson cards
            LazyVStack(spacing: 16) {
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    EnhancedLessonCard(
                        index: index + 1,
                        lesson: lesson,
                        isLast: index == lessons.count - 1
                    )
                }
            }
        }
    }
    
    private var generateButtonSection: some View {
        VStack(spacing: 16) {
            // Enhanced generate button with animations
            Button(action: generationStarted ? {} : startGeneration) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        if generationStarted {
                            // Loading spinner when generation has started
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 20, height: 20)
                                .rotationEffect(.degrees(pulseAnimation ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: pulseAnimation)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(generationStarted ? "Generating Course..." : "Generate Course")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(generationStarted ? generationManager.statusMessage : "Create your personalized learning experience")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    if !generationStarted {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 0.2, green: 0.6, blue: 1.0), location: 0),
                                    .init(color: Color(red: 0.4, green: 0.3, blue: 0.9), location: 0.3),
                                    .init(color: Color(red: 0.6, green: 0.2, blue: 0.8), location: 0.6),
                                    .init(color: Color(red: 0.3, green: 0.8, blue: 0.6), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            }
            .scaleEffect(animationProgress)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationProgress)
            
            // Progress bar when generation is active
            if generationStarted && generationManager.isGenerating {
                VStack(spacing: 8) {
                    // Custom progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, CGFloat(generationManager.generationProgress) * UIScreen.main.bounds.width * 0.8), height: 6)
                            .animation(.easeInOut(duration: 0.3), value: generationManager.generationProgress)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("\(Int(generationManager.generationProgress * 100))% Complete")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 12)
            }
        }
        .padding(.top, 8)
    }
    
    private func setupFloatingParticles() {
        floatingParticles = (0..<12).map { _ in
            FloatingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 200...800)
                ),
                size: CGFloat.random(in: 3...8),
                color: [.cyan.opacity(0.2), .blue.opacity(0.15), .purple.opacity(0.1), .white.opacity(0.1)].randomElement() ?? .cyan.opacity(0.2),
                opacity: Double.random(in: 0.3...0.7),
                duration: Double.random(in: 3...6),
                delay: Double.random(in: 0...3)
            )
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animationProgress = 1.0
        }
        pulseAnimation = true
    }
    
    private func startGeneration() {
        generationStarted = true
        
        // Start global course generation (will show compact banner in MainView)
        generationManager.generateCourse(
            topic: topic,
            suggestions: lessons,
            difficulty: difficulty,
            pace: pace,
            statsManager: statsManager,
            notificationsManager: notesManager
        )
        
        // Don't dismiss immediately - wait for generation to complete
        // The generation manager will handle the entire process independently
    }
}

// MARK: - Supporting Views

private struct MetadataItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.cyan)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.cyan.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                )
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

private struct EnhancedLessonCard: View {
    let index: Int
    let lesson: LessonSuggestion
    let isLast: Bool
    
    @State private var cardHovered = false
    
    // Enhanced color generation
    private var accentColor: Color {
        let colors: [Color] = [
            Color(red: 0.2, green: 0.6, blue: 1.0), // Blue
            Color(red: 0.9, green: 0.5, blue: 0.2), // Orange
            Color(red: 0.6, green: 0.2, blue: 0.8), // Purple
            Color(red: 0.2, green: 0.8, blue: 0.6), // Teal
            Color(red: 0.8, green: 0.3, blue: 0.5), // Pink
            Color(red: 0.4, green: 0.7, blue: 0.3)  // Green
        ]
        guard !colors.isEmpty else { return .blue }
        let safeIndex = abs(lesson.id.hashValue) % colors.count
        return colors[safeIndex]
    }
    
    private var estimatedTime: String {
        let baseTime = 15 // Base 15 minutes
        let variation = Int.random(in: -5...10)
        return "\(baseTime + variation) min"
    }
    
    private var difficultyLevel: String {
        ["Beginner", "Intermediate", "Advanced"].randomElement() ?? "Intermediate"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 16) {
                // Enhanced lesson number with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    accentColor,
                                    accentColor.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Text("\(index)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 14) {
                    // Title and metadata
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lesson.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Metadata badges
                        HStack(spacing: 8) {
                            MetadataBadge(text: estimatedTime, icon: "clock", color: .cyan)
                            MetadataBadge(text: difficultyLevel, icon: "chart.line.uptrend.xyaxis", color: accentColor)
                        }
                    }
                    
                    // Description with better formatting
                    Text(lesson.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        accentColor.opacity(0.4),
                                        accentColor.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: accentColor.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            
            // Connection line to next lesson
            if !isLast {
                HStack {
                    Spacer()
                        .frame(width: 24) // Align with circle center
                    
                    VStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(accentColor.opacity(0.6))
                                .frame(width: 4, height: 4)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
            }
        }
    }
}

private struct MetadataBadge: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
            
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Course Generation Loading View
private struct CourseGenerationLoadingView: View {
    let topic: String
    let lessons: [LessonSuggestion]
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject private var generationManager: CourseGenerationManager
    @State private var animationProgress: Double = 0
    @State private var particles: [CourseLoadingParticle] = []
    @State private var pulseAnimation = false
    @State private var currentStepIndex = 0
    
    private let progressSteps = [
        "Analyzing your learning preferences...",
        "Crafting personalized lesson content...",
        "Generating interactive exercises...",
        "Adding engaging multimedia elements...",
        "Finalizing your custom course..."
    ]
    
    var body: some View {
        ZStack {
            // Background
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
            
            // Particles
            ForEach(Array(particles.enumerated()), id: \.offset) { index, particle in
                particleView(particle)
            }
            
            // Content
            VStack(spacing: 32) {
                Spacer()
                
                // Title section
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow.opacity(0.9), .cyan.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        Text("Creating Your Course")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .cyan, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                    
                    Text(topic)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Current step
                VStack(spacing: 12) {
                    Text(currentStepText)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.5), value: currentStepText)
                    
                    // Progress bar
                    CourseProgressBar(progress: generationManager.generationProgress)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 40)
                    
                    Text("\(Int(generationManager.generationProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Cancel button
                Button("Cancel", action: onCancel)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            setupView()
        }
        .onChange(of: generationManager.generationProgress) { _, newProgress in
            updateCurrentStep(for: newProgress)
        }
        .onChange(of: generationManager.generatedCourse) { _, course in
            if course != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
    
    private var currentStepText: String {
        guard !progressSteps.isEmpty,
              currentStepIndex >= 0,
              currentStepIndex < progressSteps.count else {
            return "Almost ready..."
        }
        return progressSteps[currentStepIndex]
    }
    
    private func setupView() {
        withAnimation(.easeOut(duration: 0.8)) {
            animationProgress = 1.0
        }
        setupLoadingParticles()
        startAnimations()
    }
    
    private func setupLoadingParticles() {
        particles = (0..<20).map { _ in
            CourseLoadingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...700)
                ),
                size: CGFloat.random(in: 6...16),
                color: [.cyan, .blue, .purple, .pink].randomElement() ?? .cyan,
                opacity: Double.random(in: 0.3...0.8),
                scale: Double.random(in: 0.5...1.2),
                duration: Double.random(in: 2...4),
                delay: Double.random(in: 0...2)
            )
        }
    }
    
    private func startAnimations() {
        pulseAnimation = true
    }
    
    private func updateCurrentStep(for progress: Double) {
        guard !progressSteps.isEmpty else { return }
        let calculatedIndex = Int(progress * Double(progressSteps.count))
        let newStepIndex = max(0, min(calculatedIndex, progressSteps.count - 1))
        if newStepIndex != currentStepIndex {
            currentStepIndex = newStepIndex
        }
    }
    
    private func particleView(_ particle: CourseLoadingParticle) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        particle.color,
                        particle.color.opacity(0.3)
                    ]),
                    center: .center,
                    startRadius: 1,
                    endRadius: particle.size/2
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(particle.position)
            .opacity(particle.opacity)
            .scaleEffect(particle.scale)
            .animation(
                .easeInOut(duration: particle.duration)
                .repeatForever(autoreverses: true)
                .delay(particle.delay),
                value: pulseAnimation
            )
    }
}

// MARK: - Course Loading Particle Model
private struct CourseLoadingParticle {
    let position: CGPoint
    let size: CGFloat
    let color: Color
    let opacity: Double
    let scale: Double
    let duration: Double
    let delay: Double
}

// MARK: - Pace Extension
extension Pace {
    var timeMultiplier: Double {
        switch self {
        case .quickReview: return 0.7
        case .balanced: return 1.0
        case .deepDive: return 1.3
        }
    }
}

struct FinalizeCourseView_Previews: PreviewProvider {
    static var previews: some View {
        FinalizeCourseView(
            lessons: [
                .init(title: "Introduction to Phonetic Transcription", description: "In this lesson, you'll learn the basics of phonetic transcription using the International Phonetic Alphabet (IPA)..."),
                .init(title: "Language Isolates: An Introduction", description: "Explore the fascinating world of language isolates, which are languages that don't appear to be..."),
                .init(title: "Phonetic Transcription in Action", description: "Practice transcribing spoken words into phonetic script using real-world examples...")
            ],
            topic: "Phonetic Transcription",
            difficulty: .beginner,
            pace: .balanced,
            onCancel: {},
            onGenerate: {}
        )
        .environmentObject(CourseGenerationManager())
        .environmentObject(LearningStatsManager())
        .environmentObject(NotificationsManager())
    }
}

// MARK: - Generation Theater View

struct GenerationTheaterView: View {
    let topic: String
    let totalLessons: Int
    @ObservedObject var generationManager: CourseGenerationManager
    
    @State private var animatedProgress: Double = 0.0
    @State private var pulseScale: Double = 1.0
    @State private var sparkleRotation: Double = 0.0
    @State private var completedLessonsCount: Int = 0
    
    private var progressPercentage: Int {
        Int(generationManager.generationProgress * 100)
    }
    
    private var estimatedTimeRemaining: String {
        let totalTime = 20.0 // seconds
        let remaining = totalTime * (1.0 - generationManager.generationProgress)
        if remaining < 10 {
            return "Almost done!"
        } else {
            return "\(Int(remaining))s remaining"
        }
    }
    
    var body: some View {
        ZStack {
            // Animated background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.1, green: 0.1, blue: 0.2), location: 0),
                    .init(color: Color(red: 0.2, green: 0.1, blue: 0.3), location: 0.3),
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.4), location: 0.7),
                    .init(color: Color(red: 0.05, green: 0.05, blue: 0.15), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                // Animated particles
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.2), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 50...350),
                            y: CGFloat.random(in: 100...700)
                        )
                        .scaleEffect(pulseScale)
                        .animation(.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true), value: pulseScale)
                }
            )
            
            VStack(spacing: 40) {
                Spacer()
                
                // Course topic header
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.cyan)
                            .rotationEffect(.degrees(sparkleRotation))
                            .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: sparkleRotation)
                        
                        Text("Creating Your Course")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Text(topic)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Large circular progress indicator
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(pulseScale)
                    
                    // Center content
                    VStack(spacing: 8) {
                        Text("\(progressPercentage)%")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(Int(animatedProgress * Double(totalLessons))) of \(totalLessons)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Status and time remaining
                VStack(spacing: 8) {
                    Text(shortStatusMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(estimatedTimeRemaining)
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                }
                
                // Lesson completion indicators
                if totalLessons <= 8 {
                    LessonProgressIndicators(
                        totalLessons: totalLessons,
                        progress: generationManager.generationProgress
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: generationManager.generationProgress) { _, newProgress in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newProgress
            }
        }
    }
    
    private var shortStatusMessage: String {
        let message = generationManager.statusMessage
        
        // Convert long messages to shorter, more engaging ones
        if message.contains("Generating all lessons simultaneously") {
            return "🧠 AI is crafting your lessons..."
        } else if message.contains("Completed lesson:") {
            // Extract lesson name and show it nicely
            let components = message.components(separatedBy: ":")
            if components.count > 1 {
                let lessonName = components[1].trimmingCharacters(in: .whitespaces)
                return "✅ \(lessonName)"
            }
        } else if message.contains("Designing course structure") {
            return "📋 Designing your course..."
        } else if message.contains("Finalizing") {
            return "✨ Adding final touches..."
        } else if message.contains("Done") {
            return "🎉 Course ready!"
        }
        
        return message
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
        
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
    }
}

// MARK: - Lesson Progress Indicators

struct LessonProgressIndicators: View {
    let totalLessons: Int
    let progress: Double
    
    private var completedLessons: Int {
        Int(progress * Double(totalLessons))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalLessons, id: \.self) { index in
                Circle()
                    .fill(index < completedLessons ? 
                          LinearGradient(colors: [.green, .cyan], startPoint: .top, endPoint: .bottom) : 
                          LinearGradient(colors: [.white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .scaleEffect(index < completedLessons ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: completedLessons)
            }
        }
    }
} 