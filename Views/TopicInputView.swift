import SwiftUI

// MARK: - New Advanced Configuration Models
enum LearningStyle: String, CaseIterable, Codable {
    case visual = "visual"
    case interactive = "interactive"
    case analytical = "analytical"
    case storytelling = "storytelling"
    
    var displayName: String {
        switch self {
        case .visual: return "Visual"
        case .interactive: return "Interactive"
        case .analytical: return "Analytical"
        case .storytelling: return "Storytelling"
        }
    }
    
    var description: String {
        switch self {
        case .visual: return "📊 Diagrams, infographics, and visual representations"
        case .interactive: return "🎮 Games, simulations, and hands-on activities"
        case .analytical: return "📈 Data, comparisons, and structured analysis"
        case .storytelling: return "📚 Narratives, case studies, and real-world examples"
        }
    }
    
    var icon: String {
        switch self {
        case .visual: return "chart.bar.fill"
        case .interactive: return "gamecontroller.fill"
        case .analytical: return "chart.line.uptrend.xyaxis"
        case .storytelling: return "book.fill"
        }
    }
}

enum AssessmentFrequency: String, CaseIterable, Codable {
    case everyLesson = "every_lesson"
    case everyThreeLessons = "every_three_lessons"
    case atEnd = "at_end"
    case minimal = "minimal"
    
    var displayName: String {
        switch self {
        case .everyLesson: return "Every Lesson"
        case .everyThreeLessons: return "Every 3 Lessons"
        case .atEnd: return "At End"
        case .minimal: return "Minimal"
        }
    }
    
    var description: String {
        switch self {
        case .everyLesson: return "🎯 Regular check-ins for maximum retention"
        case .everyThreeLessons: return "⚖️ Balanced assessment frequency"
        case .atEnd: return "🏁 Final comprehensive evaluation"
        case .minimal: return "✨ Focus on learning, minimal testing"
        }
    }
}

enum LearningContext: String, CaseIterable, Codable {
    case work = "work"
    case hobby = "hobby"
    case exam = "exam"
    case general = "general"
    
    var displayName: String {
        switch self {
        case .work: return "Work/Career"
        case .hobby: return "Personal Interest"
        case .exam: return "Exam Prep"
        case .general: return "General Knowledge"
        }
    }
    
    var description: String {
        switch self {
        case .work: return "💼 Professional development and career advancement"
        case .hobby: return "🎨 Personal enrichment and enjoyment"
        case .exam: return "📝 Structured preparation for specific tests"
        case .general: return "🧠 Broad understanding and curiosity"
        }
    }
}

struct AdvancedCourseConfig {
    var learningObjectives: [String] = []
    var learningStyle: LearningStyle = .interactive
    var assessmentFrequency: AssessmentFrequency = .everyThreeLessons
    var context: LearningContext = .general
    var prerequisites: String = ""
    var realWorldApplication: String = ""
    var estimatedTimeCommitment: Double = 30 // minutes per session
    var numberOfSessions: Int = 5
}

struct TopicInputView: View {
    @EnvironmentObject private var generationManager: CourseGenerationManager
    @EnvironmentObject private var navManager: NavigationManager
    @EnvironmentObject private var statsManager: LearningStatsManager
    @EnvironmentObject private var notesManager: NotificationsManager
    
    @State private var topic: String = ""
    @State private var difficulty: Difficulty = .intermediate
    @State private var pace: Pace = .balanced
    @State private var advancedConfig = AdvancedCourseConfig()
    @State private var showAdvancedOptions = false
    @State private var showAIChat = false
    @State private var showTemplateGallery = false
    @State private var currentObjective = ""
    @State private var selectedTemplate: CourseTemplate? = nil

