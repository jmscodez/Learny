import SwiftUI

// MARK: - Dynamic Theme Engine
struct LessonTheme {
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let backgroundGradient: [Color]
    let particleColor: Color
    let iconName: String
    let ambientElements: [AmbientElement]
}

struct AmbientElement {
    let symbol: String
    let color: Color
    let size: CGFloat
    let opacity: Double
}

class ThemeEngine {
    static func generateTheme(for course: Course) -> LessonTheme {
        let topic = course.title.lowercased()
        
        // Science themes
        if topic.contains("science") || topic.contains("biology") || topic.contains("chemistry") || topic.contains("physics") {
            return LessonTheme(
                primaryColor: .cyan,
                secondaryColor: .blue,
                accentColor: .green,
                backgroundGradient: [
                    Color(red: 0.1, green: 0.3, blue: 0.8),
                    Color(red: 0.0, green: 0.5, blue: 0.7),
                    Color(red: 0.1, green: 0.7, blue: 0.5)
                ],
                particleColor: .cyan,
                iconName: "atom",
                ambientElements: [
                    AmbientElement(symbol: "circle.fill", color: .cyan.opacity(0.3), size: 8, opacity: 0.6),
                    AmbientElement(symbol: "hexagon.fill", color: .blue.opacity(0.2), size: 12, opacity: 0.4)
                ]
            )
        }
        
        // History themes
        if topic.contains("history") || topic.contains("ancient") || topic.contains("empire") {
            return LessonTheme(
                primaryColor: .brown,
                secondaryColor: .orange,
                accentColor: .yellow,
                backgroundGradient: [
                    Color(red: 0.4, green: 0.2, blue: 0.1),
                    Color(red: 0.6, green: 0.3, blue: 0.1),
                    Color(red: 0.8, green: 0.4, blue: 0.2)
                ],
                particleColor: .orange,
                iconName: "scroll.fill",
                ambientElements: [
                    AmbientElement(symbol: "triangle.fill", color: .orange.opacity(0.3), size: 10, opacity: 0.5),
                    AmbientElement(symbol: "diamond.fill", color: .yellow.opacity(0.2), size: 8, opacity: 0.4)
                ]
            )
        }
        
        // Math themes
        if topic.contains("math") || topic.contains("algebra") || topic.contains("geometry") {
            return LessonTheme(
                primaryColor: .purple,
                secondaryColor: .pink,
                accentColor: .blue,
                backgroundGradient: [
                    Color(red: 0.3, green: 0.1, blue: 0.8),
                    Color(red: 0.5, green: 0.2, blue: 0.9),
                    Color(red: 0.4, green: 0.3, blue: 0.7)
                ],
                particleColor: .purple,
                iconName: "function",
                ambientElements: [
                    AmbientElement(symbol: "square.fill", color: .purple.opacity(0.3), size: 10, opacity: 0.5),
                    AmbientElement(symbol: "circle.fill", color: .pink.opacity(0.2), size: 6, opacity: 0.4)
                ]
            )
        }
        
        // Default theme
        return LessonTheme(
            primaryColor: .blue,
            secondaryColor: .cyan,
            accentColor: .green,
            backgroundGradient: [
                Color(red: 0.2, green: 0.4, blue: 0.8),
                Color(red: 0.1, green: 0.6, blue: 0.7),
                Color(red: 0.2, green: 0.7, blue: 0.5)
            ],
            particleColor: .blue,
            iconName: "book.fill",
            ambientElements: [
                AmbientElement(symbol: "circle.fill", color: .blue.opacity(0.3), size: 8, opacity: 0.5)
            ]
        )
    }
    
    static func generateLessonIcon(for lesson: Lesson, in course: Course) -> String {
        let title = lesson.title.lowercased()
        let courseTitle = course.title.lowercased()
        
        // Science-specific icons
        if courseTitle.contains("science") || courseTitle.contains("biology") {
            if title.contains("cell") || title.contains("cellular") {
                return "circle.hexagongrid.fill"
            } else if title.contains("dna") || title.contains("genetic") {
                return "link"
            } else if title.contains("respiration") || title.contains("breathing") {
                return "lungs.fill"
            } else if title.contains("photosynthesis") || title.contains("plant") {
                return "leaf.fill"
            } else if title.contains("evolution") || title.contains("darwin") {
                return "arrow.triangle.branch"
            }
            return "atom"
        }
        
        // History-specific icons
        if courseTitle.contains("history") {
            if title.contains("empire") || title.contains("kingdom") {
                return "crown.fill"
            } else if title.contains("war") || title.contains("battle") {
                return "shield.fill"
            } else if title.contains("culture") || title.contains("art") {
                return "paintbrush.fill"
            } else if title.contains("trade") || title.contains("economy") {
                return "dollarsign.circle.fill"
            }
            return "scroll.fill"
        }
        
        // Math-specific icons
        if courseTitle.contains("math") {
            if title.contains("algebra") || title.contains("equation") {
                return "x.squareroot"
            } else if title.contains("geometry") || title.contains("triangle") {
                return "triangle.fill"
            } else if title.contains("calculus") || title.contains("derivative") {
                return "function"
            }
            return "number.square.fill"
        }
        
        // Default icons based on lesson type
        switch lesson.type {
        case .videoLesson:
            return "play.circle.fill"
        case .checkpointQuiz:
            return "questionmark.circle.fill"
        case .readingMaterial:
            return "book.fill"
        case .interactiveDemo:
            return "hand.tap.fill"
        case .lesson:
            return "book.fill"
        case .practiceExercise:
            return "pencil.circle.fill"
        }
    }
}

