//
//  GeneratingStepView.swift
//  Learny
//

import SwiftUI

struct GeneratingStepView: View {
    let topic: String
    @Binding var progress: Double
    
    @State private var animationProgress: Double = 0
    @State private var currentStep = 0
    @State private var showingSteps = false
    @State private var particles: [Particle] = []
    
    private let generationSteps = [
        "Analyzing your preferences",
        "Selecting relevant topics and concepts",
        "Structuring optimal lesson sequence",
        "Generating personalized content",
        "Finalizing your custom course"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color.opacity(0.6))
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Main animation circle
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 200, height: 200)
                        
                        // Progress ring
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple, .green]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.8), value: progress)
                        
                        // Center content
                        VStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(animationProgress)
                                .rotationEffect(.degrees(animationProgress * 360))
                            
                            Text("\(Int(progress * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Title and description
                    VStack(spacing: 16) {
                        Text("Creating your personalized course")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(animationProgress)
                        
                        Text("Our AI is analyzing your preferences and crafting the perfect learning path for \(topic)")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(animationProgress)
                    }
                    
                    // Generation steps
                    if showingSteps {
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
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer()
                    
                    // Background processing note
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            Text("You can navigate to other tabs while your course generates")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Button("Continue in Background") {
                            // Handle background processing
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        )
                    }
                    .opacity(progress > 0.2 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
        }
        .onAppear {
            startAnimations()
            simulateProgress()
        }
        .onChange(of: progress) { newProgress in
            updateCurrentStep(for: newProgress)
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 1.0)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingSteps = true
            }
        }
        
        createParticles()
        animateParticles()
    }
    
    private func simulateProgress() {
        // Simulate progress updates
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if progress < 1.0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    progress = min(progress + 0.1, 1.0)
                }
            } else {
                timer.invalidate()
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
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...700)
                ),
                color: [Color.blue, Color.purple, Color.green, Color.cyan].randomElement() ?? .blue,
                size: CGFloat.random(in: 4...12),
                scale: CGFloat.random(in: 0.5...1.0),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
                for i in particles.indices {
                    particles[i].position = CGPoint(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...700)
                    )
                    particles[i].scale = CGFloat.random(in: 0.5...1.0)
                    particles[i].opacity = Double.random(in: 0.3...0.8)
                }
            }
        }
    }
}

struct GenerationStepRow: View {
    let step: String
    let isCompleted: Bool
    let isActive: Bool
    let animationDelay: Double
    
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Step indicator
            ZStack {
                Circle()
                    .fill(stepColor.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(stepColor)
                } else if isActive {
                    Circle()
                        .fill(stepColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(appeared ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: appeared)
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 12, height: 12)
                }
            }
            
            // Step text
            Text(step)
                .font(.subheadline)
                .foregroundColor(isCompleted || isActive ? .white : .white.opacity(0.6))
                .fontWeight(isActive ? .medium : .regular)
            
            Spacer()
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(animationDelay)) {
                appeared = true
            }
        }
    }
    
    private var stepColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .blue
        } else {
            return .white.opacity(0.3)
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var scale: CGFloat
    var opacity: Double
}

#Preview {
    GeneratingStepView(
        topic: "World War 2",
        progress: .constant(0.6)
    )
} 