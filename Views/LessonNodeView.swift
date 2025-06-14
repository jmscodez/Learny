import SwiftUI

struct LessonNodeView: View {
    let lesson: Lesson
    
    var body: some View {
        VStack {
            Image(systemName: lesson.isComplete ? "checkmark.circle.fill" : (lesson.isUnlocked ? "play.circle.fill" : "lock.fill"))
                .font(.largeTitle)
                .foregroundColor(nodeColor)
                .padding()
                .background(Circle().fill(nodeColor.opacity(0.2)))
            
            Text(lesson.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .opacity(lesson.isUnlocked ? 1.0 : 0.5)
    }
    
    private var nodeColor: Color {
        if lesson.isComplete {
            return .green
        } else if lesson.isUnlocked {
            return .blue
        } else {
            return .gray
        }
    }
}

struct LessonNodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonNodeView(lesson: Lesson(id: UUID(), title: "First Lesson", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: false))
            LessonNodeView(lesson: Lesson(id: UUID(), title: "Completed", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: true))
            LessonNodeView(lesson: Lesson(id: UUID(), title: "Locked Lesson", contentBlocks: [], quiz: [], isUnlocked: false, isComplete: false))
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
} 
