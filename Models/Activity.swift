import Foundation

/// A line of dialogue in a lesson activity.
struct DialogueLine: Identifiable, Codable, Hashable {
    let id: UUID
    let speaker: String
    let text: String
}

/// A matching game activity in a lesson.
struct MatchingGame: Identifiable, Codable, Hashable {
    let id: UUID
    let pairs: [MatchingPair]
}

/// A single pair in a matching game.
struct MatchingPair: Identifiable, Codable, Hashable {
    let id: UUID
    let term: String
    let definition: String
} 