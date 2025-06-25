//
//  ExperienceStepView.swift
//  Learny
//

import SwiftUI

struct ExperienceStepView: View {
    @Binding var selectedExperience: String
    let onContinue: () -> Void
    
    @State private var animationProgress: Double = 0
    
    private let experienceLevels = [
        ExperienceLevel(
            id: "complete-beginner",
            title: "Complete Beginner",
            description: "I'm just starting out with this topic",
            icon: "star.fill",
            color: .green,
            details: "Perfect for those with little to no prior knowledge"
        ),
        ExperienceLevel(
            id: "some-knowledge",
            title: "Some Knowledge",
            description: "I have basic understanding but want to learn more",
            icon: "star.leadinghalf.filled",
            color: .blue,
            details: "Great for building on existing foundations"
        ),
        ExperienceLevel(
            id: "intermediate",
            title: "Intermediate",
            description: "I have solid fundamentals and want to go deeper",
            icon: "star.circle.fill",
            color: .orange,
            details: "Ready for more advanced concepts and applications"
        ),
        ExperienceLevel(
            id: "advanced",
            title: "Advanced",
            description: "I want to master specific areas or stay updated",
            icon: "crown.fill",
            color: .purple,
            details: "Focused on expertise and cutting-edge knowledge"
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header - Fixed height
                headerSection
                    .frame(height: geometry.size.height * 0.2)
                
                // Experience levels - Flexible space
                experienceLevelsSection
                    .frame(maxHeight: .infinity)
                
                // Continue button - Fixed at bottom
                if !selectedExperience.isEmpty {
                    continueButton
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("What's your experience level?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaleEffect(animationProgress)
                .opacity(animationProgress)
            
            Text("This helps us tailor the course complexity and pace")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(animationProgress)
        }
        .padding(.top, 20)
    }
    
    private var experienceLevelsSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(experienceLevels.enumerated()), id: \.element.id) { index, level in
                ExperienceLevelCard(
                    level: level,
                    isSelected: selectedExperience == level.id,
                    animationDelay: Double(index) * 0.1
                ) {
                    withAnimation(.spring()) {
                        selectedExperience = level.id
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var continueButton: some View {
        if !selectedExperience.isEmpty {
            Button(action: onContinue) {
                HStack(spacing: 12) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .purple.opacity(0.4), radius: 15, y: 8)
            }
            .scaleEffect(animationProgress)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct ExperienceLevel: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let details: String
}

struct ExperienceLevelCard: View {
    let level: ExperienceLevel
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    @State private var animationOffset: CGFloat = 50
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon Section
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? 
                            level.color : 
                            level.color.opacity(0.2)
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                    
                    Image(systemName: level.icon)
                        .font(.title2)
                        .foregroundColor(
                            isSelected ? .white : level.color
                        )
                }
                .animation(.spring(), value: isSelected)
                
                // Content Section
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(level.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    Text(level.details)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? level.color : .white.opacity(0.3))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(), value: isSelected)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ?
                        level.color.opacity(0.1) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? 
                                level.color.opacity(0.5) : 
                                Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? level.color.opacity(0.3) : .clear,
                radius: isSelected ? 10 : 0,
                y: isSelected ? 5 : 0
            )
            .animation(.spring(), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: animationOffset)
        .opacity(animationOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(animationDelay)) {
                animationOffset = 0
                animationOpacity = 1
            }
        }
    }
}

#Preview {
    ExperienceStepView(selectedExperience: .constant("some-knowledge")) {
        print("Continue tapped")
    }
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