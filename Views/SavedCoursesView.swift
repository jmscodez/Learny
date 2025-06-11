import SwiftUI

struct SavedCoursesView: View {
    @EnvironmentObject private var stats: LearningStatsManager
    @State private var editMode: EditMode = .inactive

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Courses")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Spacer()
                    EditButton()
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)

                if stats.courses.isEmpty {
                    Spacer()
                    Text("You have no courses yet.\nGenerate one on the Learn tab!")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(stats.courses) { course in
                            NavigationLink(destination: LessonMapView(course: course)) {
                                CourseCard(course: course)
                            }
                        }
                        .onDelete { indexSet in
                            stats.deleteCourses(at: indexSet)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .environment(\.editMode, $editMode)
    }
}

private struct CourseCard: View {
    let course: Course

    private var progress: Double {
        guard course.lessons.count > 0 else { return 0 }
        return Double(course.lessons.filter(\.isComplete).count) / Double(course.lessons.count)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(course.title.capitalized)
                    .font(.headline)
                    .foregroundColor(.white)

                SwiftUI.ProgressView(value: progress)
                    .accentColor(.cyan)

                Text("\(Int(progress * 100))% • \(course.lessons.filter(\.isComplete).count)/\(course.lessons.count) lessons")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack {
                Text("0 XP")
                    .font(.caption2)
                    .padding(6)
                    .background(Color.purple)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(16)
    }
}

struct SavedCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedCoursesView()
            .environmentObject(LearningStatsManager())
            .preferredColorScheme(.dark)
    }
}
