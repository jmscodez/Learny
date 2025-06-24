import SwiftUI

struct LessonNodeView: View {
    let lesson: Lesson
    let alignment: HorizontalAlignment
    @State private var isPulsing = false
    
    private var iconName: String {
        if lesson.isCompleted {
            return "checkmark"
        } else if lesson.isCurrent {
            return "play.fill"
        } else {
            return "lock.fill"
        }
    }
    
    private var iconColor: Color {
        if lesson.isCompleted {
            return .white
        } else if lesson.isCurrent {
            return .white
        } else {
            return .gray.opacity(0.7)
        }
    }
    
    private var nodeGradient: LinearGradient {
        if lesson.isCompleted {
            return LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        } else if lesson.isCurrent {
            return LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [Color(white: 0.3), Color(white: 0.2)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            ZStack {
                // Base of the 3D effect. The current lesson is larger.
                Circle()
                    .fill(nodeGradient)
                    .frame(width: lesson.isCurrent ? 80 : 70, height: lesson.isCurrent ? 80 : 70)
                    .shadow(color: .black.opacity(0.4), radius: 5, y: 5)
                
                // Pulsing glow for the current lesson.
                if lesson.isCurrent {
                    Circle()
                        .stroke(Color.blue.opacity(0.7), lineWidth: 2)
                        .frame(width: isPulsing ? 90 : 80, height: isPulsing ? 90 : 80)
                        .opacity(isPulsing ? 0 : 1)
                }
                
                // Top "button" part.
                Circle()
                    .fill(nodeGradient.opacity(0.8))
                    .frame(width: lesson.isCurrent ? 70 : 60, height: lesson.isCurrent ? 70 : 60)
                    .shadow(color: .white.opacity(0.3), radius: 2, y: -2) // Inner highlight
                
                Image(systemName: iconName)
                    .font(lesson.isCurrent ? .largeTitle : .title)
                    .foregroundColor(iconColor)
            }
            
            Text(lesson.title)
                .font(.caption.bold())
                .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                .foregroundColor(.white)
                .frame(width: 120, alignment: alignment == .leading ? .leading : .trailing)
        }
        // Locked lessons are dimmed.
        .opacity(lesson.isCompleted || lesson.isCurrent ? 1.0 : 0.7)
        .onAppear {
            if lesson.isCurrent {
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
            LessonNodeView(lesson: Lesson(title: "Current Lesson", lessonNumber: 1, isCurrent: true), alignment: .leading)
            LessonNodeView(lesson: Lesson(title: "Completed Lesson", lessonNumber: 2, isCompleted: true), alignment: .trailing)
            LessonNodeView(lesson: Lesson(title: "Locked Lesson", lessonNumber: 3), alignment: .leading)
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
} 
