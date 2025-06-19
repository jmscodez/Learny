import SwiftUI

struct CourseDetailSheetView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

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
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "book.closed.fill")
                            .font(.title)
                            .foregroundColor(.cyan)
                        Text("Overview")
                            .font(.title2).bold()
                    }
                    Text(course.overview)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.cyan.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan, lineWidth: 1)
                )

                // What You'll Learn Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.title)
                            .foregroundColor(.purple)
                        Text("What You'll Learn")
                            .font(.title2).bold()
                    }

                    // This would ideally come from the Course model
                    InfoRow(icon: "timer", title: "Key Figures & Events", description: "Explore the pivotal moments and influential figures that shaped the course topic.")
                    InfoRow(icon: "chart.line.uptrend.xyaxis", title: "Future Focus", description: "Discover exciting trends and developments related to the subject.")

                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 1)
                )
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

// Helper view for the "What You'll Learn" section
private struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// Add a placeholder 'overview' to the Course model for preview
extension Course {
    var overview: String {
        "Get ready to discover the topic of \(title) like never before! This course takes you on a journey through the fascinating history, vibrant culture, and promising future of this subject. Whether you're a history buff, a curious traveler, or a local looking to deepen your connection with the city, this course is for you."
    }
}

struct CourseDetailSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCourse = Course(
            id: UUID(),
            title: "The Great War",
            topic: "World War I",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: [],
            createdAt: Date()
        )

        CourseDetailSheetView(course: sampleCourse)
    }
} 