    // MARK: - Course Templates
    private let courseTemplates: [CourseTemplate] = [
        CourseTemplate(
            id: UUID(),
            title: "Quick Skill Builder",
            description: "Learn a new skill in 3-5 focused lessons",
            estimatedTime: "2-3 hours",
            icon: "bolt.fill",
            difficulty: .beginner,
            pace: .balanced,
            sessionCount: 4,
            color: .blue
        ),
        CourseTemplate(
            id: UUID(),
            title: "Deep Dive Mastery",
            description: "Comprehensive exploration of complex topics",
            estimatedTime: "8-12 hours",
            icon: "brain.head.profile",
            difficulty: .advanced,
            pace: .deepDive,
            sessionCount: 10,
            color: .purple
        ),
        CourseTemplate(
            id: UUID(),
            title: "Exam Preparation",
            description: "Structured preparation with practice tests",
            estimatedTime: "5-8 hours",
            icon: "graduationcap.fill",
            difficulty: .intermediate,
            pace: .balanced,
            sessionCount: 6,
            color: .green
        ),
        CourseTemplate(
            id: UUID(),
            title: "Professional Development",
            description: "Career-focused learning with real-world applications",
            estimatedTime: "6-10 hours",
            icon: "briefcase.fill",
            difficulty: .intermediate,
            pace: .balanced,
            sessionCount: 8,
            color: .orange
        )
    ]
    
    private var difficultyDescription: String {
        switch difficulty {
        case .beginner: 
            return "🎯 Perfect for newcomers! Starts with fundamentals, uses simple language, includes lots of examples, and assumes no prior knowledge. Concepts are introduced step-by-step with plenty of context."
        case .intermediate: 
            return "⚡ Assumes basic familiarity with the topic. Moves at a moderate pace, introduces complex relationships between concepts, and includes some technical terminology. Great for building on existing knowledge."
        case .advanced: 
            return "🚀 For experts seeking deep understanding! Uses technical language, explores nuanced concepts, analyzes complex theories, and assumes strong foundational knowledge. Minimal hand-holding."
        }
    }
    
    private var paceDescription: String {
        switch pace {
        case .quickReview: 
            return "⚡ Fast-paced overview hitting the key highlights. Perfect for refreshing knowledge or getting familiar with main concepts quickly. Light on deep explanations."
        case .balanced: 
            return "🎯 Perfect middle ground! Thorough explanations with practical examples, interactive exercises, and time to absorb concepts. Most comprehensive learning experience."
        case .deepDive: 
            return "🔬 Comprehensive, in-depth exploration. Detailed analysis, multiple perspectives, extensive examples, and thorough coverage of subtopics. Maximum learning depth."
        }
    }
    
