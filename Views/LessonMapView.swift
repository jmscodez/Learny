import SwiftUI

struct LessonMapView: View {
    let course: Course
    @StateObject private var vm: LessonMapViewModel

    init(course: Course) {
        self.course = course
        _vm = StateObject(
            wrappedValue: LessonMapViewModel(
                course: course,
                stats: LearningStatsManager()
            )
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(vm.lessons) { lesson in
                HStack {
                    Text(lesson.title)
                    Spacer()
                    if lesson.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                    } else if lesson.isUnlocked {
                        NavigationLink("Start", destination: LessonDetailView(lesson: lesson))
                    } else {
                        Image(systemName: "lock.fill")
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(course.title)
    }
}
