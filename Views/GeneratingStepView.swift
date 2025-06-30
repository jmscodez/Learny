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
    
    var body: some View {
        ZStack {
            // App's signature gradient background
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
            
            // Enhanced floating particles
            ForEach(particles.indices, id: \.self) { index in
                let particle = particles[index]
                Group {
                    if index % 4 == 0 {
                        // Star particles
                        Image(systemName: "sparkle")
                            .font(.system(size: particle.size))
                            .foregroundColor(particle.color)
                            .opacity(particle.opacity)
                            .scaleEffect(particle.scale)
                            .position(particle.position)
                            .animation(
                                .easeInOut(duration: particle.duration)
                                .repeatForever(autoreverses: true)
                                .delay(particle.delay),
                                value: pulseAnimation
                            )
                    } else {
                        // Geometric particles
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
            }
            
            VStack(spacing: 20) {
                Spacer()
                
                titleSection
                
                progressSection
                
                enhancedProgressBar
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
            setupLoadingParticles()
            startLoadingAnimations()
        }
        .onChange(of: progress) { newProgress in
            updateCurrentStep(for: newProgress)
        }
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
        particles = (0..<20).map { i in
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
    
    private func startLoadingAnimations() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func updateCurrentStep(for progress: Double) {
        let newStep = min(Int(progress * 5), 4) // 5 steps total
        if newStep != currentStep {
            withAnimation(.spring()) {
                currentStep = newStep
            }
        }
    }
}

// MARK: - Particle System Models
// LoadingParticle is defined in InterestsStepView.swift

#Preview {
    GeneratingStepView(
        topic: "World War 2",
        selectedLessons: [],
        progress: .constant(0.6),
        isVisible: .constant(true),
        isFrozen: false,
        onComplete: {},
        onCancel: {}
    )
} 