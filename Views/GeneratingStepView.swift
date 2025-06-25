//
//  GeneratingStepView.swift
//  Learny
//

import SwiftUI

struct GeneratingStepView: View {
    let topic: String
    let progress: Double
    
    @State private var animationPhase: Double = 0
    @State private var sparklePositions: [CGPoint] = []
    @State private var showSparkles: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Main Animation Section
            VStack(spacing: 32) {
                // Animated AI Brain
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(1 + sin(animationPhase * 2) * 0.1)
                    
                    // Middle ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(1 + sin(animationPhase * 2.5 + .pi) * 0.08)
                    
                    // Core circle with brain icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(1 + sin(animationPhase * 3) * 0.05)
                    }
                }
                .shadow(color: .purple.opacity(0.3), radius: 20, y: 10)
                .overlay(
                    // Floating sparkles
                    ForEach(0..<8, id: \.self) { index in
                        if showSparkles {
                            Image(systemName: "sparkle")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.title2)
                                .position(sparklePositions.indices.contains(index) ? sparklePositions[index] : CGPoint(x: 50, y: 50))
                                .opacity(sin(animationPhase * 2 + Double(index) * 0.5) > 0 ? 0.8 : 0.3)
                                .scaleEffect(sin(animationPhase * 2 + Double(index) * 0.5) > 0 ? 1.2 : 0.8)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationPhase)
                        }
                    }
                )
                
                // Title and Status
                VStack(spacing: 16) {
                    Text("Creating your personalized course")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Our AI is analyzing your preferences and crafting the perfect learning path for **\(topic)**")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            // Progress Section
            VStack(spacing: 24) {
                // Progress Bar
                VStack(spacing: 12) {
                    HStack {
                        Text("Progress")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.7 * progress, height: 8)
                            .animation(.easeInOut(duration: 0.5), value: progress)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.7)
                }
                
                // Status Messages
                VStack(spacing: 8) {
                    ForEach(getStatusMessages(), id: \.self) { message in
                        HStack(spacing: 12) {
                            if shouldShowCheckmark(for: message) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                            } else if shouldShowSpinner(for: message) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                            
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(getMessageColor(for: message))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .onAppear {
            setupSparklePositions()
            startAnimations()
        }
    }
    
    private func setupSparklePositions() {
        sparklePositions = (0..<8).map { index in
            let angle = Double(index) * .pi / 4
            let radius: Double = 80
            let x = 70 + cos(angle) * radius
            let y = 70 + sin(angle) * radius
            return CGPoint(x: x, y: y)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showSparkles = true
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }
    
    private func getStatusMessages() -> [String] {
        [
            "Analyzing your learning preferences",
            "Selecting relevant topics and concepts",
            "Structuring optimal lesson sequence",
            "Generating personalized content",
            "Finalizing your custom course"
        ]
    }
    
    private func shouldShowCheckmark(for message: String) -> Bool {
        let messages = getStatusMessages()
        guard let index = messages.firstIndex(of: message) else { return false }
        let threshold = Double(index + 1) / Double(messages.count)
        return progress >= threshold
    }
    
    private func shouldShowSpinner(for message: String) -> Bool {
        let messages = getStatusMessages()
        guard let index = messages.firstIndex(of: message) else { return false }
        let threshold = Double(index + 1) / Double(messages.count)
        let previousThreshold = Double(index) / Double(messages.count)
        return progress >= previousThreshold && progress < threshold
    }
    
    private func getMessageColor(for message: String) -> Color {
        if shouldShowCheckmark(for: message) {
            return .white
        } else if shouldShowSpinner(for: message) {
            return .white.opacity(0.9)
        } else {
            return .white.opacity(0.5)
        }
    }
}

#Preview {
    GeneratingStepView(topic: "Personal Finance", progress: 0.6)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.05, blue: 0.2),
                    Color(red: 0.05, green: 0.1, blue: 0.3),
                    Color(red: 0.08, green: 0.15, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
} 