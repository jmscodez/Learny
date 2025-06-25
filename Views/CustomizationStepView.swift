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
                    VStack(spacing: 24) {
                        Spacer(minLength: 16)
                        
                        headerSection
                        compactCourseStatsSection
                        selectedLessonsPreview
                        lessonGridSection
                        
                        Spacer(minLength: 100) // Space for fixed generate button
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
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Your Course is Ready!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .scaleEffect(animationProgress)
            .opacity(animationProgress)
            
            Text("We've crafted **\(viewModel.suggestedLessons.count) personalized lessons** based on your preferences.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .opacity(animationProgress)
        }
    }
    
    private var compactCourseStatsSection: some View {
        HStack(spacing: 12) {
            CompactStatCard(
                icon: "book.fill",
                title: "Lessons",
                value: "\(selectedCount)/\(viewModel.suggestedLessons.count)",
                color: .blue
            )
            
            CompactStatCard(
                icon: "clock.fill",
                title: "Est. Time",
                value: formatTime(totalEstimatedTime),
                color: .green
            )
            
            CompactStatCard(
                icon: "target",
                title: "Progress",
                value: selectedCount > 0 ? "Ready" : "Select",
                color: .purple
            )
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var selectedLessonsPreview: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Selected Lessons")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(selectedCount) lessons • \(formatTime(totalEstimatedTime))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            if selectedCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.selectedLessons.prefix(3), id: \.id) { lesson in
                            SelectedLessonChip(lesson: lesson)
                        }
                        
                        if selectedCount > 3 {
                            Text("+\(selectedCount - 3) more")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                Text("Select lessons below to get started")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .italic()
            }
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var lessonGridSection: some View {
        VStack(spacing: 16) {
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
            
            HStack(spacing: 8) {
                FloatingActionButton(
                    icon: "plus.circle.fill",
                    text: "Generate More",
                    colors: [.purple, .blue],
                    action: { showingGenerateOptions = true }
                )
                
                showAllButton
            }
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var showAllButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showingAllLessons.toggle()
            }
        }) {
            HStack(spacing: 6) {
                Text(showingAllLessons ? "Show Less" : "Show All")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .rotationEffect(.degrees(showingAllLessons ? 180 : 0))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private var lessonGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
            ForEach(displayedLessons.indices, id: \.self) { index in
                let lesson = displayedLessons[index]
                LessonSelectionCard(
                    lesson: lesson,
                    isSelected: viewModel.selectedLessons.contains { $0.id == lesson.id },
                    onToggle: { toggleLessonSelection(lesson) },
                    onShowDetail: { onShowDetail(lesson) }
                )
                .opacity(animationProgress)
                .offset(y: animationProgress == 1.0 ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animationProgress)
            }
        }
        .padding(.horizontal, 20)
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
    
    private var generateCourseButtonSection: some View {
        VStack(spacing: 12) {
            if selectedCount > 0 {
                // Course summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(selectedCount) lessons selected")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Estimated time: \(formatTime(totalEstimatedTime))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: onFinalize) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.headline)
                            
                            Text("Generate Course")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple, .green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(animationProgress)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                        .background(Color.black.opacity(0.3))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            } else {
                Text("Select at least one lesson to continue")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 34)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func toggleLessonSelection(_ lesson: LessonSuggestion) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == lesson.id }) {
                viewModel.suggestedLessons[index].isSelected.toggle()
            }
        }
    }
    
    private func generateMoreLessons() {
        isGeneratingMore = true
        
        Task {
            await viewModel.generateAdditionalLessons()
            await MainActor.run {
                withAnimation(.spring()) {
                    isGeneratingMore = false
                }
            }
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

struct CompactStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SelectedLessonChip: View {
    let lesson: LessonSuggestion
    
    var body: some View {
        Text(lesson.title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct FloatingActionButton: View {
    let icon: String
    let text: String
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: colors.first?.opacity(0.4) ?? .clear, radius: 8, x: 0, y: 4)
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: true)
    }
}

struct LessonSelectionCard: View {
    let lesson: LessonSuggestion
    let isSelected: Bool
    let onToggle: () -> Void
    let onShowDetail: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.green : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                // Lesson content
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Info button
                Button(action: onShowDetail) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.green.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Legacy Compatibility

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        CompactStatCard(icon: icon, title: title, value: value, color: color)
    }
}

// MARK: - AI Chat Modal

struct AIChatModalView: View {
    let topic: String
    let onGenerateMore: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Chat with AI about \(topic)")
                    .font(.title2)
                    .padding()
                
                Spacer()
                
                Button("Generate More Lessons", action: onGenerateMore)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done", action: onClose))
        }
    }
} 