// Enhanced progress bar with theme support
struct CustomProgressBar: View {
    var progress: Double
    var theme: LessonTheme
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(.white.opacity(0.3))
                Capsule()
                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                    .foregroundColor(theme.primaryColor)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct LessonMapView: View {
    @EnvironmentObject var streaks: StreakManager
    @StateObject private var viewModel: LessonMapViewModel
    @StateObject private var studyTimer = StudyTimerManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCourseDetails = false
    @State private var showXpAnimation = false
    @State private var xpGained = 0
    @State private var selectedLesson: Lesson?
    @State private var showStudyTimer = false
    @State private var animateProgress = false
    @State private var showMoreLessonsOption = false
    @State private var particleAnimations: [UUID: Bool] = [:]
    
    private let theme: LessonTheme
    
    init(course: Course) {
        _viewModel = StateObject(wrappedValue: LessonMapViewModel(course: course))
        self.theme = ThemeEngine.generateTheme(for: course)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Consistent app background that matches the rest of the app
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
                    
                    // Enhanced dynamic particle system
                    ParticleSystemView(
                        theme: theme,
                        progress: viewModel.course.progress,
                        geometry: geometry
                    )
                    
                    VStack(spacing: 0) {
                        // Enhanced Header
                        DuolingoStyleHeader(
                            course: viewModel.course,
                            theme: theme,
                            onBackTapped: { dismiss() },
                            onInfoTapped: { showCourseDetails = true },
                            onTimerTapped: { showStudyTimer = true }
                        )
                        
                        // Interactive Lesson Map with enhanced animations
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                // Course title and progress at top
                                VStack(spacing: 16) {
                                    Text(viewModel.course.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2)
                                    
                                    EnhancedProgressOverview(
                                        course: viewModel.course, 
                                        theme: theme,
                                        animateProgress: animateProgress
                                    )
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                                
                                // The lesson path with enhanced interactions
                                EnhancedLessonPath(
                                    lessons: processedLessons,
                                    course: viewModel.course,
                                    theme: theme,
                                    viewModel: viewModel,
                                    showMoreLessonsOption: $showMoreLessonsOption,
                                    onLessonTap: { lesson in
                                        if !lesson.isLocked {
                                            selectedLesson = lesson
                                        }
                                    },
                                    screenWidth: geometry.size.width
                                )
                                .padding(.top, 30)
                                
                                // Enhanced Finish Line Celebration
                                if viewModel.course.isCompleted {
                                    EnhancedFinishLineCelebration(
                                        theme: theme,
                                        onGenerateMore: { showMoreLessonsOption = true }
                                    )
                                    .padding(.top, 40)
                                    .padding(.bottom, 50)
                                } else {
                                    Spacer(minLength: 100)
                                }
                            }
                        }
                    }
                    
                    // Enhanced XP Animation Overlay
                    if showXpAnimation {
                        EnhancedXPAnimationView(amount: xpGained, theme: theme)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showXpAnimation = false
                                }
                            }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCourseDetails) {
            CourseDetailView(course: viewModel.course)
        }
        .sheet(isPresented: $showStudyTimer) {
            StudyTimerView(course: viewModel.course)
                .environmentObject(studyTimer)
        }
        .sheet(item: $selectedLesson) { lesson in
            NavigationView {
                LessonPlayerView(lesson: lesson)
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showMoreLessonsOption) {
            GenerateMoreLessonsView(course: viewModel.course)
        }
        .onReceive(viewModel.xpGainedPublisher) { xp in
            xpGained = xp
            showXpAnimation = true
            animateProgress = true
        }
        .onAppear {
            animateProgress = true
        }
    }
    
    // Process lessons to implement proper locking logic
    private var processedLessons: [Lesson] {
        var processed = viewModel.lessons
        
        for i in 0..<processed.count {
            if i == 0 {
                // First lesson is always unlocked
                processed[i].isLocked = false
                if !processed[i].isCompleted && processed.filter({ $0.isCurrent }).isEmpty {
                    processed[i].isCurrent = true
                }
            } else {
                // Lock lesson if previous is not completed
                let previousCompleted = processed[i - 1].isCompleted
                processed[i].isLocked = !previousCompleted
                
                // Set current lesson
                if previousCompleted && !processed[i].isCompleted && !processed[i].isLocked {
                    // Clear other current states
                    for j in 0..<processed.count {
                        if j != i {
                            processed[j].isCurrent = false
                        }
                    }
                    processed[i].isCurrent = true
                }
            }
        }
        
        return processed
    }
}

