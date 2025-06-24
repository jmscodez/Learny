import SwiftUI

struct CourseOverviewView: View {
    let course: Course
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Semi-transparent black overlay
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Course Details")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overview Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.cyan)
                                Text("Overview")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Text("This course covers the essentials of \(course.topic).")
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color(white: 0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.cyan, lineWidth: 1)
                        )

                        // What You'll Learn Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "target")
                                    .foregroundColor(.pink)
                                Text("What You'll Learn")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(course.lessons.indices, id: \.self) { idx in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.mint)
                                        Text(course.lessons[idx].title)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [.purple, .pink]),
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ).asColor(), lineWidth: 1)
                        )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Helper to convert Gradient Stroke to Color for overlay
extension LinearGradient {
    func asColor() -> Color {
        // Fallback solid color if needed
        return Color.purple
    }
}

struct CourseOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLessons = [
            Lesson(title: "Lesson 1: Intro", lessonNumber: 1, isCurrent: true),
            Lesson(title: "Lesson 2: Deep Dive", lessonNumber: 2)
        ]
        let sampleCourse = Course(
            id: UUID(),
            title: "Us history",
            topic: "Us history",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: sampleLessons,
            createdAt: Date()
        )
        CourseOverviewView(course: sampleCourse)
    }
} 