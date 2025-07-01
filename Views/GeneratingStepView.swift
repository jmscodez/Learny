//
//  GeneratingStepView.swift
//  Learny
//

import SwiftUI

struct GeneratingStepView: View {
    let topic: String
    let selectedLessons: [LessonSuggestion]
    @Binding var progress: Double
    @Binding var isVisible: Bool
    let isFrozen: Bool
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @State private var animationProgress: Double = 0
    @State private var currentStep = 0
    @State private var particles: [LoadingParticle] = []
    @State private var pulseAnimation = false
    @State private var currentStoryStep = ""
    @State private var previewLessons: [PreviewLesson] = []
    @State private var showingPreviewCards = false
    @State private var sparkleAnimations: [SparkleAnimation] = []
    
    // Dynamic progress story steps
    private let progressSteps = [
        ProgressStep(title: "Analyzing Your Learning Style", icon: "brain.head.profile", description: "Understanding how you learn best"),
        ProgressStep(title: "Selecting Perfect Topics", icon: "target", description: "Choosing the most relevant concepts"),
        ProgressStep(title: "Crafting Lesson Structure", icon: "building.columns", description: "Organizing content for optimal learning"),
        ProgressStep(title: "Generating Content", icon: "doc.text", description: "Creating personalized lessons"),
        ProgressStep(title: "Final Touches", icon: "sparkles", description: "Polishing your learning experience")
    ]
    
