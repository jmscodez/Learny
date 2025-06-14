import SwiftUI

struct FinalizeCourseView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stats: LearningStatsManager
    
    @State var lessons: [LessonSuggestion]
    let topic: String
    let onComplete: (Course) -> Void
    
    // Supports swipe-to-delete
    private func deleteLesson(at offsets: IndexSet) {
        lessons.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    List {
                        ForEach(lessons) { lesson in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(lesson.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(lesson.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color(white: 0.1))
                        }
                        .onMove(perform: moveLesson)
                        .onDelete(perform: deleteLesson)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.black)

                    VStack(spacing: 12) {
                        // Generate Course button
                        Button(action: saveCourse) {
                            Text("Generate Course")
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
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Finalize Your Course")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: EditButton().foregroundColor(.white)
            )
        }
    }
    
    private func moveLesson(from source: IndexSet, to destination: Int) {
        lessons.move(fromOffsets: source, toOffset: destination)
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