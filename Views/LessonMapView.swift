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
    @EnvironmentObject var streaks: StreakManager
    @StateObject private var viewModel: LessonMapViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCourseDetails = false
    @State private var showXpAnimation = false
    @State private var xpGained = 0
    
    // Define a more reasonable spacing for each node
    private let nodeVerticalSpacing: CGFloat = 180.0
    private let pathWidth: CGFloat = 300

    // Calculate total height based on lesson count
    private var totalPathHeight: CGFloat {
        // Add extra padding at the top and bottom
        return CGFloat(viewModel.lessons.count) * nodeVerticalSpacing + 100
    }

    init(course: Course) {
        _viewModel = StateObject(wrappedValue: LessonMapViewModel(course: course))
    }

    var body: some View {
        ZStack {
            // Placeholder for a dynamic, themed background
            LinearGradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.1), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // New, cleaner header
                NewHeaderView(
                    title: viewModel.course.title,
                    lessons: viewModel.lessons,
                    onBackTapped: { dismiss() },
                    onInfoTapped: { showCourseDetails = true }
                )
                
                ScrollView {
                    ZStack {
                        CoursePathView(
                            pathHeight: totalPathHeight,
                            pathWidth: pathWidth
                        )
                        .frame(height: totalPathHeight)
                        
                        NodesView(
                            lessons: viewModel.lessons,
                            pathWidth: pathWidth,
                            viewModel: viewModel,
                            nodeVerticalSpacing: nodeVerticalSpacing
                        )
                        .frame(height: totalPathHeight)
                    }
                }
            }
            
            if showXpAnimation {
                XPAnimationView(amount: xpGained)
                    .onAppear {
                        // The animation will last 2 seconds, then disappear
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showXpAnimation = false
                        }
                    }
            }
        }
        .navigationBarHidden(true) // Hiding the default nav bar
        .sheet(isPresented: $showCourseDetails) {
            CourseDetailSheetView(course: viewModel.course)
        }
        .onReceive(viewModel.xpGainedPublisher) { xp in
            xpGained = xp
            showXpAnimation = true
        }
    }
}

// MARK: - XP Animation
struct XPAnimationView: View {
    let amount: Int
    @State private var isAnimating = false
    
    var body: some View {
        Text("+ \(amount) XP")
            .font(.largeTitle).bold()
            .foregroundColor(.yellow)
            .shadow(color: .black, radius: 2)
            .scaleEffect(isAnimating ? 1.5 : 1.0)
            .offset(y: isAnimating ? -100 : 0)
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Subviews
private struct NewHeaderView: View {
    let title: String
    let lessons: [Lesson]
    let onBackTapped: () -> Void
    let onInfoTapped: () -> Void
    
    private var progress: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(lessons.filter { $0.isCompleted }.count) / Double(lessons.count)
    }
    
    private var xp: Int {
        lessons.filter { $0.isCompleted }.count * 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top navigation
            HStack {
                Button(action: onBackTapped) {
                    Label("Back", systemImage: "chevron.left")
                }
                .foregroundColor(.white)
                Spacer()
            }
            
            // Title and progress
            Text(title)
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            HStack {
                Text("\(Int(progress * 100))% Complete")
                Spacer()
                Text("\(xp) XP Earned")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            // Details Button
            Button(action: onInfoTapped) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("View Course Details")
                }
                .font(.headline)
                .foregroundColor(.cyan)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }
}

private struct CoursePathView: View {
    let pathHeight: CGFloat
    let pathWidth: CGFloat

    var body: some View {
        WindingPath()
            .stroke(
                LinearGradient(
                    colors: [.cyan.opacity(0.8), .purple.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [20, 15])
            )
    }
}

private struct NodesView: View {
    let lessons: [Lesson]
    let pathWidth: CGFloat
    @ObservedObject var viewModel: LessonMapViewModel
    let nodeVerticalSpacing: CGFloat
    
    var body: some View {
        let totalNodes = lessons.count
        
        ForEach(lessons.indices, id: \.self) { index in
            let lesson = lessons[index]
            // Calculate y position based on index and spacing
            let yPos = (CGFloat(index) * nodeVerticalSpacing) + (nodeVerticalSpacing / 2)
            // Use a normalized value (0 to 1) for the sine wave calculation
            let normalizedY = CGFloat(index) / CGFloat(max(1, totalNodes - 1))
            let xOffset = WindingPath.xOffset(for: normalizedY, pathWidth: pathWidth)

            // Determine the alignment based on the curve's position
            let alignment: HorizontalAlignment = (xOffset < 0) ? .leading : .trailing

            NavigationLink(destination: destinationView(for: lesson)) {
                LessonNodeView(lesson: lesson, alignment: alignment)
            }
            .disabled(!lesson.isCurrent && !lesson.isCompleted)
            .position(
                x: (UIScreen.main.bounds.width / 2) + xOffset,
                y: yPos
            )
        }
    }
    
    @ViewBuilder
    private func destinationView(for lesson: Lesson) -> some View {
        LessonPlayerView(lesson: lesson).environmentObject(viewModel)
    }
}


// MARK: - Custom Path Shape
private struct WindingPath: Shape {
    static func xOffset(for y: CGFloat, pathWidth: CGFloat) -> CGFloat {
        let frequency: CGFloat = 4.0
        let amplitude = pathWidth / 2
        return sin(y * .pi * frequency) * amplitude
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = 100
        
        for i in 0...steps {
            let y = CGFloat(i) / CGFloat(steps) * rect.height
            let x = rect.midX + Self.xOffset(for: CGFloat(i) / CGFloat(steps), pathWidth: rect.width)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// MARK: - Previews
struct LessonMapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLessons = [
            Lesson(title: "The Spark: Assassination and Alliances", lessonNumber: 1, isCompleted: true),
            Lesson(title: "Life in the Trenches: A New Kind of War", lessonNumber: 2, isCurrent: true),
            Lesson(title: "The War's Global Reach", lessonNumber: 3),
            Lesson(title: "America Enters the Fray", lessonNumber: 4),
            Lesson(title: "The Treaty of Versailles and Its Legacy", lessonNumber: 5)
        ]
        let sampleCourse = Course(
            id: UUID(),
            title: "The Great War: A Deep Dive into WWI",
            topic: "World War I",
            difficulty: .beginner,
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: sampleLessons,
            createdAt: Date()
        )
        
        return NavigationView {
            LessonMapView(course: sampleCourse)
                .environmentObject(StreakManager())
                .preferredColorScheme(.dark)
        }
    }
}
