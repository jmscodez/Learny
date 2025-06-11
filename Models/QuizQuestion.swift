import Foundation

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    var prompt: String
    var options: [String]
    var correctIndex: Int
}
