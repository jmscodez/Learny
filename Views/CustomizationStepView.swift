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
    @State private var showingGenerateOptions = false
    @State private var isGeneratingMore = false
    @State private var showingAIChatModal = false
    
    var selectedCount: Int {
        viewModel.selectedLessons.count
    }
    
    var totalEstimatedTime: Int {
        selectedCount * viewModel.preferredLessonTime
    }
    
    var displayedLessons: [LessonSuggestion] {
        showingAllLessons ? viewModel.suggestedLessons : Array(viewModel.suggestedLessons.prefix(6))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 20)
                        
                        headerSection
                        courseStatsSection
                        lessonGridSection
                        
                        Spacer(minLength: 120) // Space for fixed generate button
                    }
                }
                
                // Fixed Generate Course Button at bottom
                VStack {
                    Spacer()
                    generateCourseButtonSection
                }
            }
        }
        .sheet(isPresented: $showingAIChatModal) {
            AIChatModalView(
                topic: viewModel.topic,
                onGenerateMore: { generateMoreLessons() },
                onClose: { showingAIChatModal = false }
            )
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
    
    private var headerSection: some View {
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
    }
    
    private var courseStatsSection: some View {
        VStack(spacing: 16) {
            Text("Course Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatCard(
                    icon: "book.fill",
                    title: "Lessons",
                    value: "\(selectedCount)/\(viewModel.suggestedLessons.count)",
                    color: .blue
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Est. Time",
                    value: formatTime(totalEstimatedTime),
                    color: .green
                )
                
                StatCard(
                    icon: "target",
                    title: "Progress",
                    value: selectedCount > 0 ? "Ready" : "0%",
                    color: .purple
                )
            }
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var lessonGridSection: some View {
        VStack(spacing: 20) {
            lessonSectionHeader
            lessonGrid
        }
    }
    
    private var lessonSectionHeader: some View {
        HStack {
            Text("Choose Your Lessons")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 12) {
                generateMoreButton
                showAllButton
            }
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var generateMoreButton: some View {
        Button(action: {
            showingGenerateOptions = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Generate More")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .alert("Generate More Lessons", isPresented: $showingGenerateOptions) {
            Button("💬 AI Chat for Ideas") {
                showingAIChatModal = true
            }
            Button("🚀 Auto Generate") {
                generateMoreLessons()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to chat with AI for personalized ideas, or automatically generate lessons based on your preferences?")
        }
    }
    
    @ViewBuilder
    private var showAllButton: some View {
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
    
    private var lessonGrid: some View {
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
    
    private var generateCourseButtonSection: some View {
        VStack(spacing: 0) {
            // Gradient overlay to blend with content
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0),
                    .init(color: Color.black.opacity(0.2), location: 0.7),
                    .init(color: Color.black.opacity(0.4), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            
            VStack(spacing: 16) {
                // Course summary
                if selectedCount > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ready to Generate")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("\(selectedCount) lessons • ~\(formatTime(totalEstimatedTime))")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Generate button
                Button(action: onFinalize) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.headline)
                        
                        Text("Generate Course")
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
                            gradient: Gradient(colors: selectedCount > 0 ? [.green, .blue] : [.gray, .gray.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: selectedCount > 0 ? .green.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
                .disabled(selectedCount == 0)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .blur(radius: 20)
            )
        }
    }
    
    private func binding(for lesson: LessonSuggestion) -> Binding<LessonSuggestion> {
        guard let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == lesson.id }) else {
            return .constant(lesson)
        }
        return $viewModel.suggestedLessons[index]
    }
    
    private func generateMoreLessons() {
        // Implementation for generating more lessons
        Task {
            isGeneratingMore = true
            // Add your lesson generation logic here
            await viewModel.generateAdditionalLessons()
            isGeneratingMore = false
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AIChatModalView: View {
    let topic: String
    let onGenerateMore: () -> Void
    let onClose: () -> Void
    
    @State private var chatInput = ""
    @State private var chatMessages: [ChatMessage] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Chat interface would go here
                VStack {
                    Spacer()
                    
                    Text("💬 AI Chat for Lesson Ideas")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Chat with AI to get personalized lesson suggestions for your \(topic) course")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    Button("Generate Ideas") {
                        onGenerateMore()
                        onClose()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    onClose()
                }
            )
        }
    }
}

struct PersonalizedLessonCard: View {
    @Binding var lesson: LessonSuggestion
    let animationDelay: Double
    let onShowDetail: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: { lesson.isSelected.toggle() }) {
                    Image(systemName: lesson.isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(lesson.isSelected ? .green : .gray)
                }
                
                Spacer()
                
                Button(action: onShowDetail) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            
            Text(lesson.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(lesson.shortDescription)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(3)
            
            Text(lesson.estimatedMinutes)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lesson.isSelected ? Color.green : Color.clear, lineWidth: 2)
        )
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