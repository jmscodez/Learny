//
//  CustomizationStepView.swift
//  Learny
//

import SwiftUI

struct CustomizationStepView: View {
    @ObservedObject var viewModel: EnhancedCourseChatViewModel
    let onShowDetail: (LessonSuggestion) -> Void
    let onFinalize: () -> Void
    
    @State private var animationProgress: Double = 0
    @State private var showingAllLessons = false
    
    var selectedCount: Int {
        viewModel.selectedLessons.count
    }
    
    var displayedLessons: [LessonSuggestion] {
        showingAllLessons ? viewModel.suggestedLessons : Array(viewModel.suggestedLessons.prefix(6))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                // Header Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Your Course is Ready!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animationProgress)
                    .opacity(animationProgress)
                    
                    Text("We've crafted **\(viewModel.suggestedLessons.count) personalized lessons** based on your preferences. Select the ones you're excited about!")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(animationProgress)
                }
                
                // Course Summary Card
                CourseStatsCard(
                    selectedCount: selectedCount,
                    totalCount: viewModel.suggestedLessons.count,
                    estimatedTime: selectedCount * viewModel.preferredLessonTime,
                    animationProgress: animationProgress
                )
                .padding(.horizontal, 20)
                
                // Lesson Grid
                VStack(spacing: 20) {
                    // Section Header
                    HStack {
                        Text("Choose Your Lessons")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if viewModel.suggestedLessons.count > 6 {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showingAllLessons.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(showingAllLessons ? "Show Less" : "Show All")
                                        .font(.subheadline)
                                    Image(systemName: showingAllLessons ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(animationProgress)
                    
                    // Lessons
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 16
                    ) {
                        ForEach(Array(displayedLessons.enumerated()), id: \.element.id) { index, lesson in
                            PersonalizedLessonCard(
                                lesson: binding(for: lesson),
                                animationDelay: Double(index) * 0.05,
                                onShowDetail: { onShowDetail(lesson) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Finalize Button
                    if selectedCount > 0 {
                        Button(action: onFinalize) {
                            HStack(spacing: 12) {
                                Text("Create Course (\(selectedCount) lessons)")
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
                    
                    // Helper Text
                    Text("Select at least 3 lessons to create your course")
                        .font(.caption)
                        .foregroundColor(.white.opacity(selectedCount >= 3 ? 0.6 : 0.8))
                        .opacity(animationProgress)
                }
                
                Spacer(minLength: 60)
            }
        }
        .onAppear {
            // Auto-select the first few lessons if none are selected
            if viewModel.selectedLessons.isEmpty && !viewModel.suggestedLessons.isEmpty {
                let autoSelectCount = min(4, viewModel.suggestedLessons.count)
                for i in 0..<autoSelectCount {
                    viewModel.suggestedLessons[i].isSelected = true
                }
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func binding(for lesson: LessonSuggestion) -> Binding<LessonSuggestion> {
        guard let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == lesson.id }) else {
            return .constant(lesson)
        }
        return $viewModel.suggestedLessons[index]
    }
}

struct CourseStatsCard: View {
    let selectedCount: Int
    let totalCount: Int
    let estimatedTime: Int
    let animationProgress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Course Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "book.fill",
                    title: "Lessons",
                    value: "\(selectedCount)/\(totalCount)",
                    color: .blue
                )
                
                StatItem(
                    icon: "clock.fill",
                    title: "Est. Time",
                    value: "\(estimatedTime) min",
                    color: .green
                )
                
                StatItem(
                    icon: "target",
                    title: "Progress",
                    value: "\(Int(Double(selectedCount) / Double(totalCount) * 100))%",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(animationProgress)
        .opacity(animationProgress)
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PersonalizedLessonCard: View {
    @Binding var lesson: LessonSuggestion
    let animationDelay: Double
    let onShowDetail: () -> Void
    
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    
    private var backgroundColor: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(lesson.isSelected ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        lesson.isSelected ? Color.green.opacity(0.5) : Color.white.opacity(0.2),
                        lineWidth: lesson.isSelected ? 2 : 1
                    )
            )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with selection
            HStack {
                Button(action: {
                    withAnimation(.spring()) {
                        lesson.isSelected.toggle()
                    }
                }) {
                    Image(systemName: lesson.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(lesson.isSelected ? .green : .white.opacity(0.5))
                }
                
                Spacer()
                
                Button(action: onShowDetail) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.blue.opacity(0.8))
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(lesson.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Lesson details
                HStack {
                    Label(lesson.estimatedMinutes, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    if lesson.hasPractice {
                        Label("Interactive", systemImage: "gamecontroller")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(minHeight: 140)
        .background(backgroundColor)
        .scaleEffect(lesson.isSelected ? 1.02 : 1.0)
        .shadow(
            color: lesson.isSelected ? Color.green.opacity(0.3) : .clear,
            radius: lesson.isSelected ? 8 : 0,
            y: lesson.isSelected ? 4 : 0
        )
        .animation(.spring(), value: lesson.isSelected)
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
    CustomizationStepView(
        viewModel: EnhancedCourseChatViewModel(
            topic: "Personal Finance",
            difficulty: .beginner,
            pace: .balanced
        ),
        onShowDetail: { _ in print("Show detail") },
        onFinalize: { print("Finalize") }
    )
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