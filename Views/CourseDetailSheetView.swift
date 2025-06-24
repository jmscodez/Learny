import SwiftUI

struct CourseDetailSheetView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Text("Course Details")
                            .font(.largeTitle).bold()
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }

                    // Overview Section
                    InfoCard(
                        title: "Overview",
                        icon: "book.closed.fill",
                        color: .cyan
                    ) {
                        Text(course.overview)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // What You'll Learn Section
                    InfoCard(
                        title: "What You'll Learn",
                        icon: "target",
                        color: .purple
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(course.learningObjectives, id: \.self) { objective in
                                InfoRow(icon: "checkmark.circle", text: objective)
                            }
                        }
                    }
                    
                    // Who It's For Section
                    InfoCard(
                        title: "Who It's For",
                        icon: "person.2.fill",
                        color: .orange
                    ) {
                        Text(course.whoIsThisFor)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .foregroundColor(.white)
                .padding()
            }
        }
    }
}

// MARK: - Reusable Components

private struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(.title2).bold()
            }
            content
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color, lineWidth: 1)
        )
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.purple)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

private struct StatPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(.subheadline.bold())
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.2))
        .cornerRadius(20)
    }
}


// MARK: - Preview

struct CourseDetailSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCourse = Course(
            id: UUID(),
            title: "The Great War",
            topic: "World War I",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: [Lesson(title: "The Spark", lessonNumber: 1)],
            createdAt: Date(),
            overview: "Get ready to discover the topic of WWI like never before! This course takes you on a journey through the fascinating history, vibrant culture, and promising future of this subject.",
            learningObjectives: ["Understand the causes of the war.", "Analyze key battles.", "Explore the treaty's legacy."],
            whoIsThisFor: "Perfect for history buffs, students, or anyone curious about this defining moment.",
            estimatedTime: "Approx. 45-60 minutes"
        )

        CourseDetailSheetView(course: sampleCourse)
    }
} 