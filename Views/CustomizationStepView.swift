//
//  CustomizationStepView.swift
//  Learny
//

import SwiftUI

struct CustomizationStepView: View {
    @ObservedObject var viewModel: EnhancedCourseChatViewModel
    let onShowDetail: (LessonSuggestion) -> Void
    let onFinalize: () -> Void
    
    @State private var animationProgress: Double = 0.0
    @State private var showingAIChatModal = false
    @State private var isGeneratingMore = false
    @State private var showingGenerateOptions = false
    @State private var showingLessonInfo = false
    @State private var selectedLessonForInfo: LessonSuggestion?
    @State private var showingLessonValidationPopup = false
    
    var selectedCount: Int {
        viewModel.selectedLessons.count
    }
    
    var totalEstimatedTime: Int {
        selectedCount * viewModel.preferredLessonTime
    }
    
    var displayedLessons: [LessonSuggestion] {
        // Always show all lessons, no filtering
        viewModel.suggestedLessons
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 16)
                        
                        headerSection
                        
                        // NEW: Prominent AI Chat Button
                        aiCustomLessonButton
                        
                        selectedLessonsPreview
                        lessonGridSection
                        
                        // Extra space for bottom button - increased to prevent overlap
                        Spacer(minLength: 140)
                    }
                }
                
                // Fixed Generate Course Section at bottom
                VStack {
                    Spacer()
                    generateCourseButtonSection
                }
            }
        }
        .onAppear {
            // Ensure all lessons start unchecked when first entering this view
            for index in viewModel.suggestedLessons.indices {
                viewModel.suggestedLessons[index].isSelected = false
            }
            
            withAnimation(.easeInOut(duration: 2.0)) {
                animationProgress = 1.0
            }
        }
        .sheet(isPresented: $showingAIChatModal) {
            ChatOverlayView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingLessonInfo) {
            if let lesson = selectedLessonForInfo {
                NavigationView {
                    LessonInfoModal(lesson: lesson)
                }
                .presentationDetents([.large])
                .presentationBackground(.regularMaterial)
            }
        }
        .overlay(
            showingLessonValidationPopup ? 
            LessonCountValidationPopup(
                selectedCount: selectedCount,
                targetCount: viewModel.desiredLessonCount,
                onSelectMore: {
                    showingLessonValidationPopup = false
                    // User stays on this screen to select more lessons
                },
                onGenerateMore: {
                    showingLessonValidationPopup = false
                    handleGenerateMoreLessons()
                },
                onContinueWithCurrent: {
                    showingLessonValidationPopup = false
                    onFinalize()
                },
                onCancel: {
                    showingLessonValidationPopup = false
                }
            ) : nil
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Lessons")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Select from these AI-generated lessons or create custom ones")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
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
    
    private var aiCustomLessonButton: some View {
        Button(action: {
            showingAIChatModal = true
        }) {
            HStack(spacing: 16) {
                // AI Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Custom Lesson with AI")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Chat with AI to create personalized lessons")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.3),
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.6), .blue.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(animationProgress * 0.95 + 0.05)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
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
                        ForEach(Array(viewModel.selectedLessons.prefix(3)), id: \.id) { lesson in
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
            }
        }
        .padding(.horizontal, 20)
        .opacity(animationProgress)
    }
    
    private var lessonGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
            ForEach(displayedLessons.indices, id: \.self) { index in
                let lesson = displayedLessons[index]
                LessonCard(
                    lesson: Binding(
                        get: { viewModel.suggestedLessons.first { $0.id == lesson.id } ?? lesson },
                        set: { newValue in
                            if let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == lesson.id }) {
                                viewModel.suggestedLessons[index] = newValue
                            }
                        }
                    ),
                    onTap: { toggleLessonSelection(lesson) },
                    onInfo: { showLessonInfo(lesson) }
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
        VStack(spacing: 16) {
            if selectedCount > 0 {
                // Course summary (centered)
                VStack(spacing: 4) {
                    Text("\(selectedCount) lessons selected")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Est. time: \(formatTime(totalEstimatedTime))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Generate Course button (primary, prominent)
                Button(action: handleGenerateCourse) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                        
                        Text("Generate Course")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple, .green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .scaleEffect(animationProgress)
                
            } else {
                Text("Select at least one lesson to continue")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            // Clean gradient background that blends with the main background
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.05, green: 0.05, blue: 0.15).opacity(0.8),
                        Color(red: 0.08, green: 0.1, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)
                
                Color(red: 0.08, green: 0.1, blue: 0.2)
            }
        )
        .padding(.bottom, 0)
    }
    
    // MARK: - Helper Functions
    
    private func handleGenerateCourse() {
        let targetCount = viewModel.desiredLessonCount
        
        // Check if user has selected fewer lessons than their target
        if selectedCount < targetCount {
            showingLessonValidationPopup = true
        } else {
            // Proceed normally if they have enough lessons
            onFinalize()
        }
    }
    
    private func toggleLessonSelection(_ lesson: LessonSuggestion) {
        if let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == lesson.id }) {
            viewModel.suggestedLessons[index].isSelected.toggle()
        }
    }
    
    private func showLessonInfo(_ lesson: LessonSuggestion) {
        selectedLessonForInfo = lesson
        showingLessonInfo = true
    }
    
    private func generateMoreLessons() {
        isGeneratingMore = true
        Task {
            await viewModel.generateAdditionalLessons()
            await MainActor.run {
                isGeneratingMore = false
            }
        }
    }
    
    private func handleGenerateMoreLessons() {
        let targetCount = viewModel.desiredLessonCount
        let unselectedLessons = viewModel.suggestedLessons.filter { !$0.isSelected }
        let neededCount = targetCount - selectedCount
        
        // First, try to auto-select from existing unselected lessons
        if unselectedLessons.count >= neededCount {
            // Auto-select the needed lessons from unselected ones
            for i in 0..<neededCount {
                if let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == unselectedLessons[i].id }) {
                    viewModel.suggestedLessons[index].isSelected = true
                }
            }
            
            // Proceed to finalization
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onFinalize()
            }
        } else {
            // Generate more lessons if we don't have enough
            isGeneratingMore = true
            Task {
                // First select all remaining unselected lessons
                for lesson in unselectedLessons {
                    if let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == lesson.id }) {
                        viewModel.suggestedLessons[index].isSelected = true
                    }
                }
                
                await viewModel.generateAdditionalLessons()
                
                await MainActor.run {
                    isGeneratingMore = false
                    
                    // Auto-select newly generated lessons to reach target
                    let currentSelected = viewModel.selectedLessons.count
                    let stillNeeded = max(0, targetCount - currentSelected)
                    
                    if stillNeeded > 0 {
                        let unselected = viewModel.suggestedLessons.filter { !$0.isSelected }
                        for i in 0..<min(stillNeeded, unselected.count) {
                            if let index = viewModel.suggestedLessons.firstIndex(where: { $0.id == unselected[i].id }) {
                                viewModel.suggestedLessons[index].isSelected = true
                            }
                        }
                    }
                    
                    // Proceed to finalization
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onFinalize()
                    }
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

