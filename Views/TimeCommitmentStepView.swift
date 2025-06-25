//
//  TimeCommitmentStepView.swift
//  Learny
//

import SwiftUI

struct TimeCommitmentStepView: View {
    @Binding var selectedTime: Int
    @Binding var selectedFrequency: String
    let onContinue: () -> Void
    
    @State private var animationProgress: Double = 0
    
    private let timeOptions = [5, 10, 15, 20, 30, 45, 60]
    private let frequencyOptions = [
        FrequencyOption(id: "daily", title: "Daily", description: "Consistent daily progress", icon: "calendar", color: .green),
        FrequencyOption(id: "few-times-week", title: "Few times a week", description: "Flexible learning schedule", icon: "calendar.badge.clock", color: .blue),
        FrequencyOption(id: "weekly", title: "Weekly", description: "Weekly focused sessions", icon: "calendar.badge.plus", color: .orange),
        FrequencyOption(id: "flexible", title: "Flexible", description: "Learn at my own pace", icon: "clock.arrow.circlepath", color: .purple)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                headerSection
                timeSection
                frequencySection
                
                Spacer(minLength: 40)
                continueButton
                Spacer(minLength: 60)
            }
        }
        .onAppear {
            if selectedTime == 0 {
                selectedTime = 15 // Default to 15 minutes
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("How much time can you commit?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaleEffect(animationProgress)
                .opacity(animationProgress)
            
            Text("Help us create lessons that fit your schedule perfectly")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(animationProgress)
        }
    }
    
    private var timeSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Minutes per lesson")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text("\(selectedTime) min")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .opacity(animationProgress)
            
            timeSliderSection
        }
    }
    
    private var timeSliderSection: some View {
        VStack(spacing: 12) {
            Slider(
                value: Binding(
                    get: { Double(selectedTime) },
                    set: { selectedTime = Int($0) }
                ),
                in: 5...60,
                step: 5
            ) {
                Text("Lesson Duration")
            }
            .accentColor(.blue)
            .opacity(animationProgress)
            
            timeMarkers
        }
        .padding(.horizontal, 20)
    }
    
    private var timeMarkers: some View {
        HStack {
            ForEach([5, 15, 30, 45, 60], id: \.self) { time in
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 2, height: 8)
                    Text("\(time)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                if time != 60 { Spacer() }
            }
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var frequencySection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Study frequency")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .opacity(animationProgress)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(frequencyOptions.enumerated()), id: \.element.id) { index, option in
                    FrequencyCard(
                        option: option,
                        isSelected: selectedFrequency == option.id,
                        animationDelay: Double(index) * 0.1
                    ) {
                        withAnimation(.spring()) {
                            selectedFrequency = option.id
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var continueButton: some View {
        if !selectedFrequency.isEmpty {
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

struct FrequencyOption: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct FrequencyCard: View {
    let option: FrequencyOption
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            option.color :
                            option.color.opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                    
                    Image(systemName: option.icon)
                        .font(.title3)
                        .foregroundColor(
                            isSelected ? .white : option.color
                        )
                }
                .animation(.spring(), value: isSelected)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(option.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? option.color : .white.opacity(0.3))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(), value: isSelected)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        option.color.opacity(0.1) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                option.color.opacity(0.5) :
                                Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? option.color.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0,
                y: isSelected ? 4 : 0
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
    TimeCommitmentStepView(
        selectedTime: .constant(15),
        selectedFrequency: .constant("daily")
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