// MARK: - Enhanced Header
private struct DuolingoStyleHeader: View {
    let course: Course
    let theme: LessonTheme
    let onBackTapped: () -> Void
    let onInfoTapped: () -> Void
    let onTimerTapped: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBackTapped) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
            
            Spacer()
            
            // Course info button
            Button(action: onInfoTapped) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(theme.primaryColor.opacity(0.3))
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
            
            // Streak indicator
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.accentColor)
                Text("5")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 4)
            
            // XP indicator
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.secondaryColor)
                Text("\(course.totalXP)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 4)
            
            Button(action: onTimerTapped) {
                Image(systemName: "timer")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Enhanced Progress Overview
struct EnhancedProgressOverview: View {
    let course: Course
    let theme: LessonTheme
    let animateProgress: Bool
    
    @State private var liquidAnimation = false
    @State private var sparkleAnimation = false
    @State private var progressValue: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Liquid-style progress bar with glassmorphism
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track with subtle texture
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .frame(height: 12)
                    
                    // Animated liquid progress fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.primaryColor,
                                    theme.secondaryColor,
                                    theme.accentColor.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressValue, height: 12)
                        .overlay(
                            // Liquid shimmer effect
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.white.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: 40, height: 12)
                                    .offset(x: liquidAnimation ? geometry.size.width : -40)
                            )
                        )
                        .shadow(color: theme.primaryColor.opacity(0.5), radius: 6, x: 0, y: 2)
                        .animation(.spring(response: 1.5, dampingFraction: 0.8), value: progressValue)
                    
                    // Progress sparkles
                    if course.progress > 0 {
                        HStack(spacing: 8) {
                            ForEach(0..<min(5, Int(course.progress * 5)), id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.8))
                                    .scaleEffect(sparkleAnimation ? 1.3 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: sparkleAnimation
                                    )
                            }
                            Spacer()
                        }
                        .position(x: geometry.size.width * progressValue - 20, y: 6)
                    }
                }
            }
            .frame(height: 12)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    progressValue = course.progress
                }
                
                // Start liquid animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        liquidAnimation = true
                    }
                }
                
                // Start sparkle animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    sparkleAnimation = true
                }
            }
            
            // Enhanced progress stats with glassmorphism
            HStack(spacing: 16) {
                // Progress text
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(course.completedLessonsCount) of \(course.lessons.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("lessons completed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Achievement badges
                HStack(spacing: 8) {
                    if course.progress >= 0.25 {
                        AchievementBadge(icon: "flame.fill", color: theme.accentColor, label: "Started")
                    }
                    if course.progress >= 0.5 {
                        AchievementBadge(icon: "bolt.fill", color: theme.primaryColor, label: "Halfway")
                    }
                    if course.progress >= 0.75 {
                        AchievementBadge(icon: "star.fill", color: theme.secondaryColor, label: "Almost")
                    }
                    if course.progress >= 1.0 {
                        AchievementBadge(icon: "crown.fill", color: .yellow, label: "Master")
                    }
                }
                
                Spacer()
                
                // Percentage with enhanced styling
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(course.progress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("complete")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 4)
        }
        .onChange(of: animateProgress) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    progressValue = course.progress
                }
            }
        }
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let icon: String
    let color: Color
    let label: String
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.5), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
            }
            
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Enhanced Lesson Path
struct EnhancedLessonPath: View {
    let lessons: [Lesson]
    let course: Course
    let theme: LessonTheme
    let viewModel: LessonMapViewModel
    @Binding var showMoreLessonsOption: Bool
    let onLessonTap: (Lesson) -> Void
    let screenWidth: CGFloat
    
    @State private var pathAnimationProgress: CGFloat = 0
    @State private var connectionAnimations: [UUID: Bool] = [:]
    
