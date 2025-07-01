import SwiftUI

struct CourseDetailSheetView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Enhanced gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles background
            ParticleBackgroundView()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                // Enhanced Header
                EnhancedHeaderView(course: course) {
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Main Content
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // Course Title & Stats Section
                        CourseTitleSection(course: course)
                        
                        // About This Course Section
                        AboutCourseSection(course: course)
                        
                        // What You'll Learn Section
                        LearningObjectivesSection(course: course)
                        
                        // Who It's For Section
                        TargetAudienceSection(course: course)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
}

// MARK: - Enhanced Header
struct EnhancedHeaderView: View {
    let course: Course
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text("Course Details")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Button(action: onDismiss) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("Done")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Course Title Section
struct CourseTitleSection: View {
    let course: Course
    @State private var animateTitle = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Course Title
            Text(course.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .scaleEffect(animateTitle ? 1.0 : 0.9)
                .opacity(animateTitle ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateTitle)
            
            // Stats Row
            HStack(spacing: 20) {
                StatPill(
                    icon: "clock.fill",
                    text: course.estimatedTime.isEmpty ? "45 min" : course.estimatedTime,
                    color: .blue
                )
                
                StatPill(
                    icon: "book.fill",
                    text: "\(course.lessons.count) lessons",
                    color: .green
                )
                
                Spacer()
            }
        }
        .onAppear {
            animateTitle = true
        }
    }
}

// MARK: - About Course Section
struct AboutCourseSection: View {
    let course: Course
    
    var body: some View {
        EnhancedInfoCard(
            title: "About This Course",
            icon: "info.circle.fill",
            gradient: LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            Text(course.overview.isEmpty ? "Dive deep into \(course.title) with this comprehensive course. You'll explore key concepts, analyze important events, and develop a thorough understanding of the subject matter through interactive lessons and engaging content." : course.overview)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
    }
}

// MARK: - Learning Objectives Section
struct LearningObjectivesSection: View {
    let course: Course
    @State private var animateObjectives = false
    
    var body: some View {
        EnhancedInfoCard(
            title: "What You'll Learn",
            icon: "target",
            gradient: LinearGradient(
                colors: [Color.green.opacity(0.6), Color.mint.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(learningObjectives.enumerated()), id: \.offset) { index, objective in
                    EnhancedObjectiveRow(
                        text: objective,
                        index: index,
                        isAnimated: animateObjectives
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                animateObjectives = true
            }
        }
    }
    
    private var learningObjectives: [String] {
        if course.learningObjectives.isEmpty {
            return [
                "Master the fundamental concepts and key principles",
                "Analyze important events and their significance", 
                "Develop critical thinking skills through interactive exercises",
                "Apply knowledge through practical examples and scenarios"
            ]
        }
        return course.learningObjectives
    }
}

// MARK: - Target Audience Section
struct TargetAudienceSection: View {
    let course: Course
    
    var body: some View {
        EnhancedInfoCard(
            title: "Who It's For",
            icon: "person.2.fill",
            gradient: LinearGradient(
                colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            Text(course.whoIsThisFor.isEmpty ? "Perfect for learners of all levels who want to explore \(course.topic) in depth. Whether you're a beginner or looking to deepen your understanding, this course provides engaging content tailored to your learning journey." : course.whoIsThisFor)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
    }
}

// MARK: - Enhanced Components

struct EnhancedInfoCard<Content: View>: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    @ViewBuilder let content: Content
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.white.opacity(0.2), radius: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Content
            content
        }
        .padding(24)
        .background(
            ZStack {
                // Glassmorphism background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
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
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                // Subtle inner glow
                RoundedRectangle(cornerRadius: 20)
                    .fill(gradient.opacity(0.1))
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

struct EnhancedObjectiveRow: View {
    let text: String
    let index: Int
    let isAnimated: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .shadow(color: Color.green.opacity(0.4), radius: 4)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimated ? 1.0 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.1), value: isAnimated)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(2)
                .offset(x: isAnimated ? 0 : 20)
                .opacity(isAnimated ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1 + 0.2), value: isAnimated)
        }
    }
}

struct StatPill: View {
    let icon: String
    let text: String
    let color: Color
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Capsule()
                    .fill(color.opacity(0.1))
            }
        )
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Particle Background
struct ParticleBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animate ? CGFloat.random(in: 0.5...1.2) : 1.0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Preview
struct CourseDetailSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCourse = Course(
            id: UUID(),
            title: "Mathematics",
            topic: "Advanced Mathematics",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: [
                Lesson(title: "Introduction", lessonNumber: 1),
                Lesson(title: "Fundamentals", lessonNumber: 2),
                Lesson(title: "Advanced Topics", lessonNumber: 3),
                Lesson(title: "Applications", lessonNumber: 4),
                Lesson(title: "Practice", lessonNumber: 5),
                Lesson(title: "Review", lessonNumber: 6),
                Lesson(title: "Final Assessment", lessonNumber: 7)
            ],
            createdAt: Date(),
            overview: "Dive deep into Mathematics with this comprehensive course. You'll explore key concepts, analyze important events, and develop a thorough understanding of the subject matter through interactive lessons and engaging content.",
            learningObjectives: [
                "Master the fundamental concepts and key principles",
                "Analyze important events and their significance",
                "Develop critical thinking skills through interactive exercises", 
                "Apply knowledge through practical examples and scenarios"
            ],
            whoIsThisFor: "Perfect for history buffs, students, or anyone curious about this defining moment.",
            estimatedTime: "1h 45m"
        )

        CourseDetailSheetView(course: sampleCourse)
    }
} 