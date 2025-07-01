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
                    // Enhanced gradient background
                    LinearGradient(
                        colors: theme.backgroundGradient + [theme.backgroundGradient.last!.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Subtle floating particles
                    ForEach(0..<8, id: \.self) { index in
                        let element = theme.ambientElements.randomElement() ?? theme.ambientElements.first!
                        let animationKey = UUID()
                        
                        Image(systemName: element.symbol)
                            .font(.system(size: element.size))
                            .foregroundColor(element.color.opacity(0.3))
                            .position(
                                x: CGFloat.random(in: 50...geometry.size.width - 50),
                                y: CGFloat.random(in: 100...geometry.size.height - 100)
                            )
                            .opacity(particleAnimations[animationKey] == true ? 0.4 : 0.1)
                            .animation(
                                .easeInOut(duration: Double.random(in: 6...10))
                                .repeatForever(autoreverses: true),
                                value: particleAnimations[animationKey]
                            )
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                                    particleAnimations[animationKey] = true
                                }
                            }
                    }
                    
                    VStack(spacing: 0) {
                        // Enhanced Header
                        DuolingoStyleHeader(
                            course: viewModel.course,
                            theme: theme,
                            onBackTapped: { dismiss() },
                            onInfoTapped: { showCourseDetails = true },
                            onTimerTapped: { showStudyTimer = true }
                        )
                        
                        // Interactive Lesson Map with winding path
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                // Course title and progress at top
                                VStack(spacing: 16) {
                                    Text(viewModel.course.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2)
                                    
                                    ProgressOverview(course: viewModel.course, theme: theme)
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                                
                                // The lesson path with proper locking
                                LessonPath(
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
                                
                                // Finish Line Celebration
                                if viewModel.course.isCompleted {
                                    FinishLineCelebration(
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
                    
                    // XP Animation Overlay
                    if showXpAnimation {
                        XPAnimationView(amount: xpGained)
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

// MARK: - Progress Overview
private struct ProgressOverview: View {
    let course: Course
    let theme: LessonTheme
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * course.progress, height: 8)
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: course.progress)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(course.completedLessonsCount) of \(course.lessons.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(Int(course.progress * 100))% complete")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Modern Lesson Path with Pills
private struct LessonPath: View {
    let lessons: [Lesson]
    let course: Course
    let theme: LessonTheme
    let viewModel: LessonMapViewModel
    @Binding var showMoreLessonsOption: Bool
    let onLessonTap: (Lesson) -> Void
    let screenWidth: CGFloat
    
    @State private var pathAnimationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(lessons.indices, id: \.self) { index in
                let lesson = lessons[index]
                
                VStack(spacing: 12) {
                    // Connection line (except for first lesson)
                    if index > 0 {
                        ConnectionLine(
                            isCompleted: lessons[index - 1].isCompleted,
                            theme: theme
                        )
                    }
                    
                    // Lesson pill card
                    LessonPillCard(
                        lesson: lesson,
                        course: course,
                        theme: theme,
                        index: index + 1,
                        onTap: { onLessonTap(lesson) }
                    )
                }
            }
            
            // Generate more lessons button at the bottom
            if lessons.allSatisfy({ $0.isCompleted }) {
                GenerateMoreButton(theme: theme) {
                    showMoreLessonsOption = true
                }
                .padding(.top, 30)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}

// MARK: - Connection Line
private struct ConnectionLine: View {
    let isCompleted: Bool
    let theme: LessonTheme
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: isCompleted ? 
                        [theme.primaryColor, theme.secondaryColor] : 
                        [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4, height: 40)
            .cornerRadius(2)
    }
}

// MARK: - Generate More Button
private struct GenerateMoreButton: View {
    let theme: LessonTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Generate More Lessons")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [theme.primaryColor, theme.secondaryColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: theme.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}



// MARK: - Lesson Pill Card
private struct LessonPillCard: View {
    let lesson: Lesson
    let course: Course
    let theme: LessonTheme
    let index: Int
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: {
            if !lesson.isLocked {
                onTap()
            }
        }) {
            HStack(spacing: 16) {
                // Lesson number circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: circleGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    if lesson.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    } else if lesson.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(index)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: theme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // Lesson content
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: dynamicIcon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(statusText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        if lesson.isCurrent {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(theme.accentColor)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: cardGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: lesson.isCurrent ? theme.primaryColor.opacity(0.4) : Color.black.opacity(0.2),
                radius: lesson.isCurrent ? 12 : 6,
                x: 0,
                y: lesson.isCurrent ? 6 : 3
            )
        }
        .disabled(lesson.isLocked)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onAppear {
            if lesson.isCurrent {
                glowAnimation = true
            }
        }
        .pressAction { pressed in
            isPressed = pressed
        }
    }
    
    private var circleGradientColors: [Color] {
        if lesson.isCompleted {
            return [theme.accentColor, theme.accentColor.opacity(0.8)]
        } else if lesson.isCurrent {
            return [theme.primaryColor, theme.secondaryColor]
        } else if !lesson.isLocked {
            return [theme.secondaryColor.opacity(0.9), theme.primaryColor.opacity(0.7)]
        } else {
            return [Color.gray.opacity(0.7), Color.gray.opacity(0.5)]
        }
    }
    
    private var cardGradientColors: [Color] {
        if lesson.isLocked {
            return [Color.black.opacity(0.4), Color.black.opacity(0.6)]
        } else if lesson.isCurrent {
            return [Color.white.opacity(0.15), Color.white.opacity(0.25)]
        } else {
            return [Color.white.opacity(0.1), Color.white.opacity(0.2)]
        }
    }
    
    private var dynamicIcon: String {
        if lesson.isLocked {
            return "lock.fill"
        } else if lesson.isCompleted {
            return "checkmark.circle.fill"
        } else {
            return ThemeEngine.generateLessonIcon(for: lesson, in: course)
        }
    }
    
    private var statusText: String {
        if lesson.isCompleted {
            return "Completed"
        } else if lesson.isCurrent {
            return "Continue Learning"
        } else if lesson.isLocked {
            return "Locked"
        } else {
            return "Ready to Start"
        }
    }
}

// MARK: - Finish Line Celebration
private struct FinishLineCelebration: View {
    let onGenerateMore: () -> Void
    @State private var animateFlag = false
    @State private var animateConfetti = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Finish line with flags
            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Color.black : Color.white)
                        .frame(height: 80)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .delay(Double(index) * 0.1),
                            value: animateFlag
                        )
                        .scaleEffect(y: animateFlag ? 1.0 : 0.1)
                }
            }
            .frame(height: 80)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.3), radius: 4)
            
            // Celebration content
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                
                Text("Course Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                
                Text("Congratulations! You've mastered this topic.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Generate more lessons button
                Button(action: onGenerateMore) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Generate More Lessons")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                }
                .padding(.horizontal, 40)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                    )
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateFlag = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateConfetti = true
            }
        }
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

// MARK: - Press Action Modifier
extension View {
    func pressAction(perform action: @escaping (Bool) -> Void) -> some View {
        self.onPressGesture(action: action)
    }
}

// Enhanced XP Animation
private struct XPAnimationView: View {
    let amount: Int
    @State private var isAnimating = false
    @State private var particles: [ParticleData] = []
    
    struct ParticleData: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var life: Double = 1.0
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("+ \(amount) XP")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text("Great job!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .offset(y: isAnimating ? -50 : 0)
            .opacity(isAnimating ? 0 : 1)
            
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 6, height: 6)
                    .position(particle.position)
                    .opacity(particle.life)
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 2.0)) {
                isAnimating = true
            }
            animateParticles()
        }
    }
    
    private func generateParticles() {
        let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        particles = (0..<20).map { _ in
            ParticleData(
                position: center,
                velocity: CGPoint(
                    x: Double.random(in: -200...200),
                    y: Double.random(in: -300...100)
                )
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x * 0.016
                particles[i].position.y += particles[i].velocity.y * 0.016
                particles[i].velocity.y += 500 * 0.016
                particles[i].life -= 0.016 / 2.0
            }
            
            particles = particles.filter { $0.life > 0 }
            
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
}

// Custom gesture modifier
extension View {
    func onPressGesture(action: @escaping (Bool) -> Void) -> some View {
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
