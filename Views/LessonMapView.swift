import SwiftUI

// A simple linear progress bar to replace ProgressView determinate style
struct CustomProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(.gray.opacity(0.3))
                Capsule()
                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                    .foregroundColor(.cyan)
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
    
    init(course: Course) {
        _viewModel = StateObject(wrappedValue: LessonMapViewModel(course: course))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Enhanced gradient background that fits the UI better
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8),  // Deeper blue
                            Color(red: 0.1, green: 0.6, blue: 0.7),  // Rich teal
                            Color(red: 0.2, green: 0.7, blue: 0.5),  // Forest green
                            Color(red: 0.3, green: 0.8, blue: 0.4)   // Vibrant green
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Floating elements for depth
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 20...60))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true),
                                value: animateProgress
                            )
                    }
                    
                    VStack(spacing: 0) {
                        // Enhanced Header
                        DuolingoStyleHeader(
                            course: viewModel.course,
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
                                    
                                    ProgressOverview(course: viewModel.course)
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                                
                                // The lesson path with proper locking
                                LessonPath(
                                    lessons: processedLessons,
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
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
            
            // Streak indicator
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
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
                    .foregroundColor(.yellow)
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
                                colors: [.yellow, .orange],
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

// MARK: - Enhanced Lesson Path
private struct LessonPath: View {
    let lessons: [Lesson]
    let onLessonTap: (Lesson) -> Void
    let screenWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let pathSpacing: CGFloat = 140
            
            ZStack {
                // Draw connecting path
                Path { path in
                    for index in 0..<lessons.count {
                        let position = nodePosition(for: index, width: width, spacing: pathSpacing)
                        
                        if index == 0 {
                            path.move(to: position)
                        } else {
                            path.addLine(to: position)
                        }
                    }
                }
                .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                
                // Draw completed path sections
                Path { path in
                    for index in 0..<lessons.count {
                        if lessons[index].isCompleted || lessons[index].isCurrent {
                            let position = nodePosition(for: index, width: width, spacing: pathSpacing)
                            
                            if index == 0 || (index > 0 && lessons[index - 1].isCompleted) {
                                if index == 0 {
                                    path.move(to: position)
                                } else {
                                    let prevPosition = nodePosition(for: index - 1, width: width, spacing: pathSpacing)
                                    path.move(to: prevPosition)
                                    path.addLine(to: position)
                                }
                            }
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [.yellow, .orange, .green],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                
                // Lesson nodes
                ForEach(lessons.indices, id: \.self) { index in
                    let lesson = lessons[index]
                    let position = nodePosition(for: index, width: width, spacing: pathSpacing)
                    
                    DuolingoLessonNode(
                        lesson: lesson,
                        index: index + 1,
                        screenWidth: screenWidth,
                        onTap: { onLessonTap(lesson) }
                    )
                    .position(position)
                }
            }
        }
        .frame(height: CGFloat(lessons.count) * 140 + 100)
    }
    
    private func nodePosition(for index: Int, width: CGFloat, spacing: CGFloat) -> CGPoint {
        let centerX = width / 2
        let y = CGFloat(index) * spacing + 50
        
        // Create a winding path like Duolingo
        let amplitude: CGFloat = 80
        let frequency: Double = 0.6
        let offset = sin(Double(index) * frequency) * amplitude
        
        return CGPoint(x: centerX + offset, y: y)
    }
}

// MARK: - Enhanced Duolingo Lesson Node
private struct DuolingoLessonNode: View {
    let lesson: Lesson
    let index: Int
    let screenWidth: CGFloat
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var bounceAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: {
            if !lesson.isLocked {
                onTap()
            }
        }) {
            ZStack {
                // Glow effect for current lesson
                if lesson.isCurrent {
                    Circle()
                        .fill(Color.yellow.opacity(glowAnimation ? 0.6 : 0.2))
                        .frame(width: 100, height: 100)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowAnimation)
                }
                
                // Main circle
                Circle()
                    .fill(nodeColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: lesson.isCurrent ? 4 : 2)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                
                // Content
                VStack(spacing: 4) {
                    Image(systemName: nodeIcon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(index)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Lock overlay for locked lessons
                if lesson.isLocked {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Checkmark for completed lessons
                if lesson.isCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                                .background(Color.white, in: Circle())
                                .offset(x: 8, y: -8)
                        }
                        Spacer()
                    }
                    .frame(width: 80, height: 80)
                }
            }
        }
        .disabled(lesson.isLocked)
        .scaleEffect(isPressed ? 0.9 : (bounceAnimation ? 1.1 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bounceAnimation)
        .onAppear {
            if lesson.isCurrent {
                glowAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    bounceAnimation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        bounceAnimation = false
                    }
                }
            }
        }
        .pressAction { pressed in
            isPressed = pressed
        }
        
        // Dynamic lesson title positioning
        .overlay(
            VStack {
                Spacer()
                Text(lesson.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 2)
                    .padding(.horizontal, 8)
                    .frame(width: min(screenWidth * 0.4, 140))
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(y: 55)
            }
        )
    }
    
    private var nodeColor: Color {
        if lesson.isCompleted {
            return Color.green
        } else if lesson.isCurrent {
            return Color.orange
        } else if !lesson.isLocked {
            return Color.blue
        } else {
            return Color.gray
        }
    }
    
    private var nodeIcon: String {
        if lesson.isCompleted {
            return "star.fill"
        } else if lesson.isCurrent {
            return "play.fill"
        } else if !lesson.isLocked {
            return lesson.type.icon
        } else {
            return "lock.fill"
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
