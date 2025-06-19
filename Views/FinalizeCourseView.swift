import SwiftUI

private struct GlowingButton: View {
    let text: String
    let action: () -> Void

    @State private var isGlowing = false

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline).bold()
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .purple.opacity(isGlowing ? 0.8 : 0.2), radius: 10, y: 5)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
        }
        .onAppear {
            self.isGlowing = true
        }
    }
}

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
    
    init(lessons: [LessonSuggestion], topic: String, difficulty: Difficulty, pace: Pace, onCancel: @escaping () -> Void, onGenerate: @escaping () -> Void) {
        self._lessons = State(initialValue: lessons)
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
        self.onCancel = onCancel
        self.onGenerate = onGenerate

        // Customize Navigation Bar Appearance to be consistently black with a cyan title
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.cyan]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.cyan]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    // Supports swipe-to-delete
    private func deleteLesson(at offsets: IndexSet) {
        lessons.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                                LessonRow(index: index + 1, lesson: lesson)
                            }
                        }
                        .padding()
                    }

                    VStack(spacing: 12) {
                        GlowingButton(text: "Generate Course", action: startGeneration)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Finalize Your Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
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

private struct LessonRow: View {
    let index: Int
    let lesson: LessonSuggestion
    
    // Generate a consistent color from the lesson's ID
    private var color: Color {
        let hash = lesson.id.hashValue
        let hue = Double((hash & 0xFF0000) >> 16) / 255.0
        let saturation = Double((hash & 0x00FF00) >> 8) / 255.0
        return Color(hue: hue, saturation: saturation * 0.5 + 0.5, brightness: 0.8)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(color)
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Lesson \(index): \(lesson.title)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
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