    // Zig-zag layout constants
    private let cardWidth: CGFloat = 280
    private let cardHeight: CGFloat = 80
    private let horizontalPadding: CGFloat = 20
    private let verticalSpacing: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(lessons.indices, id: \.self) { index in
                let lesson = lessons[index]
                let isLeftSide = index % 2 == 0
                
                VStack(spacing: 0) {
                    // Enhanced zig-zag connection line (except for first lesson)
                    if index > 0 {
                        EnhancedZigZagConnectionLine(
                            isCompleted: lessons[index - 1].isCompleted,
                            isNextCurrent: lesson.isCurrent,
                            theme: theme,
                            animationProgress: pathAnimationProgress,
                            fromLeft: (index - 1) % 2 == 0,
                            toLeft: index % 2 == 0,
                            screenWidth: screenWidth
                        )
                    }
                    
                    // Lesson card with zig-zag positioning
                    HStack {
                        if isLeftSide {
                            // Left side lesson
                            EnhancedLessonPillCard(
                                lesson: lesson,
                                course: course,
                                theme: theme,
                                index: index + 1,
                                isZigZag: true,
                                onTap: { 
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    onLessonTap(lesson) 
                                }
                            )
                            .frame(width: cardWidth, height: cardHeight)
                            
                            Spacer()
                        } else {
                            // Right side lesson
                            Spacer()
                            
                            EnhancedLessonPillCard(
                                lesson: lesson,
                                course: course,
                                theme: theme,
                                index: index + 1,
                                isZigZag: true,
                                onTap: { 
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    onLessonTap(lesson) 
                                }
                            )
                            .frame(width: cardWidth, height: cardHeight)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 8)
                }
            }
            
            // Enhanced generate more lessons button
            if lessons.allSatisfy({ $0.isCompleted }) {
                EnhancedGenerateMoreButton(theme: theme) {
                    showMoreLessonsOption = true
                }
                .padding(.top, 30)
            }
        }
        .padding(.horizontal, 0) // Remove horizontal padding since we handle it internally
        .padding(.vertical, 20)
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                pathAnimationProgress = 1.0
            }
        }
    }
}

// MARK: - Enhanced Zig-Zag Connection Line
struct EnhancedZigZagConnectionLine: View {
    let isCompleted: Bool
    let isNextCurrent: Bool
    let theme: LessonTheme
    let animationProgress: CGFloat
    let fromLeft: Bool
    let toLeft: Bool
    let screenWidth: CGFloat
    
    @State private var energyFlow = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Create curved path for zig-zag connections
                if fromLeft != toLeft {
                    // Diagonal connection between sides
                    CurvedConnectionPath(
                        fromLeft: fromLeft,
                        toLeft: toLeft,
                        isCompleted: isCompleted,
                        theme: theme,
                        animationProgress: animationProgress,
                        energyFlow: energyFlow
                    )
                    .frame(height: 60)
                } else {
                    // Straight connection for same side (shouldn't happen in zig-zag but just in case)
                    StraightConnectionPath(
                        isCompleted: isCompleted,
                        theme: theme,
                        animationProgress: animationProgress,
                        energyFlow: energyFlow
                    )
                    .frame(height: 40)
                }
                
                // Connection nodes for completed paths
                if isCompleted {
                    HStack {
                        if fromLeft {
                            Spacer()
                                .frame(width: screenWidth * 0.15)
                        }
                        
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(theme.accentColor.opacity(0.6))
                                .frame(width: 6, height: 6)
                                .scaleEffect(energyFlow ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: energyFlow
                                )
                        }
                        
                        if !fromLeft {
                            Spacer()
                                .frame(width: screenWidth * 0.15)
                        }
                    }
                }
            }
        }
        .onAppear {
            if isCompleted || isNextCurrent {
                energyFlow = true
            }
        }
    }
}

// MARK: - Curved Connection Path
struct CurvedConnectionPath: View {
    let fromLeft: Bool
    let toLeft: Bool
    let isCompleted: Bool
    let theme: LessonTheme
    let animationProgress: CGFloat
    let energyFlow: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let startX: CGFloat = fromLeft ? width * 0.25 : width * 0.75
                let endX: CGFloat = toLeft ? width * 0.25 : width * 0.75
                
                let startPoint = CGPoint(x: startX, y: 0)
                let endPoint = CGPoint(x: endX, y: height)
                
                // Create smooth curved path
                let controlPoint1 = CGPoint(x: startX, y: height * 0.3)
                let controlPoint2 = CGPoint(x: endX, y: height * 0.7)
                