    var body: some View {
        NavigationStack(path: $navManager.path) {
            ZStack {
                // Enhanced gradient background
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
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerView
                        
                        // Main topic input with smart suggestions
                        topicInputSection
                        
                        // Template gallery
                        if !topic.isEmpty && !showAdvancedOptions {
                            templateGallerySection
                        }
                        
                        // Quick configuration section
                        if !topic.isEmpty {
                            quickConfigurationSection
                        }
                        
                        // Advanced options
                        if showAdvancedOptions {
                            advancedOptionsSection
                        }
                        
                        // Create button
                        createCourseButton
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Learn")
            .navigationBarHidden(true)
            .navigationDestination(for: Course.self) { course in
                LessonMapView(course: course)
            }
            .fullScreenCover(isPresented: $showAIChat) {
                CourseChatSetupView(
                    topic: topic, 
                    difficulty: difficulty, 
                    pace: pace, 
                    advancedConfig: advancedConfig,
                    isPresented: $showAIChat
                )
            }
        }
        .onAppear(perform: notesManager.requestAuthorization)
        .onChange(of: generationManager.generatedCourse) { newCourse in
            if let course = newCourse {
                navManager.path.append(course)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create with AI")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Build the perfect course for your learning goals")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Quick stats or notifications could go here
                Button(action: { showTemplateGallery.toggle() }) {
                    Image(systemName: "square.grid.2x2")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Topic Input Section
    private var topicInputSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(height: 60)
                
                TextField("", text: $topic)
                    .placeholder(when: topic.isEmpty) {
                        Text("What would you like to master today?")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
            }
            
            // Smart topic suggestions
            if topic.count > 2 {
                smartSuggestionsView
            }
        }
    }
    
    // MARK: - Smart Suggestions
    private var smartSuggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(getSmartSuggestions(), id: \.self) { suggestion in
                    Button(action: { topic = suggestion }) {
                        Text(suggestion)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Template Gallery Section
    private var templateGallerySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Start Templates")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(courseTemplates) { template in
                        TemplateCard(template: template, isSelected: selectedTemplate?.id == template.id) {
                            selectedTemplate = template
                            difficulty = template.difficulty
                            pace = template.pace
                            advancedConfig.numberOfSessions = template.sessionCount
                            advancedConfig.context = template.title.contains("Professional") ? .work : 
                                                   template.title.contains("Exam") ? .exam : .general
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Quick Configuration Section
    private var quickConfigurationSection: some View {
        VStack(spacing: 24) {
            // Difficulty and Pace
            VStack(spacing: 20) {
                OptionGroupView(title: "Difficulty Level") {
                    HStack(spacing: 12) {
                        ForEach(Difficulty.allCases, id: \.self) { level in
                            ModernPill(
                                title: level.rawValue.capitalized,
                                isSelected: difficulty == level,
                                icon: difficultyIcon(for: level)
                            ) {
                                difficulty = level
                            }
                        }
                    }
                    
                    Text(difficultyDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(minHeight: 40, alignment: .top)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                }
                
                OptionGroupView(title: "Learning Pace") {
                    HStack(spacing: 12) {
                        ForEach(Pace.allCases, id: \.self) { level in
                            ModernPill(
                                title: level.displayName,
                                isSelected: pace == level,
                                icon: paceIcon(for: level)
                            ) {
                                pace = level
                            }
                        }
                    }
                    
                    Text(paceDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(minHeight: 40, alignment: .top)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                }
            }
            
            // Advanced options toggle
            Button(action: { 
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showAdvancedOptions.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "gearshape.2.fill")
                    Text(showAdvancedOptions ? "Hide Advanced Options" : "Advanced Configuration")
                    Spacer()
                    Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Advanced Options Section
    private var advancedOptionsSection: some View {
        VStack(spacing: 24) {
            // Learning Objectives Builder
            OptionGroupView(title: "Learning Objectives") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What do you want to achieve? (Tap + to add objectives)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ForEach(Array(advancedConfig.learningObjectives.enumerated()), id: \.offset) { index, objective in
                        HStack {
                            Text("• \(objective)")
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { advancedConfig.learningObjectives.remove(at: index) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.7))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    HStack {
                        TextField("Add learning objective...", text: $currentObjective)
                            .foregroundColor(.white)
                            .onSubmit {
                                if !currentObjective.trimmingCharacters(in: .whitespaces).isEmpty {
                                    advancedConfig.learningObjectives.append(currentObjective.trimmingCharacters(in: .whitespaces))
                                    currentObjective = ""
                                }
                            }
                        
                        Button(action: {
                            if !currentObjective.trimmingCharacters(in: .whitespaces).isEmpty {
                                advancedConfig.learningObjectives.append(currentObjective.trimmingCharacters(in: .whitespaces))
                                currentObjective = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            
            // Learning Style
            OptionGroupView(title: "Learning Style Preference") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(LearningStyle.allCases, id: \.self) { style in
                        LearningStyleCard(
                            style: style,
                            isSelected: advancedConfig.learningStyle == style
                        ) {
                            advancedConfig.learningStyle = style
                        }
                    }
                }
            }
            
            // Assessment and Context
            VStack(spacing: 20) {
                OptionGroupView(title: "Assessment Frequency") {
                    VStack(spacing: 12) {
                        ForEach(AssessmentFrequency.allCases, id: \.self) { frequency in
                            AssessmentOption(
                                frequency: frequency,
                                isSelected: advancedConfig.assessmentFrequency == frequency
                            ) {
                                advancedConfig.assessmentFrequency = frequency
                            }
                        }
                    }
                }
                
                OptionGroupView(title: "Learning Context") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(LearningContext.allCases, id: \.self) { context in
                            ContextCard(
                                context: context,
                                isSelected: advancedConfig.context == context
                            ) {
                                advancedConfig.context = context
                            }
                        }
                    }
                }
            }
            
            // Prerequisites and Application
            VStack(spacing: 16) {
                AdvancedTextField(
                    title: "Prerequisites (What do you already know?)",
                    text: $advancedConfig.prerequisites,
                    placeholder: "e.g., Basic programming concepts, algebra..."
                )
                
                AdvancedTextField(
                    title: "Real-world Application",
                    text: $advancedConfig.realWorldApplication,
                    placeholder: "How will you use this knowledge?"
                )
            }
            
            // Time Commitment
            OptionGroupView(title: "Time Commitment") {
                VStack(spacing: 16) {
                    HStack {
                        Text("Session Length:")
                        Spacer()
                        Text("\(Int(advancedConfig.estimatedTimeCommitment)) minutes")
                            .foregroundColor(.blue)
                    }
                    .foregroundColor(.white)
                    
                    Slider(value: $advancedConfig.estimatedTimeCommitment, in: 15...120, step: 15)
                        .accentColor(.blue)
                    
                    HStack {
                        Text("Number of Sessions:")
                        Spacer()
                        Text("\(advancedConfig.numberOfSessions)")
                            .foregroundColor(.blue)
                    }
                    .foregroundColor(.white)
                    
                    Slider(value: Binding(
                        get: { Double(advancedConfig.numberOfSessions) },
                        set: { advancedConfig.numberOfSessions = Int($0) }
                    ), in: 3...15, step: 1)
                        .accentColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Create Course Button
    private var createCourseButton: some View {
        VStack(spacing: 16) {
            if !topic.trimmingCharacters(in: .whitespaces).isEmpty {
                Button(action: { 
                    // Start generation immediately on main page
                    generationManager.isGenerating = true
                    showAIChat = true 
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title2)
                        Text("Create with AI")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .scaleEffect(topic.trimmingCharacters(in: .whitespaces).isEmpty ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: topic.isEmpty)
                
                // Preview of course configuration
                CoursePreviewCard(topic: topic, difficulty: difficulty, pace: pace, config: advancedConfig)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getSmartSuggestions() -> [String] {
        let baseSuggestions = [
            "Machine Learning Fundamentals",
            "Spanish for Beginners",
            "Digital Marketing Strategy",
            "Web Development with React",
            "Personal Finance Management",
            "Data Science with Python"
        ]
        
        return baseSuggestions.filter { suggestion in
            suggestion.lowercased().contains(topic.lowercased()) ||
            topic.lowercased().contains(suggestion.components(separatedBy: " ").first?.lowercased() ?? "")
        }
    }
    
    private func difficultyIcon(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .beginner: return "star.fill"
        case .intermediate: return "star.circle.fill"
        case .advanced: return "crown.fill"
        }
    }
    
    private func paceIcon(for pace: Pace) -> String {
        switch pace {
        case .quickReview: return "bolt.fill"
        case .balanced: return "scale.3d"
        case .deepDive: return "magnifyingglass"
        }
    }
}

// MARK: - Supporting Views and Models

struct CourseTemplate: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let estimatedTime: String
    let icon: String
    let difficulty: Difficulty
    let pace: Pace
    let sessionCount: Int
    let color: Color
}

struct TemplateCard: View {
    let template: CourseTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundColor(template.color)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    Text(template.estimatedTime)
                        .font(.caption2)
                        .foregroundColor(template.color)
                        .padding(.top, 4)
                }
                
                Spacer()
            }
            .padding(16)
            .frame(width: 180, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? template.color : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OptionGroupView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ModernPill: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .foregroundColor(isSelected ? .blue : .white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LearningStyleCard: View {
    let style: LearningStyle
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.7))
                
                Text(style.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(style.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AssessmentOption: View {
    let frequency: AssessmentFrequency
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(frequency.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(frequency.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContextCard: View {
    let context: LearningContext
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Text(context.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(context.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.green : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdvancedTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(2...4)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
        }
    }
}

struct CoursePreviewCard: View {
    let topic: String
    let difficulty: Difficulty
    let pace: Pace
    let config: AdvancedCourseConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Course Preview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "eye.fill")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("📚 \(topic)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("🎯 \(difficulty.rawValue.capitalized)")
                    Text("•")
                    Text("⚡ \(pace.displayName)")
                    Text("•")
                    Text("📝 \(config.numberOfSessions) sessions")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                
                Text("🎨 \(config.learningStyle.displayName) style")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                if !config.learningObjectives.isEmpty {
                    Text("🎯 \(config.learningObjectives.count) learning objectives")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Extensions

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Legacy pill views for backward compatibility
private struct DifficultyPill: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ModernPill(title: title, isSelected: isSelected, icon: "star.fill", onTap: onTap)
    }
}

private struct PacePill: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ModernPill(title: title, isSelected: isSelected, icon: "gauge.medium", onTap: onTap)
    }
}

struct TopicInputView_Previews: PreviewProvider {
    @State static var tab = 0
    static var previews: some View {
        TopicInputView()
            .environmentObject(CourseGenerationManager())
            .environmentObject(NavigationManager())
            .environmentObject(LearningStatsManager())
            .environmentObject(NotificationsManager())
            .preferredColorScheme(.dark)
    }
}
