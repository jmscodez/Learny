//
//  TimeCommitmentStepView.swift
//  Learny
//

import SwiftUI

struct TimeCommitmentStepView: View {
    @Binding var minutesPerLesson: Int
    @Binding var studyFrequency: String
    let onNext: () -> Void
    
    @State private var showContinueButton = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header - Fixed at top
                VStack(spacing: 16) {
                    Text("How much time can you commit?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Help us create lessons that fit your schedule perfectly")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Spacer for visual balance
                        Spacer()
                            .frame(height: 20)
                        
                        // Minutes per lesson
                        VStack(spacing: 16) {
                            HStack {
                                Text("Minutes per lesson")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(minutesPerLesson) min")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            // Slider
                            VStack(spacing: 8) {
                                Slider(value: Binding(
                                    get: { Double(minutesPerLesson) },
                                    set: { minutesPerLesson = Int($0) }
                                ), in: 5...60, step: 5)
                                .accentColor(.blue)
                                
                                HStack {
                                    Text("5")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("15")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("30")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("45")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("60")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                        
                        // Study frequency
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Study frequency")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                FrequencyOption(
                                    icon: "calendar",
                                    title: "Daily",
                                    subtitle: "Consistent daily progress",
                                    isSelected: studyFrequency == "daily",
                                    color: .green
                                ) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        studyFrequency = "daily"
                                        showContinueButton = true
                                    }
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }
                                
                                FrequencyOption(
                                    icon: "calendar.badge.clock",
                                    title: "Few times a week",
                                    subtitle: "Flexible learning schedule",
                                    isSelected: studyFrequency == "few_times_week",
                                    color: .blue
                                ) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        studyFrequency = "few_times_week"
                                        showContinueButton = true
                                    }
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }
                                
                                FrequencyOption(
                                    icon: "calendar.badge.plus",
                                    title: "Weekly",
                                    subtitle: "Weekly focused sessions",
                                    isSelected: studyFrequency == "weekly",
                                    color: .orange
                                ) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        studyFrequency = "weekly"
                                        showContinueButton = true
                                    }
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }
                                
                                FrequencyOption(
                                    icon: "clock.arrow.2.circlepath",
                                    title: "Flexible",
                                    subtitle: "Learn at your own pace",
                                    isSelected: studyFrequency == "flexible",
                                    color: .purple
                                ) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        studyFrequency = "flexible"
                                        showContinueButton = true
                                    }
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }
                            }
                        }
                        
                        // Bottom padding to ensure content doesn't get cut off
                        Spacer()
                            .frame(height: showContinueButton ? 120 : 60)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Fixed Continue Button at bottom
                if showContinueButton {
                    VStack(spacing: 0) {
                        // Gradient overlay to blend with content
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.clear, location: 0),
                                .init(color: Color.black.opacity(0.1), location: 0.5),
                                .init(color: Color.black.opacity(0.3), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)
                        
                        Button(action: onNext) {
                            HStack {
                                Text("Continue")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                        .background(
                            // Background to ensure button visibility
                            Rectangle()
                                .fill(Color.black.opacity(0.2))
                                .blur(radius: 20)
                        )
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
            }
        }
    }
}

struct FrequencyOption: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? color : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : color)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? color : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    TimeCommitmentStepView(
        minutesPerLesson: .constant(15),
        studyFrequency: .constant("daily")
    ) {
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