import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
}

enum Pace: String, Codable, CaseIterable {
    case quickReview = "quick_review", balanced, deepDive = "deep_dive"
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
}
