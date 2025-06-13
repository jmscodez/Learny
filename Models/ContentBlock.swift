import Foundation

/// Represents the different types of content that can be in a lesson.
/// Using an enum with associated values is a powerful way to handle this.
enum ContentBlock: Identifiable, Codable, Hashable {
    case text(String)
    case dialogue([DialogueLine])
    case matching(MatchingGame)

    // The 'id' is needed for ForEach loops in SwiftUI.
    var id: UUID {
        // We can generate a stable ID based on the content.
        switch self {
        case .text(let text):
            return "text-\(text)".toUUID()
        case .dialogue(let lines):
            // Use the ID of the first line for stability
            return lines.first?.id ?? UUID()
        case .matching(let game):
            return game.id
        }
    }
}

// Helper extension to create a UUID from a string for stable IDs.
fileprivate extension String {
    func toUUID() -> UUID {
        return UUID(uuidString: self) ?? UUID()
    }
}

enum BlockType: String, Codable, CaseIterable {
    case text
    case image
    // Future types like 'video', 'code' could be added here.
} 