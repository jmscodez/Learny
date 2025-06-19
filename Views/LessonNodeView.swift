import SwiftUI

struct LessonNodeView: View {
    let lesson: Lesson
    let alignment: HorizontalAlignment
    @State private var isPulsing = false
    
    private var iconName: String {
        if lesson.isComplete {
            return "checkmark"
        } else if lesson.isUnlocked {
            return "play.fill"
        } else {
            return "lock.fill"
        }
    }
    
    private var iconColor: Color {
        if lesson.isComplete {
            return .white
        } else if lesson.isUnlocked {
            return .white
        } else {
            return .gray.opacity(0.7)
        }
    }
    
    private var nodeGradient: LinearGradient {
        if lesson.isComplete {
            return LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        } else if lesson.isUnlocked {
            return LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [Color(white: 0.3), Color(white: 0.2)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            ZStack {
                // Base of the 3D effect
                Circle()
                    .fill(nodeGradient)
                    .frame(width: lesson.isUnlocked && !lesson.isComplete ? 80 : 70, height: lesson.isUnlocked && !lesson.isComplete ? 80 : 70)
                    .shadow(color: .black.opacity(0.4), radius: 5, y: 5)
                
                // Pulsing glow for the current lesson
                if lesson.isUnlocked && !lesson.isComplete {
                    Circle()
                        .stroke(Color.blue.opacity(0.7), lineWidth: 2)
                        .frame(width: isPulsing ? 90 : 80, height: isPulsing ? 90 : 80)
                        .opacity(isPulsing ? 0 : 1)
                }
                
                // Top "button" part
                Circle()
                    .fill(nodeGradient.opacity(0.8))
                    .frame(width: lesson.isUnlocked && !lesson.isComplete ? 70 : 60, height: lesson.isUnlocked && !lesson.isComplete ? 70 : 60)
                    .shadow(color: .white.opacity(0.3), radius: 2, y: -2) // Inner highlight
                
                Image(systemName: iconName)
                    .font(lesson.isUnlocked && !lesson.isComplete ? .largeTitle : .title)
                    .foregroundColor(iconColor)
            }
            
            Text(lesson.title)
                .font(.caption.bold())
                .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                .foregroundColor(.white)
                .frame(width: 120, alignment: alignment == .leading ? .leading : .trailing)
        }
        .opacity(lesson.isUnlocked ? 1.0 : 0.7)
        .onAppear {
            if lesson.isUnlocked && !lesson.isComplete {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

struct LessonNodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonNodeView(lesson: Lesson(id: UUID(), title: "First Lesson", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: false), alignment: .leading)
            LessonNodeView(lesson: Lesson(id: UUID(), title: "Completed", contentBlocks: [], quiz: [], isUnlocked: true, isComplete: true), alignment: .trailing)
            LessonNodeView(lesson: Lesson(id: UUID(), title: "Locked Lesson with a very long title that wraps around", contentBlocks: [], quiz: [], isUnlocked: false, isComplete: false), alignment: .leading)
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
} 
