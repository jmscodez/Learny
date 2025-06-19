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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stats: LearningStatsManager
    
    @State var lessons: [LessonSuggestion]
    let topic: String
    let onComplete: (Course) -> Void
    
    init(lessons: [LessonSuggestion], topic: String, onComplete: @escaping (Course) -> Void) {
        self._lessons = State(initialValue: lessons)
        self.topic = topic
        self.onComplete = onComplete

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
                        GlowingButton(text: "Generate Course", action: saveCourse)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Finalize Your Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
    
    private func saveCourse() {
        let newLessons = lessons.map { suggestion in
            Lesson(
                id: UUID(),
                title: suggestion.title,
                contentBlocks: [.text(suggestion.description)],
                quiz: [],
                isUnlocked: true,
                isComplete: false
            )
        }
        let newCourse = Course(
            id: UUID(),
            title: topic,
            topic: topic,
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: newLessons,
            createdAt: Date()
        )
        stats.addCourse(newCourse)
        onComplete(newCourse)
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
            onComplete: { _ in }
        )
        .environmentObject(LearningStatsManager())
    }
} 