    var body: some View {
        ZStack {
            backgroundView
            particleSystemView
            contentView
        }
        .onAppear {
            setupView()
        }
        .onChange(of: progress) { _, newProgress in
            updateProgress(newProgress)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.08, green: 0.1, blue: 0.2),
                Color(red: 0.1, green: 0.15, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea(.all)
    }
    
    private var particleSystemView: some View {
        ZStack {
            // Enhanced floating particles
            ForEach(Array(particles.enumerated()), id: \.offset) { index, particle in
                particleView(particle, index: index)
            }
            
            // Milestone sparkle bursts
            ForEach(Array(sparkleAnimations.enumerated()), id: \.offset) { index, sparkle in
                sparkleView(sparkle)
            }
        }
    }
    
    private func particleView(_ particle: LoadingParticle, index: Int) -> some View {
        Group {
            if index % 4 == 0 {
                Image(systemName: "sparkle")
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .opacity(particle.opacity * (0.5 + progress * 0.5))
                    .scaleEffect(particle.scale * (0.8 + progress * 0.4))
                    .position(particle.position)
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: true)
                        .delay(particle.delay),
                        value: pulseAnimation
                    )
            } else {
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
                    .opacity(particle.opacity * (0.4 + progress * 0.6))
                    .scaleEffect(particle.scale * (0.7 + progress * 0.5))
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: true)
                        .delay(particle.delay),
                        value: pulseAnimation
                    )
            }
        }
    }
    
    private func sparkleView(_ sparkle: SparkleAnimation) -> some View {
        Group {
            if sparkle.isVisible {
                ForEach(0..<8, id: \.self) { burstIndex in
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat.random(in: 12...20)))
                        .foregroundColor(.cyan)
                        .opacity(sparkle.opacity)
                        .scaleEffect(sparkle.scale)
                        .position(
                            x: sparkle.position.x + cos(Double(burstIndex) * .pi / 4) * sparkle.radius,
                            y: sparkle.position.y + sin(Double(burstIndex) * .pi / 4) * sparkle.radius
                        )
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            titleSection
            currentStepSection
            progressSection
            
            // Always reserve space for preview cards to prevent layout shift
            previewCardsSection
            
            enhancedProgressBar
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private func setupView() {
        withAnimation(.easeOut(duration: 0.8)) {
            animationProgress = 1.0
        }
        setupLoadingParticles()
        startLoadingAnimations()
        generatePreviewLessons()
    }
    
    private func updateProgress(_ newProgress: Double) {
        updateCurrentStep(for: newProgress)
        updateStoryStep(for: newProgress)
        updatePreviewCards(for: newProgress)
        checkForMilestones(newProgress: newProgress)
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            // Enhanced title section with sparkles
            VStack(spacing: 12) {
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
                    
                    Text("Generating Custom Lessons")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .cyan, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .shadow(color: .cyan.opacity(0.5), radius: 4, x: 0, y: 2)
                }
                
                // Enhanced description
                Text("Our AI is crafting the perfect learning experience for you")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            
            // Topic badge
            Text(topic)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .blue.opacity(0.4),
                                    .cyan.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.cyan.opacity(0.6), .blue.opacity(0.4)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
    
    private var currentStepSection: some View {
        VStack(spacing: 12) {
            if currentStep < progressSteps.count {
                let step = progressSteps[currentStep]
                
                HStack(spacing: 12) {
                    // Animated step icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3),
                                        Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        Image(systemName: step.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(step.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // AI thinking indicator
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.cyan.opacity(0.8))
                                .frame(width: 6, height: 6)
                                .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: pulseAnimation
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.4),
                                            Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private var progressSection: some View {
        ZStack {
            // Outer glow rings with enhanced blue theme
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.6 - Double(index) * 0.15),
                                Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5 - Double(index) * 0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3 - CGFloat(index)
                    )
                    .frame(width: 140 + CGFloat(index * 15), height: 140 + CGFloat(index * 15))
                    .scaleEffect(pulseAnimation ? 1.05 + Double(index) * 0.02 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.0 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: pulseAnimation
                    )
            }
            
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 6)
                .frame(width: 140, height: 140)
            
            // Progress circle with enhanced styling
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 0.0, green: 0.8, blue: 1.0), location: 0),
                            .init(color: Color(red: 0.2, green: 0.6, blue: 1.0), location: 0.3),
                            .init(color: Color(red: 0.3, green: 0.5, blue: 1.0), location: 0.6),
                            .init(color: Color(red: 0.4, green: 0.4, blue: 1.0), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.8), radius: 10, x: 0, y: 0)
                .shadow(color: Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.6), radius: 6, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Percentage text with glow
            Text("\(Int(progress * 100))%")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, Color(red: 0.0, green: 0.8, blue: 1.0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.8), radius: 6, x: 0, y: 2)
                .contentTransition(.numericText())
        }
    }
    
    private var previewCardsSection: some View {
        VStack(spacing: 12) {
            // Always show header but with conditional opacity
            HStack {
                Image(systemName: "doc.text")
                    .font(.headline)
                    .foregroundColor(.cyan)
                
                Text("Preview Lessons")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
            }
            .opacity(showingPreviewCards ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6), value: showingPreviewCards)
            
            // Always reserve space for cards (120 height) to prevent layout shift
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(previewLessons) { lesson in
                        PreviewLessonCard(lesson: lesson, progress: progress)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 80) // Fixed height to prevent layout shifts
        }
        .frame(height: 120) // Fixed total height for the section
    }
    
    private var enhancedProgressBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.0, green: 0.8, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 1.0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("with personalized lessons tailored just for you")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            // Simple progress bar matching the interests loading screen
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 0.0, green: 0.8, blue: 1.0), location: 0),
                                    .init(color: Color(red: 0.2, green: 0.6, blue: 1.0), location: 0.5),
                                    .init(color: Color(red: 0.4, green: 0.4, blue: 1.0), location: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.8), radius: 6, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func setupLoadingParticles() {
        particles = (0..<25).map { i in
            let particleColors: [Color] = [
                Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.6),
                Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5),
                Color(red: 0.4, green: 0.4, blue: 1.0).opacity(0.55),
                .white.opacity(0.3),
                Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.4)
            ]
            
            return LoadingParticle(
                id: i,
                position: CGPoint(
                    x: CGFloat.random(in: 30...350),
                    y: CGFloat.random(in: 100...700)
                ),
                color: particleColors.randomElement() ?? .cyan.opacity(0.3),
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.3...0.6),
                scale: Double.random(in: 0.8...1.2),
                duration: Double.random(in: 2.0...4.0),
                delay: Double.random(in: 0...2.0)
            )
        }
    }
    
    private func generatePreviewLessons() {
        previewLessons = [
            PreviewLesson(id: 0, title: "Introduction to \(topic)", isVisible: false),
            PreviewLesson(id: 1, title: "Core Concepts", isVisible: false),
            PreviewLesson(id: 2, title: "Practical Applications", isVisible: false),
            PreviewLesson(id: 3, title: "Advanced Topics", isVisible: false)
        ]
    }
    
    private func startLoadingAnimations() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func updateCurrentStep(for progress: Double) {
        let newStep = min(Int(progress * Double(progressSteps.count)), progressSteps.count - 1)
        if newStep != currentStep {
            withAnimation(.spring()) {
                currentStep = newStep
            }
        }
    }
    
    private func updateStoryStep(for progress: Double) {
        if currentStep < progressSteps.count {
            currentStoryStep = progressSteps[currentStep].title
        }
    }
    
    private func updatePreviewCards(for progress: Double) {
        // Show header when progress reaches 30%
        if progress > 0.3 && !showingPreviewCards {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingPreviewCards = true
            }
        }
        
        // Show cards progressively one by one
        for i in 0..<previewLessons.count {
            let threshold = 0.4 + Double(i) * 0.15
            if progress > threshold && !previewLessons[i].isVisible {
                withAnimation(.easeInOut(duration: 0.6).delay(Double(i) * 0.3)) {
                    previewLessons[i].isVisible = true
                }
            }
        }
    }
    
    private func checkForMilestones(newProgress: Double) {
        let milestones: [Double] = [0.25, 0.5, 0.75, 1.0]
        
        for milestone in milestones {
            if newProgress >= milestone && progress < milestone {
                triggerSparklesBurst(at: milestone)
            }
        }
    }
    
    private func triggerSparklesBurst(at milestone: Double) {
        let sparkle = SparkleAnimation(
            position: CGPoint(x: 180, y: 400), // Center of progress ring
            isVisible: true,
            opacity: 1.0,
            scale: 0.5,
            radius: 0
        )
        
        sparkleAnimations.append(sparkle)
        
        withAnimation(.easeOut(duration: 1.0)) {
            if let index = sparkleAnimations.firstIndex(where: { $0.id == sparkle.id }) {
                sparkleAnimations[index].scale = 1.5
                sparkleAnimations[index].radius = 50
                sparkleAnimations[index].opacity = 0.0
            }
        }
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sparkleAnimations.removeAll { $0.id == sparkle.id }
        }
    }
}

