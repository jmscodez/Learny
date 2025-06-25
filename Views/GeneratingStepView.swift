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
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @State private var animationProgress: Double = 0
    @State private var currentStep = 0
    @State private var showingSteps = false
    @State private var particles: [Particle] = []
    @State private var pulseAnimation = false
    @State private var currentLessonBeingGenerated = ""
    @State private var showingPreview = false
    @State private var generatedContent: [String] = []
    
    private let generationSteps = [
        "🔍 Analyzing your preferences",
        "🎯 Selecting relevant concepts",
        "📚 Structuring lesson sequence",
        "✨ Generating personalized content",
        "🎉 Finalizing your course"
    ]
    
    var body: some View {
        ZStack {
            // Dynamic animated background
            backgroundGradient
            
            // Floating particles
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .scaleEffect(particle.scale)
                    .blur(radius: particle.blur)
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Main progress section
                progressSection
                
                // Title and description
                titleSection
                
                // Current lesson being generated
                if !currentLessonBeingGenerated.isEmpty {
                    currentLessonSection
                }
                
                // Generation steps
                if showingSteps {
                    generationStepsSection
                }
                
                Spacer()
                
                // Action buttons
                actionButtonsSection
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            startAnimations()
            startGeneration()
        }
        .onChange(of: progress) { newProgress in
            updateCurrentStep(for: newProgress)
            updateCurrentLesson(for: newProgress)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.02, green: 0.05, blue: 0.3), location: 0),
                .init(color: Color(red: 0.05, green: 0.1, blue: 0.4), location: 0.3),
                .init(color: Color(red: 0.08, green: 0.15, blue: 0.5), location: 0.6),
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.6), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .hueRotation(.degrees(animationProgress * 30))
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animationProgress)
    }
    
    private var progressSection: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                .frame(width: 240, height: 240)
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .opacity(pulseAnimation ? 0.3 : 0.8)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .purple, .green, .yellow, .blue]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
            
            // Inner content
            VStack(spacing: 16) {
                // AI Brain icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .clear]),
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan, .blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(animationProgress * 10))
                }
                
                // Progress percentage
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .cyan]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .contentTransition(.numericText())
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("Creating Your Personalized Course")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .cyan.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .opacity(animationProgress)
            
            Text("Our AI is crafting the perfect learning path for **\(topic)** with \(selectedLessons.count) personalized lessons")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .opacity(animationProgress)
        }
    }
    
    private var currentLessonSection: some View {
        VStack(spacing: 8) {
            Text("Currently Generating")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .tracking(1.2)
            
            Text(currentLessonBeingGenerated)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var generationStepsSection: some View {
        VStack(spacing: 16) {
            Text("Generation Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            VStack(spacing: 12) {
                ForEach(Array(generationSteps.enumerated()), id: \.offset) { index, step in
                    GenerationStepRow(
                        step: step,
                        isCompleted: index < currentStep,
                        isActive: index == currentStep,
                        animationDelay: Double(index) * 0.1
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Interactive features
            VStack(spacing: 12) {
                // Background processing note
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                        .rotationEffect(.degrees(progress * 360))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: progress)
                    
                    Text("You can navigate to other tabs while your course generates")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Progress insights
                if progress > 0.3 {
                    VStack(spacing: 8) {
                        Text("🎯 Analyzing your interests and preferences")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))
                            .opacity(progress > 0.3 ? 1 : 0)
                        
                        if progress > 0.6 {
                            Text("📚 Creating personalized lesson content")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.8))
                                .opacity(progress > 0.6 ? 1 : 0)
                        }
                        
                        if progress > 0.8 {
                            Text("✨ Finalizing your learning experience")
                                .font(.caption)
                                .foregroundColor(.purple.opacity(0.8))
                                .opacity(progress > 0.8 ? 1 : 0)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .opacity(progress > 0.2 ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: progress)
            
            HStack(spacing: 16) {
                // Cancel button
                Button(action: onCancel) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.headline)
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.2))
                            )
                    )
                }
                
                // Continue in background button
                Button(action: {
                    withAnimation(.spring()) {
                        isVisible = false
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .font(.headline)
                        Text("Continue in Background")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .opacity(progress > 0.1 ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
    
    // MARK: - Animation Functions
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 1.2)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingSteps = true
            }
        }
        
        createParticles()
        animateParticles()
    }
    
    private func startGeneration() {
        // Simulate realistic generation progress
        let totalSteps = selectedLessons.count * 4 // 4 sub-steps per lesson
        var currentProgress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if currentProgress < 1.0 {
                let increment = Double.random(in: 0.02...0.08)
                currentProgress = min(currentProgress + increment, 1.0)
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    progress = currentProgress
                }
                
                if currentProgress >= 1.0 {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }
    
    private func updateCurrentStep(for progress: Double) {
        let newStep = min(Int(progress * Double(generationSteps.count)), generationSteps.count - 1)
        if newStep != currentStep {
            withAnimation(.spring()) {
                currentStep = newStep
            }
        }
    }
    
    private func updateCurrentLesson(for progress: Double) {
        let lessonIndex = Int(progress * Double(selectedLessons.count))
        if lessonIndex < selectedLessons.count {
            let newLesson = selectedLessons[lessonIndex].title
            if newLesson != currentLessonBeingGenerated {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentLessonBeingGenerated = newLesson
                }
            }
        }
    }
    
    private func createParticles() {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                color: [.blue, .purple, .cyan, .green].randomElement() ?? .blue,
                size: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.1...0.6),
                scale: Double.random(in: 0.5...1.5),
                blur: CGFloat.random(in: 0...2)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in particles.indices {
                withAnimation(.linear(duration: Double.random(in: 2...8))) {
                    particles[i].position.x += CGFloat.random(in: -2...2)
                    particles[i].position.y += CGFloat.random(in: -2...2)
                    particles[i].opacity = Double.random(in: 0.1...0.6)
                    particles[i].scale = Double.random(in: 0.5...1.5)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct GenerationStepRow: View {
    let step: String
    let isCompleted: Bool
    let isActive: Bool
    let animationDelay: Double
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // Step indicator
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : (isActive ? Color.blue : Color.white.opacity(0.2)))
                    .frame(width: 24, height: 24)
                    .scaleEffect(isActive ? 1.2 : 1.0)
                    .animation(.spring(), value: isActive)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else if isActive {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationProgress)
                        .opacity(1 - animationProgress)
                }
            }
            
            // Step text
            Text(step)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .medium)
                .foregroundColor(isCompleted ? .green : (isActive ? .white : .white.opacity(0.6)))
                .animation(.easeInOut(duration: 0.3), value: isActive)
            
            Spacer()
            
            if isActive {
                // Loading indicator
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
        }
        .opacity(animationProgress)
        .offset(x: animationProgress == 1.0 ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(animationDelay)) {
                animationProgress = 1.0
            }
        }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            if isActive {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    animationProgress = animationProgress == 1.0 ? 0.7 : 1.0
                }
            }
        }
    }
}

// MARK: - Particle System

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: Double
    let blur: CGFloat
}

#Preview {
    GeneratingStepView(
        topic: "World War 2",
        selectedLessons: [],
        progress: .constant(0.6),
        isVisible: .constant(true),
        onComplete: {},
        onCancel: {}
    )
} 