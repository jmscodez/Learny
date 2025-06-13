import SwiftUI

struct CourseOverviewView: View {
    let course: Course
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image (Optional)
                    // Image("course_header_image")
                    //     .resizable()
                    //     .aspectRatio(contentMode: .fit)

                    Text("Overview")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    Text("This course covers the essentials of \(course.topic).")
                        .padding(.horizontal)

                    Text("What You'll Learn")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // This is a placeholder. In a real app, you might have a dedicated
                    // property on the Course model for learning objectives.
                    ForEach(course.lessons.prefix(5), id: \.id) { lesson in
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                            Text(lesson.title)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle(course.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea())
    }
}

struct CourseOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLessons = [
            Lesson(id: UUID(), title: "The Basics of Melody", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: false),
            Lesson(id: UUID(), title: "Understanding Rhythm", contentBlocks: [], quiz: [], isUnlocked: false, isComplete: false),
            Lesson(id: UUID(), title: "Chord Progressions", contentBlocks: [], quiz: [], isUnlocked: false, isComplete: false)
        ]
        let sampleCourse = Course(
            id: UUID(),
            title: "Music Theory",
            topic: "Music Theory",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: sampleLessons,
            createdAt: Date()
        )
        
        CourseOverviewView(course: sampleCourse)
    }
} 