struct LessonCard: View {
    @Binding var lesson: LessonSuggestion
    let onTap: () -> Void
    let onInfo: () -> Void
    
    // Check if this is an AI-created lesson by looking for specific indicators
    private var isChatLesson: Bool {
        lesson.description.contains("AI Custom:") || lesson.title.contains("💬") || lesson.description.lowercased().contains("from ai chat")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                // Header with selection indicator and info button
                HStack {
                    // Enhanced AI-created lesson indicator
                    if isChatLesson {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            Text("AI Custom")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.cyan.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    // Enhanced info button
                    Button(action: onInfo) {
                        Image(systemName: isChatLesson ? "sparkles.rectangle.stack" : "info.circle")
                            .font(.subheadline)
                            .foregroundColor(isChatLesson ? .cyan : .blue)
                            .frame(width: 28, height: 28)
                            .background(isChatLesson ? Color.cyan.opacity(0.2) : Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Selection indicator
                    ZStack {
                        Circle()
                            .fill(lesson.isSelected ? Color.green : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(lesson.isSelected ? Color.green : Color.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        if lesson.isSelected {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Title (remove 💬 emoji for display)
                Text(lesson.title.replacingOccurrences(of: "💬 ", with: ""))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Description
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                
                // Footer with just lesson duration
                HStack {
                    Text(lesson.estimatedMinutes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        // Enhanced gradient for AI-created lessons
                        isChatLesson ? 
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.4),
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.2),
                                Color.cyan.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                // Enhanced border for AI-created lessons
                                isChatLesson ? 
                                LinearGradient(
                                    colors: [.cyan.opacity(0.8), .blue.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isChatLesson ? 2 : 1
                            )
                    )
            )
            .scaleEffect(lesson.isSelected ? 1.02 : 1.0)
            .shadow(
                color: isChatLesson ? Color.cyan.opacity(0.4) : Color.black.opacity(0.2),
                radius: lesson.isSelected ? 12 : (isChatLesson ? 8 : 4),
                y: lesson.isSelected ? 6 : (isChatLesson ? 4 : 2)
            )
        .onTapGesture {
            onTap()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: lesson.isSelected)
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

// MARK: - Enhanced Lesson Info Modal

struct LessonInfoModal: View {
    let lesson: LessonSuggestion
    @Environment(\.dismiss) private var dismiss
    @State private var animationProgress: Double = 0
    @State private var lessonData: EnhancedLessonData?
    @State private var isLoading: Bool = false
    @State private var hasAppeared: Bool = false
    
    // Check if this is an AI-created lesson
    private var isChatLesson: Bool {
        lesson.description.contains("AI Custom:") || lesson.title.contains("💬") || lesson.description.lowercased().contains("from ai chat")
    }
    
    // Clean title without emoji
    private var cleanTitle: String {
        lesson.title.replacingOccurrences(of: "💬 ", with: "")
    }
    
    // Initialize the modal with pre-generated data
    init(lesson: LessonSuggestion) {
        self.lesson = lesson
        // Pre-generate the data synchronously to avoid black screen
        let cleanTitle = lesson.title.replacingOccurrences(of: "💬 ", with: "")
        let safeDescription = lesson.description.isEmpty ? "Learn about \(cleanTitle)" : lesson.description
        let generatedData = LessonDataGenerator.generateEnhancedLessonData(
            for: cleanTitle,
            description: safeDescription
        )
        self._lessonData = State(initialValue: generatedData)
    }
    
    var body: some View {
        ZStack {
            // Fallback solid background
            Color.black
                .ignoresSafeArea()
            
            // Beautiful gradient background matching app theme
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let lessonData = lessonData {
                // Main content - data is pre-generated in init
                contentView(with: lessonData)
            } else {
                // Fallback - generate data on the fly if somehow missing
                Color.clear
                    .onAppear {
                        if !hasAppeared {
                            hasAppeared = true
                            loadLessonData()
                        }
                    }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func contentView(with data: EnhancedLessonData) -> some View {
        ZStack {
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Header Section
                    heroHeaderSection(with: data)
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Learning Objectives Card
                        learningObjectivesCard(with: data)
                        
                        // Lesson Details Card
                        lessonDetailsCard(with: data)
                        
                        // Topics Covered Card
                        topicsCoveredCard(with: data)
                        
                        // Prerequisites Card (if any)
                        if !data.prerequisites.isEmpty {
                            prerequisitesCard(with: data)
                        }
                        

                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            

        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
        .overlay(alignment: .topTrailing) {
            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .backdrop()
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
    }
    
    private func heroHeaderSection(with data: EnhancedLessonData) -> some View {
        VStack(spacing: 16) {
            // AI Custom Badge (if applicable)
            if isChatLesson {
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.cyan)
                        Text("AI Custom Lesson")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.cyan.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.cyan.opacity(0.6), lineWidth: 1)
                            )
                    )
                }
                .padding(.top, 60)
                .opacity(animationProgress)
            } else {
                Spacer()
                    .frame(height: isChatLesson ? 0 : 60)
            }
            
            // Lesson Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3),
                                Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: data.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(animationProgress * 1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animationProgress)
            
            // Title and Duration
            VStack(spacing: 8) {
                Text(cleanTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                HStack(spacing: 16) {
                    // Duration
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.cyan.opacity(0.8))
                        Text(lesson.estimatedMinutes)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Difficulty
                    HStack(spacing: 6) {
                        Image(systemName: data.difficultyIcon)
                            .font(.caption)
                            .foregroundColor(data.difficultyColor)
                        Text(data.difficulty)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .backdrop()
                )
            }
            .opacity(animationProgress)
            .offset(y: animationProgress == 1.0 ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.3), value: animationProgress)
            
            Spacer()
                .frame(height: 20)
        }
    }
    
    private func learningObjectivesCard(with data: EnhancedLessonData) -> some View {
        LessonInfoCard(
            title: "What You'll Learn",
            icon: "target",
            color: .green
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(data.learningObjectives, id: \.self) { objective in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        
                        Text(objective)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .opacity(animationProgress)
        .offset(y: animationProgress == 1.0 ? 0 : 30)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: animationProgress)
    }
    
    private func lessonDetailsCard(with data: EnhancedLessonData) -> some View {
        LessonInfoCard(
            title: "Lesson Overview",
            icon: "doc.text",
            color: .blue
        ) {
            VStack(alignment: .leading, spacing: 16) {
                Text(data.enhancedDescription)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                
                // Lesson Format
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lesson Format")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 12) {
                        ForEach(data.format, id: \.self) { format in
                            HStack(spacing: 6) {
                                Image(systemName: formatIcon(for: format))
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                Text(format)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.cyan.opacity(0.2))
                            )
                        }
                    }
                }
            }
        }
        .opacity(animationProgress)
        .offset(y: animationProgress == 1.0 ? 0 : 30)
        .animation(.easeOut(duration: 0.6).delay(0.5), value: animationProgress)
    }
    
    private func topicsCoveredCard(with data: EnhancedLessonData) -> some View {
        LessonInfoCard(
            title: "Key Topics",
            icon: "tag",
            color: .purple
        ) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(data.keyTopics, id: \.self) { topic in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.purple)
                        
                        Text(topic)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
            }
        }
        .opacity(animationProgress)
        .offset(y: animationProgress == 1.0 ? 0 : 30)
        .animation(.easeOut(duration: 0.6).delay(0.6), value: animationProgress)
    }
    
    private func prerequisitesCard(with data: EnhancedLessonData) -> some View {
        LessonInfoCard(
            title: "Prerequisites",
            icon: "checkmark.shield",
            color: .orange
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data.prerequisites, id: \.self) { prerequisite in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        
                        Text(prerequisite)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .opacity(animationProgress)
        .offset(y: animationProgress == 1.0 ? 0 : 30)
        .animation(.easeOut(duration: 0.6).delay(0.7), value: animationProgress)
    }
    

    

    
    private func formatIcon(for format: String) -> String {
        switch format.lowercased() {
        case "interactive": return "gamecontroller"
        case "video": return "play.circle"
        case "reading": return "doc.text"
        case "quiz": return "questionmark.circle"
        case "practice": return "pencil.circle"
        default: return "book.closed"
        }
    }
    
    private func loadLessonData() {
        // Fallback synchronous data generation
        let cleanTitle = self.cleanTitle
        let safeDescription = self.lesson.description.isEmpty ? "Learn about \(cleanTitle)" : self.lesson.description
        
        // Generate the data synchronously
        let generatedData = LessonDataGenerator.generateEnhancedLessonData(
            for: cleanTitle, 
            description: safeDescription
        )
        
        // Update state
        withAnimation(.easeInOut(duration: 0.3)) {
            self.lessonData = generatedData
        }
    }
}
    
    private func generateWW2BulletPoints(for title: String) -> [String] {
        let titleLower = title.lowercased()
        
        if titleLower.contains("glance") || titleLower.contains("setting") {
            return [
                "Major causes that led to World War 2",
                "Key alliances: Axis vs Allied powers",
                "Timeline of major events from 1939-1945",
                "Global context and how the war spread worldwide",
                "Important figures who shaped the conflict"
            ]
        } else if titleLower.contains("leaders") || titleLower.contains("churchill") || titleLower.contains("hitler") || titleLower.contains("roosevelt") {
            return [
                "Winston Churchill's leadership during Britain's darkest hour",
                "Adolf Hitler's rise to power and Nazi ideology",
                "Franklin D. Roosevelt's role in mobilizing America",
                "Leadership styles and strategic decision-making",
                "How these leaders influenced the war's outcome"
            ]
        } else if titleLower.contains("britain") || titleLower.contains("battle") {
            return [
                "Germany's strategy to gain air superiority over Britain",
                "The role of radar technology in British defense",
                "Key battles and turning points in the air war",
                "Impact on civilian morale and the Blitz experience",
                "How Britain's victory changed the course of the war"
            ]
        } else if titleLower.contains("eastern") || titleLower.contains("soviet") {
            return [
                "Operation Barbarossa: Germany's invasion of the USSR",
                "The brutal nature of warfare on the Eastern Front",
                "Key battles: Stalingrad, Kursk, and Leningrad",
                "The role of winter and logistics in the campaign",
                "How the Eastern Front determined the war's outcome"
            ]
        } else if titleLower.contains("codebreaking") || titleLower.contains("espionage") {
            return [
                "The Enigma machine and how it was cracked",
                "Bletchley Park and the codebreaking effort",
                "Role of spies and intelligence networks",
                "How intelligence affected major military decisions",
                "The secret war behind the scenes"
            ]
        } else if titleLower.contains("d-day") || titleLower.contains("invasion") {
            return [
                "Planning and preparation for Operation Overlord",
                "The massive logistics of the Normandy landings",
                "Key beaches: Omaha, Utah, Gold, Juno, and Sword",
                "Challenges faced by Allied forces on D-Day",
                "How D-Day opened the Western Front in Europe"
            ]
        } else if titleLower.contains("pacific") || titleLower.contains("japan") {
            return [
                "Japan's aggressive expansion across the Pacific",
                "Key battles: Pearl Harbor, Midway, and Guadalcanal",
                "Island-hopping strategy of the United States",
                "The decision to use atomic weapons",
                "Japan's surrender and the end of the war"
            ]
        } else if titleLower.contains("home") || titleLower.contains("civilian") {
            return [
                "How civilians contributed to the war effort",
                "Rationing and resource management on the home front",
                "Propaganda and maintaining morale during wartime",
                "Women's changing roles in wartime society",
                "The impact of total war on daily life"
            ]
        } else if titleLower.contains("aftermath") || titleLower.contains("legacy") {
            return [
                "Formation of the United Nations and new world order",
                "The division of Europe and start of the Cold War",
                "War crimes trials and pursuit of justice",
                "Rebuilding efforts: Marshall Plan and reconstruction",
                "Long-term impact on global politics and society"
            ]
        } else {
            return [
                "Key events and turning points of World War 2",
                "Major battles and their strategic importance",
                "Impact on soldiers and civilians during the conflict",
                "Technological and tactical innovations of the war",
                "Long-term consequences and historical significance"
            ]
        }
    }
    
    private func generateNFLBulletPoints(for title: String) -> [String] {
        let titleLower = title.lowercased()
        
        if titleLower.contains("roseman") || titleLower.contains("draft") {
            return [
                "Howie Roseman's philosophy on draft strategy",
                "Key draft picks that shaped the Eagles' success",
                "How to evaluate college talent for the NFL",
                "Trade strategies during the draft process",
                "Building a championship roster through the draft"
            ]
        } else if titleLower.contains("super bowl") || titleLower.contains("championship") {
            return [
                "Strategic decisions that led to Super Bowl victory",
                "Key player acquisitions and roster construction",
                "Game planning and tactical adjustments",
                "Leadership and team culture development",
                "Overcoming adversity during the championship run"
            ]
        } else {
            return [
                "Core concepts and strategies in professional football",
                "Key players and their impact on team success",
                "Tactical analysis of important games and decisions",
                "Team building and organizational management",
                "Historical context and significance of events"
            ]
        }
    }
    
    private func generateBaseballBulletPoints(for title: String) -> [String] {
        let titleLower = title.lowercased()
        
        if titleLower.contains("steroid") {
            return [
                "Timeline of steroid use in Major League Baseball",
                "Key players involved in the steroid scandal",
                "Impact on player performance and statistics",
                "MLB's response and policy changes",
                "Long-term effects on the sport's integrity"
            ]
        } else {
            return [
                "Fundamental concepts and rules of baseball",
                "Key players and their contributions to the sport",
                "Strategic elements of the game",
                "Historical significance and cultural impact",
                "Statistical analysis and performance evaluation"
            ]
        }
    }
    
    private func generateGenericBulletPoints(for title: String, description: String) -> [String] {
        // Extract key concepts from title and description
        let words = (title + " " + description).components(separatedBy: .whitespacesAndNewlines)
        let keyWords = words.filter { $0.count > 4 }.prefix(3)
        
        return [
            "Core concepts and fundamental principles",
            "Key topics: " + keyWords.joined(separator: ", "),
            "Practical applications and real-world examples",
            "Important facts and background information",
            "Connections to broader themes and ideas"
        ]
    }

// MARK: - Enhanced Lesson Data Structures

struct EnhancedLessonData {
    let icon: String
    let difficulty: String
    let difficultyIcon: String
    let difficultyColor: Color
    let learningObjectives: [String]
    let enhancedDescription: String
    let keyTopics: [String]
    let format: [String]
    let prerequisites: [String]
}

// MARK: - Enhanced Data Generation

struct LessonDataGenerator {
    static func generateEnhancedLessonData(for title: String, description: String) -> EnhancedLessonData {
        // Ensure we have valid inputs
        let safeTitle = title.isEmpty ? "Lesson" : title
        let safeDescription = description.isEmpty ? "Learn about \(safeTitle)" : description
        let titleLower = safeTitle.lowercased()
        
        // Determine lesson icon with fallback
        let icon = determineLessonIcon(for: titleLower)
        
        // Generate difficulty with fallback
        let (difficulty, difficultyIcon, difficultyColor) = determineDifficulty(for: titleLower)
        
        // Generate learning objectives with error handling
        let learningObjectives = generateLearningObjectives(for: safeTitle, description: safeDescription)
        
        // Enhance description with fallback
        let enhancedDescription = enhanceDescription(original: safeDescription, title: safeTitle)
        
        // Generate key topics with error handling
        let keyTopics = generateKeyTopics(for: safeTitle, description: safeDescription)
        
        // Determine lesson format with fallback
        let format = determineLessonFormat(for: titleLower)
        
        // Generate prerequisites with fallback
        let prerequisites = generatePrerequisites(for: titleLower)
        
        return EnhancedLessonData(
            icon: icon,
            difficulty: difficulty,
            difficultyIcon: difficultyIcon,
            difficultyColor: difficultyColor,
            learningObjectives: learningObjectives,
            enhancedDescription: enhancedDescription,
            keyTopics: keyTopics,
            format: format,
            prerequisites: prerequisites
        )
    }

static func determineLessonIcon(for titleLower: String) -> String {
    if titleLower.contains("introduction") || titleLower.contains("basics") || titleLower.contains("fundamentals") {
        return "book.closed"
    } else if titleLower.contains("advanced") || titleLower.contains("expert") || titleLower.contains("master") {
        return "graduationcap"
    } else if titleLower.contains("practice") || titleLower.contains("exercise") || titleLower.contains("hands-on") {
        return "dumbbell"
    } else if titleLower.contains("strategy") || titleLower.contains("tactics") || titleLower.contains("planning") {
        return "chess.board"
    } else if titleLower.contains("history") || titleLower.contains("timeline") || titleLower.contains("origins") {
        return "clock.arrow.circlepath"
    } else if titleLower.contains("analysis") || titleLower.contains("deep dive") || titleLower.contains("detailed") {
        return "magnifyingglass"
    } else if titleLower.contains("leadership") || titleLower.contains("management") || titleLower.contains("decision") {
        return "person.3"
    } else if titleLower.contains("technology") || titleLower.contains("innovation") || titleLower.contains("modern") {
        return "gear"
    } else if titleLower.contains("comparison") || titleLower.contains("vs") || titleLower.contains("versus") {
        return "scale.3d"
    } else {
        return "lightbulb"
    }
}

static func determineDifficulty(for titleLower: String) -> (String, String, Color) {
    if titleLower.contains("introduction") || titleLower.contains("basics") || titleLower.contains("fundamentals") || titleLower.contains("overview") {
        return ("Beginner", "1.circle.fill", .green)
    } else if titleLower.contains("advanced") || titleLower.contains("expert") || titleLower.contains("master") || titleLower.contains("deep dive") {
        return ("Advanced", "3.circle.fill", .red)
    } else {
        return ("Intermediate", "2.circle.fill", .orange)
    }
}

static func generateLearningObjectives(for title: String, description: String) -> [String] {
    // Ensure we have valid inputs
    guard !title.isEmpty else {
        return [
            "Master fundamental concepts and core principles",
            "Develop critical thinking skills through analysis",
            "Apply knowledge to real-world scenarios",
            "Build a strong foundation for advanced learning"
        ]
    }
    
    let titleLower = title.lowercased()
    
    // Topic-specific objectives with better matching
    if titleLower.contains("cellular") || titleLower.contains("respiration") || titleLower.contains("glycolysis") {
        return generateScienceObjectives(for: titleLower)
    } else if titleLower.contains("ww2") || titleLower.contains("world war") {
        return generateWW2Objectives(for: titleLower)
    } else if titleLower.contains("eagles") || titleLower.contains("nfl") || titleLower.contains("football") {
        return generateNFLObjectives(for: titleLower)
    } else if titleLower.contains("baseball") || titleLower.contains("mlb") {
        return generateBaseballObjectives(for: titleLower)
    } else {
        return generateGenericObjectives(for: title, description: description)
    }
}

static func generateScienceObjectives(for titleLower: String) -> [String] {
    if titleLower.contains("cellular") && titleLower.contains("respiration") {
        return [
            "Understand the process of cellular respiration and energy production",
            "Learn how cells convert glucose into usable energy (ATP)",
            "Explore the relationship between respiration and everyday life",
            "Master the key steps and components of cellular metabolism"
        ]
    } else if titleLower.contains("glycolysis") {
        return [
            "Master the glycolysis pathway and its role in energy production",
            "Understand how glucose is broken down into pyruvate",
            "Learn about ATP generation during the glycolytic process",
            "Explore the regulation and significance of glycolysis in cells"
        ]
    } else {
        return [
            "Understand fundamental scientific concepts and principles",
            "Develop analytical skills for scientific problem-solving",
            "Learn to apply scientific knowledge to real-world situations",
            "Build a strong foundation for advanced scientific study"
        ]
    }
}

static func generateWW2Objectives(for titleLower: String) -> [String] {
    if titleLower.contains("leaders") || titleLower.contains("churchill") || titleLower.contains("hitler") {
        return [
            "Analyze the leadership styles of key WWII figures",
            "Understand how personal decisions shaped global events",
            "Evaluate the impact of charismatic leadership in wartime",
            "Compare different approaches to crisis management"
        ]
    } else if titleLower.contains("strategy") || titleLower.contains("tactics") {
        return [
            "Master the strategic thinking behind major military campaigns",
            "Understand the role of logistics in warfare",
            "Analyze successful and failed military strategies",
            "Apply strategic principles to modern problem-solving"
        ]
    } else {
        return [
            "Understand the causes and consequences of World War II",
            "Analyze key battles and their strategic importance",
            "Evaluate the impact on civilian populations",
            "Connect historical events to modern geopolitics"
        ]
    }
}

static func generateNFLObjectives(for titleLower: String) -> [String] {
    if titleLower.contains("draft") || titleLower.contains("roseman") {
        return [
            "Master NFL draft strategy and evaluation techniques",
            "Understand how to build a championship roster",
            "Learn advanced scouting and player assessment",
            "Analyze successful team-building philosophies"
        ]
    } else if titleLower.contains("super bowl") || titleLower.contains("championship") {
        return [
            "Analyze the components of championship-level teams",
            "Understand playoff strategy and preparation",
            "Learn about clutch performance under pressure",
            "Study the psychology of winning in high-stakes situations"
        ]
    } else {
        return [
            "Understand advanced football strategy and tactics",
            "Analyze team building and organizational excellence",
            "Learn from successful coaching methodologies",
            "Apply sports principles to leadership and teamwork"
        ]
    }
}

static func generateBaseballObjectives(for titleLower: String) -> [String] {
    return [
        "Understand the evolution of baseball strategy",
        "Analyze statistical trends and their impact",
        "Learn about key moments in baseball history",
        "Evaluate the cultural significance of America's pastime"
    ]
}

static func generateGenericObjectives(for title: String, description: String) -> [String] {
    let baseObjectives = [
        "Master the fundamental concepts and core principles",
        "Develop critical thinking skills through practical analysis",
        "Apply knowledge to real-world scenarios and challenges",
        "Build a strong foundation for advanced learning"
    ]
    
    // Ensure we have valid inputs
    guard !title.isEmpty else {
        return baseObjectives
    }
    
    // Customize based on title keywords
    var customObjectives = baseObjectives
    let titleLower = title.lowercased()
    
    if titleLower.contains("advanced") {
        customObjectives[0] = "Master advanced concepts and sophisticated techniques"
        customObjectives[3] = "Achieve expert-level understanding and application"
    } else if titleLower.contains("introduction") || titleLower.contains("unlocking") {
        customObjectives[0] = "Learn essential basics and foundational knowledge"
        customObjectives[3] = "Prepare for intermediate-level learning"
    }
    
    return customObjectives
}

static func enhanceDescription(original: String, title: String) -> String {
    if original.count < 50 {
        // Generate enhanced description if original is too short
        return "This comprehensive lesson covers \(title.lowercased()) with detailed explanations, practical examples, and interactive elements designed to deepen your understanding and provide actionable insights you can apply immediately."
    } else {
        return original
    }
}

static func generateKeyTopics(for title: String, description: String) -> [String] {
    // Ensure we have valid inputs
    guard !title.isEmpty else {
        return ["Core Concepts", "Key Principles", "Practical Applications", "Critical Analysis"]
    }
    
    let combinedText = title + " " + description
    let words = combinedText.components(separatedBy: .whitespacesAndNewlines)
    let stopWords = ["this", "that", "with", "from", "they", "will", "have", "been", "were", "would", "could", "should", "your", "about", "into", "through", "during", "before", "after", "above", "below", "between"]
    
    let meaningfulWords = words.filter { word in
        let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
        return cleanWord.count > 3 && !stopWords.contains(cleanWord.lowercased())
    }
    
    let uniqueWords = Array(Set(meaningfulWords.prefix(8))).sorted()
    
    if uniqueWords.count >= 4 {
        return Array(uniqueWords.prefix(6))
    } else {
        // Generate topic-specific keywords based on title
        let titleLower = title.lowercased()
        
        if titleLower.contains("cellular") || titleLower.contains("respiration") || titleLower.contains("glycolysis") {
            return ["Cellular Processes", "Energy Production", "Biochemistry", "Metabolism", "ATP Synthesis", "Scientific Concepts"]
        } else if titleLower.contains("ww2") || titleLower.contains("world war") {
            return ["Military Strategy", "Historical Context", "Key Battles", "Leadership", "Global Impact", "Aftermath"]
        } else if titleLower.contains("nfl") || titleLower.contains("eagles") || titleLower.contains("football") {
            return ["Team Strategy", "Player Analysis", "Game Planning", "Leadership", "Performance", "Championship"]
        } else if titleLower.contains("science") || titleLower.contains("biology") || titleLower.contains("chemistry") {
            return ["Scientific Method", "Core Principles", "Laboratory Techniques", "Research Methods", "Data Analysis", "Practical Applications"]
        } else {
            return ["Core Concepts", "Key Principles", "Practical Applications", "Historical Context", "Modern Relevance", "Critical Analysis"]
        }
    }
}

static func determineLessonFormat(for titleLower: String) -> [String] {
    var formats: [String] = []
    
    if titleLower.contains("interactive") || titleLower.contains("practice") || titleLower.contains("exercise") {
        formats.append("Interactive")
    }
    
    if titleLower.contains("video") || titleLower.contains("watch") || titleLower.contains("visual") {
        formats.append("Video")
    }
    
    if titleLower.contains("read") || titleLower.contains("text") || titleLower.contains("article") {
        formats.append("Reading")
    }
    
    if titleLower.contains("quiz") || titleLower.contains("test") || titleLower.contains("assessment") {
        formats.append("Quiz")
    }
    
    // Default formats if none specified
    if formats.isEmpty {
        formats = ["Interactive", "Reading"]
    }
    
    return formats
}

static func generatePrerequisites(for titleLower: String) -> [String] {
    if titleLower.contains("advanced") || titleLower.contains("expert") || titleLower.contains("master") {
        return ["Basic understanding of the topic", "Completion of introductory lessons"]
    } else if titleLower.contains("intermediate") || titleLower.contains("deeper") || titleLower.contains("detailed") {
        return ["Foundational knowledge recommended"]
    } else {
        return [] // No prerequisites for beginner lessons
    }
}
} // End of LessonDataGenerator

// MARK: - Lesson Info Card Component

struct LessonInfoCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Content
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .backdrop()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - View Extensions

extension View {
    func backdrop() -> some View {
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Lesson Count Validation Popup

struct LessonCountValidationPopup: View {
    let selectedCount: Int
    let targetCount: Int
    let onSelectMore: () -> Void
    let onGenerateMore: () -> Void
    let onContinueWithCurrent: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            // Main popup content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.8), .red.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Almost Ready!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You selected **\(selectedCount)** of **\(targetCount)** lessons")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Options
                VStack(spacing: 12) {
                    // Select More Lessons (Primary option)
                    Button(action: onSelectMore) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Select More Lessons")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Choose from existing lessons")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.4), lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // AI Generate More
                    Button(action: onGenerateMore) {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.cyan)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Let AI Create More")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("AI will add \(targetCount - selectedCount) more lessons")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Continue with Current
                    Button(action: onContinueWithCurrent) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.forward.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Continue with \(selectedCount) Lessons")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Proceed with fewer lessons")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Cancel button
                Button("Cancel") {
                    onCancel()
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.2),
                                Color(red: 0.15, green: 0.15, blue: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
        }
    }
}