                path.move(to: startPoint)
                path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
            }
            .trim(from: 0, to: animationProgress)
            .stroke(
                LinearGradient(
                    colors: pathColors,
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .shadow(color: shadowColor, radius: shadowRadius)
            
            // Energy flow animation
            if (isCompleted || energyFlow) && animationProgress > 0.5 {
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let startX: CGFloat = fromLeft ? width * 0.25 : width * 0.75
                    let endX: CGFloat = toLeft ? width * 0.25 : width * 0.75
                    
                    let startPoint = CGPoint(x: startX, y: 0)
                    let endPoint = CGPoint(x: endX, y: height)
                    
                    let controlPoint1 = CGPoint(x: startX, y: height * 0.3)
                    let controlPoint2 = CGPoint(x: endX, y: height * 0.7)
                    
                    path.move(to: startPoint)
                    path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
                }
                .trim(from: energyFlow ? 0.8 : 0, to: energyFlow ? 1.0 : 0.2)
                .stroke(
                    LinearGradient(
                        colors: [.clear, theme.accentColor.opacity(0.8), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .animation(
                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                    value: energyFlow
                )
            }
        }
    }
    
    private var pathColors: [Color] {
        if isCompleted {
            return [theme.accentColor.opacity(0.8), theme.primaryColor.opacity(0.6)]
        } else {
            return [Color.white.opacity(0.2), Color.white.opacity(0.1)]
        }
    }
    
    private var shadowColor: Color {
        isCompleted ? theme.accentColor.opacity(0.3) : Color.clear
    }
    
    private var shadowRadius: CGFloat {
        isCompleted ? 4 : 0
    }
}

// MARK: - Straight Connection Path (fallback)
struct StraightConnectionPath: View {
    let isCompleted: Bool
    let theme: LessonTheme
    let animationProgress: CGFloat
    let energyFlow: Bool
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: isCompleted ? 
                            [theme.accentColor.opacity(0.8), theme.primaryColor.opacity(0.6)] : 
                            [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 40)
                .scaleEffect(x: 1, y: animationProgress)
        }
    }
}

// MARK: - Enhanced Lesson Pill Card
struct EnhancedLessonPillCard: View {
    let lesson: Lesson
    let course: Course
    let theme: LessonTheme
    let index: Int
    let isZigZag: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var rippleOffset = CGSize.zero
    @State private var rippleScale: CGFloat = 0
    @State private var sparkleOffset = CGSize.zero
    @State private var sparkleOpacity: Double = 0
    
