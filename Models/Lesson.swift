import Foundation

enum LessonType: String, Codable {
    case lesson
    case checkpointQuiz
}

struct Lesson: Identifiable, Codable, Hashable {
    var id = UUID()
    let title: String
    var lessonNumber: Int
    var screens: [LessonScreen] = []
    var isCompleted: Bool = false
    var isCurrent: Bool = false
    
    init(id: UUID = UUID(), title: String, lessonNumber: Int, screens: [LessonScreen] = [], isCompleted: Bool = false, isCurrent: Bool = false) {
        self.id = id
        self.title = title
        self.lessonNumber = lessonNumber
        self.screens = screens
        self.isCompleted = isCompleted
        self.isCurrent = isCurrent
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        lhs.id == rhs.id
    }
}
