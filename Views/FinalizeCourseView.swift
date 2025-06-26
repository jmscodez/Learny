import SwiftUI

struct FinalizeCourseView: View {
    @EnvironmentObject private var generationManager: CourseGenerationManager
    @EnvironmentObject private var statsManager: LearningStatsManager
    @EnvironmentObject private var notesManager: NotificationsManager
    
    @State var lessons: [LessonSuggestion]
    let topic: String
    let difficulty: Difficulty
    let pace: Pace
    
    let onCancel: () -> Void
    let onGenerate: () -> Void
    
    @State private var animationProgress: Double = 0
    
    init(lessons: [LessonSuggestion], topic: String, difficulty: Difficulty, pace: Pace, onCancel: @escaping () -> Void, onGenerate: @escaping () -> Void) {
        self._lessons = State(initialValue: lessons)
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
        self.onCancel = onCancel
        self.onGenerate = onGenerate
    }
    
    // Supports swipe-to-delete
    private func deleteLesson(at offsets: IndexSet) {
        lessons.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Consistent gradient background
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

                VStack(spacing: 24) {
                    // Header section
                    VStack(spacing: 16) {
                        Text("Finalize Your Course")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .scaleEffect(animationProgress)
                        
                        Text("Review and customize your \(lessons.count) selected lessons")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(animationProgress)
                    }
                    .padding(.top, 20)
                    
                    // Lessons list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                                ModernLessonRow(index: index + 1, lesson: lesson)
                                    .opacity(animationProgress)
                                    .offset(y: animationProgress == 1.0 ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animationProgress)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Action buttons
                    VStack(spacing: 16) {
                        ModernGenerateButton(action: startGeneration)
                            .scaleEffect(animationProgress)
                            .opacity(animationProgress)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom navigation bar
                VStack {
                    HStack {
                        Button(action: onCancel) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                Text("Cancel")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func startGeneration() {
        generationManager.generateCourse(
            topic: topic,
            suggestions: lessons,
            difficulty: difficulty,
            pace: pace,
            statsManager: statsManager,
            notificationsManager: notesManager
        )
        onGenerate()
    }
}

private struct ModernLessonRow: View {
    let index: Int
    let lesson: LessonSuggestion
    
    // Generate a consistent color from the lesson's ID
    private var color: Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .cyan]
        return colors[lesson.id.hashValue % colors.count]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Lesson number
            ZStack {
                Circle()
                .fill(color)
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(20)
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

private struct ModernGenerateButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
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
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct FinalizeCourseView_Previews: PreviewProvider {
    static var previews: some View {
        FinalizeCourseView(
            lessons: [
                .init(title: "The Birth and Early History of the NBA", description: "From the BAA to the NBA..."),
                .init(title: "Legendary Players & Defining Dynasties", description: "Covering icons like Bill Russell..."),
                .init(title: "The Rules of the Game & Basic Strategy", description: "An essential primer...")
            ],
            topic: "The History of the NBA",
            difficulty: .beginner,
            pace: .balanced,
            onCancel: {},
            onGenerate: {}
        )
        .environmentObject(CourseGenerationManager())
        .environmentObject(LearningStatsManager())
        .environmentObject(NotificationsManager())
    }
} 