    // Zig-zag specific dimensions
    private var cardWidth: CGFloat { isZigZag ? 280 : 350 }
    private var cardHeight: CGFloat { isZigZag ? 80 : 70 }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            ZStack {
                // Main card background with glassmorphism
                RoundedRectangle(cornerRadius: isZigZag ? 20 : 25)
                    .fill(cardBackground)
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: isZigZag ? 20 : 25)
                            .stroke(borderGradient, lineWidth: 1.5)
                    )
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
                
                // Content with improved layout for zig-zag
                HStack(spacing: isZigZag ? 12 : 16) {
                    // Enhanced lesson number badge
                    ZStack {
                        Circle()
                            .fill(badgeGradient)
                            .frame(width: isZigZag ? 45 : 50, height: isZigZag ? 45 : 50)
                            .shadow(color: badgeColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("\(index)")
                            .font(.system(size: isZigZag ? 18 : 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    
                    // Lesson details with improved text layout
                    VStack(alignment: .leading, spacing: isZigZag ? 4 : 6) {
                        Text(lesson.title)
                            .font(.system(size: isZigZag ? 14 : 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(isZigZag ? 2 : 1)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.8)
                        
                        HStack(spacing: 8) {
                            // Status indicator
                            statusIndicator
                            
                            // Achievement badge for completed lessons
                            if lesson.isCompleted {
                                achievementBadge
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, isZigZag ? 16 : 20)
                .padding(.vertical, isZigZag ? 8 : 12)
                
                // Ripple effect overlay
                if rippleScale > 0 {
                    Circle()
                        .fill(theme.accentColor.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .scaleEffect(rippleScale)
                        .offset(rippleOffset)
                        .opacity(1 - Double(rippleScale))
                }
                
                // Sparkle effect for completed lessons
                if lesson.isCompleted && sparkleOpacity > 0 {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 12))
                            .foregroundColor(theme.accentColor)
                            .offset(
                                x: sparkleOffset.width + CGFloat.random(in: -30...30),
                                y: sparkleOffset.height + CGFloat.random(in: -20...20)
                            )
                            .opacity(sparkleOpacity)
                            .animation(
                                .easeOut(duration: 1.5).delay(Double(i) * 0.1),
                                value: sparkleOpacity
                            )
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onAppear {
            if lesson.isCompleted {
                // Trigger sparkle animation
                withAnimation(.easeInOut(duration: 0.5)) {
                    sparkleOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        sparkleOpacity = 0.0
                    }
                }
            }
        }
        .disabled(lesson.isLocked)
    }
    
    // MARK: - Computed Properties
    
    private var cardBackground: LinearGradient {
        if lesson.isCompleted {
            return LinearGradient(
                colors: [
                    theme.accentColor.opacity(0.8),
                    theme.primaryColor.opacity(0.6),
                    Color.black.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if lesson.isCurrent {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.15),
                    Color.black.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if lesson.isLocked {
            return LinearGradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.gray.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.08),
                    Color.black.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderGradient: LinearGradient {
        if lesson.isCompleted {
            return LinearGradient(
                colors: [theme.accentColor.opacity(0.8), theme.primaryColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if lesson.isCurrent {
            return LinearGradient(
                colors: [Color.white.opacity(0.6), Color.white.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var badgeGradient: LinearGradient {
        LinearGradient(
            colors: [badgeColor, badgeColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var badgeColor: Color {
        if lesson.isCompleted {
            return theme.accentColor
        } else if lesson.isCurrent {
            return Color.blue // Vibrant blue for current lesson
        } else if lesson.isLocked {
            return Color.gray.opacity(0.6)
        } else {
            return Color.green // Vibrant green for available lessons
        }
    }
    
    private var shadowColor: Color {
        if lesson.isCompleted {
            return theme.accentColor.opacity(0.4)
        } else if lesson.isCurrent {
            return Color.white.opacity(0.3)
        } else {
            return Color.black.opacity(0.3)
        }
    }
    
    private var shadowRadius: CGFloat {
        lesson.isCompleted ? 8 : 4
    }
    
    private var shadowOffset: CGFloat {
        isPressed ? 2 : 4
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        HStack(spacing: 4) {
            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: isZigZag ? 12 : 14))
                    .foregroundColor(theme.accentColor)
                
                Text("Completed")
                    .font(.system(size: isZigZag ? 10 : 12, weight: .medium))
                    .foregroundColor(theme.accentColor)
            } else if lesson.isCurrent {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: isZigZag ? 12 : 14))
                    .foregroundColor(.white)
                
                Text("Continue Learning")
                    .font(.system(size: isZigZag ? 10 : 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            } else if lesson.isLocked {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: isZigZag ? 12 : 14))
                    .foregroundColor(.gray.opacity(0.6))
                
                Text("Locked")
                    .font(.system(size: isZigZag ? 10 : 12, weight: .medium))
                    .foregroundColor(.gray.opacity(0.6))
            } else {
                Image(systemName: "circle.dotted")
                    .font(.system(size: isZigZag ? 12 : 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Available")
                    .font(.system(size: isZigZag ? 10 : 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    @ViewBuilder
    private var achievementBadge: some View {
        if lesson.isCompleted {
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: isZigZag ? 8 : 10))
                    .foregroundColor(.yellow)
                
                Text("NEXT")
                    .font(.system(size: isZigZag ? 8 : 10, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.yellow.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Enhanced Generate More Button
struct EnhancedGenerateMoreButton: View {
    let theme: LessonTheme
    let onTap: () -> Void
    
    @State private var pulseAnimation = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    
                    Text("Generate More Lessons")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        // Main gradient background
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [theme.primaryColor, theme.secondaryColor, theme.accentColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color.white.opacity(0.3), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 60)
                                    .offset(x: shimmerOffset)
                            )
                        
                        // Border highlight
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: theme.primaryColor.opacity(0.5), radius: 12, x: 0, y: 6)
            }
        }
        .onAppear {
            // Pulse animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
}

// MARK: - Enhanced Finish Line Celebration
struct EnhancedFinishLineCelebration: View {
    let theme: LessonTheme
    let onGenerateMore: () -> Void
    
    @State private var animateFlag = false
    @State private var animateConfetti = false
    @State private var trophyGlow = false
    @State private var confettiParticles: [ConfettiParticle] = []
    
    private struct ConfettiParticle: Identifiable {
        let id = UUID()
        let color: Color
        let size: CGFloat
        let initialPosition: CGPoint
        let finalPosition: CGPoint
        let rotation: Double
    }
    
    var body: some View {
        ZStack {
            // Confetti particles
            ForEach(confettiParticles) { particle in
                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(animateConfetti ? particle.finalPosition : particle.initialPosition)
                    .rotationEffect(.degrees(animateConfetti ? particle.rotation : 0))
                    .opacity(animateConfetti ? 0 : 1)
                    .animation(
                        .easeOut(duration: 3.0).delay(Double.random(in: 0...1)),
                        value: animateConfetti
                    )
            }
            
            VStack(spacing: 20) {
                // Animated trophy with glow
                ZStack {
                    // Trophy glow
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow.opacity(0.3))
                        .scaleEffect(trophyGlow ? 1.3 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: trophyGlow
                        )
                    
                    // Main trophy
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                        .scaleEffect(animateFlag ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateFlag)
                }
                
                Text("Course Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .scaleEffect(animateFlag ? 1.0 : 0.8)
                    .animation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2), value: animateFlag)
                
                Text("Congratulations! You've mastered this topic.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateFlag ? 1.0 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.4), value: animateFlag)
                
                // Enhanced generate more lessons button
                EnhancedGenerateMoreButton(theme: theme, onTap: onGenerateMore)
                    .padding(.horizontal, 40)
                    .scaleEffect(animateFlag ? 1.0 : 0.8)
                    .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.6), value: animateFlag)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.5), theme.accentColor.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    // Celebration glow
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            RadialGradient(
                                colors: [.yellow.opacity(0.1), .clear],
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .scaleEffect(trophyGlow ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                            value: trophyGlow
                        )
                }
            )
        }
        .onAppear {
            // Create confetti particles
            confettiParticles = createConfettiParticles()
            
            withAnimation(.easeInOut(duration: 1.0)) {
                animateFlag = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateConfetti = true
                trophyGlow = true
            }
        }
    }
    
    private func createConfettiParticles() -> [ConfettiParticle] {
        let colors = [theme.primaryColor, theme.secondaryColor, theme.accentColor, .yellow, .orange]
        var particles: [ConfettiParticle] = []
        
        for _ in 0..<30 {
            let particle = ConfettiParticle(
                color: colors.randomElement() ?? theme.primaryColor,
                size: CGFloat.random(in: 6...12),
                initialPosition: CGPoint(x: 200, y: 100),
                finalPosition: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 300...600)
                ),
                rotation: Double.random(in: 0...720)
            )
            particles.append(particle)
        }
        
        return particles
    }
}

// MARK: - Enhanced XP Animation View
struct EnhancedXPAnimationView: View {
    let amount: Int
    let theme: LessonTheme
    
    @State private var showXP = false
    @State private var xpScale = 0.5
    @State private var xpOffset: CGFloat = 0
    @State private var xpOpacity = 0.0
    @State private var sparkles: [SparkleParticle] = []
    
    private struct SparkleParticle: Identifiable {
        let id = UUID()
        let position: CGPoint
        let delay: Double
        let color: Color
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(showXP ? 1 : 0)
                .animation(.easeIn(duration: 0.3), value: showXP)
            
            VStack(spacing: 16) {
                // XP burst with sparkles
                ZStack {
                    // Sparkle particles
                    ForEach(sparkles) { sparkle in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(sparkle.color)
                            .position(sparkle.position)
                            .scaleEffect(showXP ? 1.5 : 0)
                            .opacity(showXP ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.5).delay(sparkle.delay),
                                value: showXP
                            )
                    }
                    
                    // Main XP display
                    VStack(spacing: 8) {
                        Text("+\(amount) XP")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: theme.accentColor, radius: 8)
                            .scaleEffect(xpScale)
                        
                        Text("Experience Gained!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(xpOpacity)
                    }
                    .offset(y: xpOffset)
                }
                
                // Achievement ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: showXP ? 1 : 0)
                        .stroke(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0).delay(0.5), value: showXP)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.accentColor)
                        .scaleEffect(showXP ? 1.2 : 0.8)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.6).delay(1.2),
                            value: showXP
                        )
                }
            }
        }
        .onAppear {
            // Create sparkle particles
            sparkles = createSparkleParticles()
            
            // Animate XP display
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showXP = true
                xpScale = 1.2
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                xpOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                xpOffset = -20
            }
            
            // Scale back to normal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.3)) {
                    xpScale = 1.0
                }
            }
        }
    }
    
    private func createSparkleParticles() -> [SparkleParticle] {
        let colors = [theme.primaryColor, theme.secondaryColor, theme.accentColor, .white]
        var particles: [SparkleParticle] = []
        
        for i in 0..<12 {
            let angle = Double(i) * 30 * .pi / 180
            let radius: CGFloat = 100
            let position = CGPoint(
                x: 200 + cos(CGFloat(angle)) * radius,
                y: 200 + sin(CGFloat(angle)) * radius
            )
            
            let particle = SparkleParticle(
                position: position,
                delay: Double(i) * 0.1,
                color: colors.randomElement() ?? theme.primaryColor
            )
            particles.append(particle)
        }
        
        return particles
    }
}

// MARK: - Course Detail View
private struct CourseDetailView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Course header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(course.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            Label(course.difficulty.rawValue.capitalized, systemImage: course.difficulty.icon)
                                .foregroundColor(Color(course.difficulty.color))
                            
                            Label(course.estimatedDuration, systemImage: "clock")
                                .foregroundColor(.secondary)
                            
                            Label("\(course.lessons.count) lessons", systemImage: "book")
                                .foregroundColor(.secondary)
                        }
                        .font(.system(size: 14, weight: .medium))
                    }
                    
                    Divider()
                    
                    // Course description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About This Course")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Dive deep into \(course.topic) with this comprehensive course. You'll explore key concepts, analyze important events, and develop a thorough understanding of the subject matter through interactive lessons and engaging content.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // Learning objectives
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What You'll Learn")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        ForEach([
                            "Master the fundamental concepts and key principles",
                            "Analyze important events and their significance",
                            "Develop critical thinking skills through interactive exercises",
                            "Apply knowledge through practical examples and scenarios"
                        ], id: \.self) { objective in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 16))
                                
                                Text(objective)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .navigationTitle("Course Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Generate More Lessons View
private struct GenerateMoreLessonsView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var numberOfLessons = 5
    @State private var focusArea = ""
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Generate More Lessons")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Continue learning about \(course.topic) with additional lessons tailored to your progress.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Lessons")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            ForEach([3, 5, 10], id: \.self) { number in
                                Button("\(number)") {
                                    numberOfLessons = number
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(numberOfLessons == number ? .white : .blue)
                                .frame(width: 60, height: 40)
                                .background(numberOfLessons == number ? Color.blue : Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Focus Area (Optional)")
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField("e.g., specific battles, key figures, outcomes...", text: $focusArea)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: generateLessons) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18))
                            }
                            
                            Text(isGenerating ? "Generating..." : "Generate Lessons")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    .disabled(isGenerating)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationBarHidden(true)
        }
    }
    
    private func generateLessons() {
        isGenerating = true
        
        // Simulate generation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            dismiss()
            // Here you would actually generate the lessons
        }
    }
}

