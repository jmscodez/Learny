import Foundation

struct Lesson: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var contentBlocks: [ContentBlock]
    var quiz: [QuizQuestion]
    var isUnlocked: Bool
    var isComplete: Bool
}
