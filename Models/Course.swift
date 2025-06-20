import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
}

enum Pace: String, Codable, CaseIterable {
    case quickReview = "quick_review", balanced, deepDive = "deep_dive"
    
    var displayName: String {
        switch self {
        case .quickReview:
            return "Quick Review"
        case .balanced:
            return "Balanced"
        case .deepDive:
            return "Deep Dive"
        }
    }
}

enum CreationMethod: String, Codable, CaseIterable {
    case guidedSetup, aiAssistant, fromDocument
}

struct Course: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var topic: String
    var difficulty: Difficulty
    var pace: Pace
    var creationMethod: CreationMethod
    var lessons: [Lesson]
    var createdAt: Date
    
    // AI-generated metadata
    var overview: String
    var learningObjectives: [String]
    var whoIsThisFor: String
    var estimatedTime: String
    
    init(id: UUID, title: String, topic: String, difficulty: Difficulty, pace: Pace, creationMethod: CreationMethod, lessons: [Lesson], createdAt: Date, overview: String = "", learningObjectives: [String] = [], whoIsThisFor: String = "", estimatedTime: String = "") {
        self.id = id
        self.title = title
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
        self.creationMethod = creationMethod
        self.lessons = lessons
        self.createdAt = createdAt
        self.overview = overview
        self.learningObjectives = learningObjectives
        self.whoIsThisFor = whoIsThisFor
        self.estimatedTime = estimatedTime
    }
}