// MARK: - View Extensions
extension View {
    func pressAction(action: @escaping (Bool) -> Void) -> some View {
        self.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in action(true) }
                .onEnded { _ in action(false) }
        )
    }
}

// MARK: - Previews
struct LessonMapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLessons = [
            Lesson(title: "The Spark: Assassination and Alliances", lessonNumber: 1, isCompleted: true),
            Lesson(title: "Life in the Trenches: A New Kind of War", lessonNumber: 2, isCurrent: true),
            Lesson(title: "The War's Global Reach", lessonNumber: 3),
            Lesson(title: "America Enters the Fray", lessonNumber: 4),
            Lesson(title: "The Treaty of Versailles and Its Legacy", lessonNumber: 5)
        ]
        let sampleCourse = Course(
            id: UUID(),
            title: "The Great War: A Deep Dive into WWI",
            topic: "World War I",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: sampleLessons,
            createdAt: Date()
        )
        
        return NavigationView {
            LessonMapView(course: sampleCourse)
                .environmentObject(StreakManager())
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Enhanced Particle System
struct ParticleSystemView: View {
    let theme: LessonTheme
    let progress: Double
    let geometry: GeometryProxy
    
    @State private var particleAnimations: [UUID: ParticleState] = [:]
    @State private var breathingAnimation = false
    
    private struct ParticleState {
        var opacity: Double
        var scale: Double
        var rotation: Double
        var position: CGPoint
    }
    
    var body: some View {
        ZStack {
            // Background ambient particles
            ForEach(0..<particleCount, id: \.self) { index in
                let particleId = UUID()
                let element = theme.ambientElements.randomElement() ?? theme.ambientElements.first!
                
                Image(systemName: element.symbol)
                    .font(.system(size: element.size * sizeMultiplier))
                    .foregroundColor(element.color.opacity(baseOpacity))
                    .scaleEffect(particleAnimations[particleId]?.scale ?? 1.0)
                    .rotationEffect(.degrees(particleAnimations[particleId]?.rotation ?? 0))
                    .position(particleAnimations[particleId]?.position ?? randomPosition())
                    .opacity(particleAnimations[particleId]?.opacity ?? 0.1)
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...8))
                        .repeatForever(autoreverses: true),
                        value: particleAnimations[particleId]?.opacity
                    )
                    .onAppear {
                        let delay = Double(index) * 0.3
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeInOut(duration: Double.random(in: 4...8)).repeatForever(autoreverses: true)) {
                                particleAnimations[particleId] = ParticleState(
                                    opacity: Double.random(in: 0.2...0.6),
                                    scale: Double.random(in: 0.8...1.4),
                                    rotation: Double.random(in: 0...360),
                                    position: randomPosition()
                                )
                            }
                        }
                    }
            }
            
            // Progress celebration particles (appear as user progresses)
            if progress > 0.25 {
                ForEach(0..<celebrationParticleCount, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 6))
                        .foregroundColor(theme.accentColor.opacity(0.8))
                        .scaleEffect(breathingAnimation ? 1.2 : 0.8)
                        .position(randomPosition())
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: breathingAnimation
                        )
                }
                .onAppear {
                    breathingAnimation = true
                }
            }
            
            // Mastery glow particles (appear when near completion)
            if progress > 0.75 {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [theme.primaryColor.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .position(
                            x: CGFloat.random(in: 60...geometry.size.width - 60),
                            y: CGFloat.random(in: 150...geometry.size.height - 150)
                        )
                        .scaleEffect(breathingAnimation ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.8),
                            value: breathingAnimation
                        )
                }
            }
        }
    }
    
    private var particleCount: Int {
        // More particles as user progresses
        Int(8 + (progress * 12))
    }
    
    private var celebrationParticleCount: Int {
        Int(progress * 8)
    }
    
    private var sizeMultiplier: Double {
        1.0 + (progress * 0.5) // Particles get slightly larger as user progresses
    }
    
    private var baseOpacity: Double {
        0.2 + (progress * 0.3) // Particles get more visible as user progresses
    }
    
    private func randomPosition() -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 50...geometry.size.width - 50),
            y: CGFloat.random(in: 100...geometry.size.height - 100)
        )
    }
}
