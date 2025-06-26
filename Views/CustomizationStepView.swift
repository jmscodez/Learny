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
                LessonInfoModal(lesson: lesson)
            }
        }
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
                Button(action: onFinalize) {
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
        Button(action: onTap) {
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
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Lesson Info Modal

struct LessonInfoModal: View {
    let lesson: LessonSuggestion
    @Environment(\.dismiss) private var dismiss
    
    // Generate bullet points based on lesson content
    private var bulletPoints: [String] {
        let title = lesson.title.replacingOccurrences(of: "💬 ", with: "")
        
        // Generate topic-specific bullet points based on the lesson title
        if title.contains("WW2") || title.contains("World War") {
            return generateWW2BulletPoints(for: title)
        } else if title.contains("Eagles") || title.contains("NFL") {
            return generateNFLBulletPoints(for: title)
        } else if title.contains("Baseball") || title.contains("MLB") {
            return generateBaseballBulletPoints(for: title)
        } else {
            return generateGenericBulletPoints(for: title, description: lesson.description)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lesson.title.replacingOccurrences(of: "💬 ", with: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(lesson.estimatedMinutes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Key Topics Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What You'll Learn")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(bulletPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.blue)
                                    .padding(.top, 6)
                                
                                Text(point)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(lesson.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .navigationTitle("Lesson Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
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
}



 
