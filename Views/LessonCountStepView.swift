//
//  LessonCountStepView.swift
//  Learny
//

import SwiftUI

struct LessonCountStepView: View {
    @Binding var selectedLessonCount: Int
    let timeCommitment: Int
    let onContinue: () -> Void
    
    @State private var animationProgress: Double = 0
    
    // Calculate lesson range based on time commitment
    private var lessonRange: ClosedRange<Int> {
        switch timeCommitment {
        case 5...15:
            return 3...12  // Shorter lessons, more of them
        case 16...30:
            return 3...10  // Medium lessons
        case 31...45:
            return 3...8   // Longer lessons
        default:
            return 3...6   // Very long lessons
        }
    }
    
    private var recommendedCount: Int {
        return 7  // Always recommend 7 lessons
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top spacing for safe area
                Spacer(minLength: 20)
                
                // Header section - improved layout
                VStack(spacing: 16) {
                    Text("How many lessons would you like?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .scaleEffect(animationProgress)
                        .opacity(animationProgress)
                    
                    Text("Based on your \(timeCommitment)-minute sessions, we recommend \(recommendedCount) lessons")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .opacity(animationProgress)
                    
                    // Enhanced info message
                    HStack(spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                        
                        Text("Don't worry - you can always generate more lessons later!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                    )
                    .opacity(animationProgress)
                }
                .padding(.horizontal, 20)
                
                // Lesson count selection
                VStack(spacing: 28) {
                    // Visual lesson count display - smaller to save space
                    VStack(spacing: 12) {
                        Text("\(selectedLessonCount)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.blue)
                            .scaleEffect(animationProgress)
                        
                        Text("lessons")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(animationProgress)
                    }
                    
                    // Slider
                    VStack(spacing: 16) {
                        Slider(
                            value: Binding(
                                get: { Double(selectedLessonCount) },
                                set: { selectedLessonCount = Int($0) }
                            ),
                            in: Double(lessonRange.lowerBound)...Double(lessonRange.upperBound),
                            step: 1
                        )
                        .accentColor(.blue)
                        .scaleEffect(animationProgress)
                        
                        // Range labels
                        HStack {
                            VStack {
                                Text("\(lessonRange.lowerBound)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("minimum")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(recommendedCount)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                Text("recommended")
                                    .font(.caption2)
                                    .foregroundColor(.blue.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(lessonRange.upperBound)+")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("maximum")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .opacity(animationProgress)
                    }
                    .padding(.horizontal, 40)
                    
                    // Quick selection buttons - uniform sizing
                    HStack(spacing: 12) {
                        ForEach([3, 7, 12], id: \.self) { count in
                            Button(action: { 
                                withAnimation(.spring()) {
                                    selectedLessonCount = count
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text("\(count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(getLabelFor(count: count))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(selectedLessonCount == count ? .white : .white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedLessonCount == count ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedLessonCount == count ? .blue : .white.opacity(0.2), lineWidth: selectedLessonCount == count ? 2 : 1)
                                        )
                                )
                            }
                            .scaleEffect(selectedLessonCount == count ? 1.02 : 1.0)
                            .animation(.spring(), value: selectedLessonCount)
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(animationProgress)
                }
                
                // Continue button
                Button(action: onContinue) {
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
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(animationProgress)
                .padding(.horizontal, 20)
                
                // Bottom spacing
                Spacer(minLength: 20)
            }
        }
        .onAppear {
            // Always set initial value to 7
            selectedLessonCount = 7
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func getLabelFor(count: Int) -> String {
        switch count {
        case 3:
            return "Quick"
        case 7:
            return "Recommended"
        case 12:
            return "Comprehensive"
        default:
            return "Custom"
        }
    }
}

#Preview {
    LessonCountStepView(
        selectedLessonCount: .constant(5),
        timeCommitment: 20,
        onContinue: {}
    )
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.15, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 