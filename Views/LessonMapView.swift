import SwiftUI

struct LessonMapView: View {
    @StateObject private var viewModel: LessonMapViewModel
    @State private var showCourseOverview = false

    init(course: Course) {
        _viewModel = StateObject(wrappedValue: LessonMapViewModel(course: course))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(viewModel.lessons) { lesson in
                            NavigationLink(value: lesson) {
                                LessonNodeView(lesson: lesson)
                            }
                            .disabled(!lesson.isUnlocked)
                        }
                    }
                    .padding(.vertical, 40)
                }
                .navigationTitle(viewModel.course.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCourseOverview = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                    }
                }
                .sheet(isPresented: $showCourseOverview) {
                    CourseOverviewView(course: viewModel.course)
                }
                .navigationDestination(for: Lesson.self) { lesson in
                    LessonDetailView(lesson: lesson)
                        .environmentObject(viewModel)
                }
            }
        }
        .accentColor(.white)
    }
}

struct LessonMapView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating a sample course with a few lessons for the preview
        let sampleLessons = [
            Lesson(id: UUID(), title: "Introduction", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: true),
            Lesson(id: UUID(), title: "Chapter 1", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: false),
            Lesson(id: UUID(), title: "Chapter 2", contentBlocks: [], quiz: [], isUnlocked: false, isComplete: false)
        ]
        let sampleCourse = Course(
            id: UUID(),
            title: "History of Jazz",
            topic: "History of Jazz",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: sampleLessons,
            createdAt: Date()
        )
        
        LessonMapView(course: sampleCourse)
    }
}
