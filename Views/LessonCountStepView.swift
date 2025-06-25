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
        let mid = (lessonRange.lowerBound + lessonRange.upperBound) / 2
        return mid
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header - Fixed height
                VStack(spacing: 12) {
                    Text("How many lessons would you like?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .scaleEffect(animationProgress)
                        .opacity(animationProgress)
                    
                    Text("Based on your \(timeCommitment)-minute sessions, we recommend \(recommendedCount) lessons")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(animationProgress)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .frame(height: geometry.size.height * 0.25)
                
                // Lesson count selection - Flexible space
                VStack(spacing: 32) {
                    // Visual lesson count display
                    VStack(spacing: 16) {
                        Text("\(selectedLessonCount)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.blue)
                            .scaleEffect(animationProgress)
                        
                        Text("lessons")
                            .font(.title2)
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
                    
                    // Quick selection buttons
                    HStack(spacing: 12) {
                        ForEach([lessonRange.lowerBound, recommendedCount, lessonRange.upperBound], id: \.self) { count in
                            Button(action: { 
                                withAnimation(.spring()) {
                                    selectedLessonCount = count
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text("\(count)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text(getLabelFor(count: count))
                                        .font(.caption2)
                                }
                                .foregroundColor(selectedLessonCount == count ? .white : .white.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedLessonCount == count ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedLessonCount == count ? .blue : .white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            .scaleEffect(selectedLessonCount == count ? 1.05 : 1.0)
                            .animation(.spring(), value: selectedLessonCount)
                        }
                    }
                    .opacity(animationProgress)
                }
                .frame(maxHeight: .infinity)
                
                // Continue button - Fixed at bottom
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
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Set initial value to recommended
            if selectedLessonCount == 0 {
                selectedLessonCount = recommendedCount
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func getLabelFor(count: Int) -> String {
        if count == lessonRange.lowerBound {
            return "Quick"
        } else if count == recommendedCount {
            return "Recommended"
        } else {
            return "Comprehensive"
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