// MARK: - Supporting Models

struct ProgressStep {
    let title: String
    let icon: String
    let description: String
}

struct PreviewLesson: Identifiable {
    let id: Int
    let title: String
    var isVisible: Bool
}

struct SparkleAnimation: Identifiable {
    let id = UUID()
    let position: CGPoint
    var isVisible: Bool
    var opacity: Double
    var scale: Double
    var radius: Double
}

// MARK: - Supporting Views

struct PreviewLessonCard: View {
    let lesson: PreviewLesson
    let progress: Double
    @State private var shimmerPhase: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.caption)
                    .foregroundColor(.cyan.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.yellow.opacity(0.6))
            }
            
            Text(lesson.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            // Progress indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.6),
                            Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .frame(width: progress > 0.5 ? 60 : 30)
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
        .padding(12)
        .frame(width: 120, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.08),
                            .blue.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .cyan.opacity(0.3),
                                    .blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(lesson.isVisible ? 1.0 : 0.0)
        .scaleEffect(lesson.isVisible ? 1.0 : 0.8)
        .animation(.easeInOut(duration: 0.6), value: lesson.isVisible)
    }
}

// MARK: - Particle System Models
// LoadingParticle is defined in InterestsStepView.swift

#Preview {
    GeneratingStepView(
        topic: "Dogs",
        selectedLessons: [],
        progress: .constant(0.6),
        isVisible: .constant(true),
        isFrozen: false,
        onComplete: {},
        onCancel: {}
    )
} 