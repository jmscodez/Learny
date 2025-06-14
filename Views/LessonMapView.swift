import SwiftUI

// A simple linear progress bar to replace ProgressView determinate style
struct CustomProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(.gray.opacity(0.3))
                Capsule()
                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                    .foregroundColor(.cyan)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct LessonMapView: View {
    @StateObject private var viewModel: LessonMapViewModel
    @State private var showCourseOverview = false

    init(course: Course) {
        _viewModel = StateObject(wrappedValue: LessonMapViewModel(course: course))
    }

    var body: some View {
        let completedCount = viewModel.lessons.filter { $0.isComplete }.count
        let totalCount = viewModel.lessons.count
        let percent = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
        let xp = completedCount * 10
        let timeline = Array(zip(viewModel.lessons.indices, viewModel.lessons))

        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                // Loading overlay
                if viewModel.isGeneratingContent {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Generating course content...")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                ScrollView {
                    VStack(spacing: 24) {
                        // Progress Header
                        VStack(spacing: 12) {
                            // Custom linear progress bar
                            CustomProgressBar(progress: percent)

                            HStack {
                                Text("\(Int(percent * 100))% Complete")
                                Spacer()
                                Text("\(xp) XP Earned")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)

                            Button(action: { showCourseOverview = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "info.circle")
                                    Text("View Course Details")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.cyan)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Timeline
                        VStack(spacing: 40) {
                            ForEach(timeline, id: \.0) { idx, _ in
                                let lesson = viewModel.lessons[idx]
                                VStack(spacing: 0) {
                                    // Node
                                    NavigationLink(destination: LessonDetailView(lesson: lesson)
                                        .environmentObject(viewModel)) {
                                        LessonNodeView(lesson: lesson)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .disabled(!lesson.isUnlocked)

                                    // Connector
                                    if idx < totalCount - 1 {
                                        // Dashed line
                                        Rectangle()
                                            .frame(width: 2, height: 40)
                                            .foregroundColor(.clear)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                                    .foregroundColor(.cyan)
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 30)
                    }
                }
                .background(Color.black)
            }
            .navigationTitle(viewModel.course.title)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCourseOverview) {
                CourseOverviewView(course: viewModel.course)
            }
            .onAppear {
                viewModel.generateLessonContent()
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
