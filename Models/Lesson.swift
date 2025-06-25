import Foundation

enum LessonType: String, Codable, CaseIterable {
    case lesson, checkpointQuiz, interactiveDemo, practiceExercise, videoLesson, readingMaterial
    
    var displayName: String {
        switch self {
        case .lesson: return "Lesson"
        case .checkpointQuiz: return "Quiz"
        case .interactiveDemo: return "Interactive"
        case .practiceExercise: return "Practice"
        case .videoLesson: return "Video"
        case .readingMaterial: return "Reading"
        }
    }
    
    var icon: String {
        switch self {
        case .lesson: return "book.fill"
        case .checkpointQuiz: return "questionmark.circle.fill"
        case .interactiveDemo: return "gamecontroller.fill"
        case .practiceExercise: return "pencil.circle.fill"
        case .videoLesson: return "play.circle.fill"
        case .readingMaterial: return "doc.text.fill"
        }
    }
    
    var color: String {
        switch self {
        case .lesson: return "blue"
        case .checkpointQuiz: return "orange"
        case .interactiveDemo: return "green"
        case .practiceExercise: return "purple"
        case .videoLesson: return "red"
        case .readingMaterial: return "brown"
        }
    }
}

enum LessonDifficulty: String, Codable, CaseIterable {
    case easy, medium, hard
    
    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}

struct LessonAnalytics: Codable {
    var timeSpent: TimeInterval = 0
    var attempts: Int = 0
    var correctAnswers: Int = 0
    var totalQuestions: Int = 0
    var lastAttemptDate: Date?
    var completionDate: Date?
    var hintsUsed: Int = 0
    var mistakesMade: [String] = []
}

struct Lesson: Identifiable, Codable, Hashable {
    var id = UUID()
    let title: String
    var lessonNumber: Int
    var screens: [LessonScreen] = []
    var isCompleted: Bool = false
    var isCurrent: Bool = false
    
    // Enhanced properties
    var type: LessonType = .lesson
    var difficulty: LessonDifficulty = .medium
    var estimatedDuration: Int = 15 // minutes
    var shortDescription: String = ""
    var learningObjectives: [String] = []
    var tags: [String] = []
    var analytics: LessonAnalytics = LessonAnalytics()
    
    // Interactive elements
    var hasQuiz: Bool = false
    var hasPracticeExercise: Bool = false
    var hasInteractiveElements: Bool = false
    var prerequisiteLessons: [UUID] = []
    
    // Progress tracking
    var progressPercentage: Double = 0.0
    var isLocked: Bool = false
    var unlockConditions: [String] = []
    
    init(id: UUID = UUID(), title: String, lessonNumber: Int, screens: [LessonScreen] = [], isCompleted: Bool = false, isCurrent: Bool = false, type: LessonType = .lesson, difficulty: LessonDifficulty = .medium, estimatedDuration: Int = 15, shortDescription: String = "") {
        self.id = id
        self.title = title
        self.lessonNumber = lessonNumber
        self.screens = screens
        self.isCompleted = isCompleted
        self.isCurrent = isCurrent
        self.type = type
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.shortDescription = shortDescription
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed properties
    var formattedDuration: String {
        if estimatedDuration < 60 {
            return "\(estimatedDuration) min"
        } else {
            let hours = estimatedDuration / 60
            let minutes = estimatedDuration % 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
    
    var progressRing: Double {
        if isCompleted { return 1.0 }
        if isCurrent { return progressPercentage }
        return 0.0
    }
    
    var statusIcon: String {
        if isCompleted { return "checkmark.circle.fill" }
        if isCurrent { return "play.circle.fill" }
        if isLocked { return "lock.circle.fill" }
        return "circle"
    }
    
    var statusColor: String {
        if isCompleted { return "green" }
        if isCurrent { return "blue" }
        if isLocked { return "gray" }
        return "gray"
    }
}
