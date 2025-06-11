import Foundation

/// A single line of dialogue in a lesson.
struct DialogueLine: Identifiable, Codable, Hashable {
    let id = UUID()
    let speaker: String
    let text: String
}

/// A matching‐pairs mini‐game model.
struct MatchingPair: Identifiable, Codable, Hashable {
    let id = UUID()
    let term: String
    let definition: String
}

struct MatchingGame: Codable, Hashable {
    let pairs: [MatchingPair]
}

/// All possible content blocks in a lesson.
enum ContentBlock: Codable, Hashable {
    case text(String)
    case dialogue([DialogueLine])
    case matching(MatchingGame)

    private enum CodingKeys: CodingKey { case type, value }
    private enum BlockType: String, Codable { case text, dialogue, matching }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let str):
            try container.encode(BlockType.text, forKey: .type)
            try container.encode(str, forKey: .value)
        case .dialogue(let lines):
            try container.encode(BlockType.dialogue, forKey: .type)
            try container.encode(lines, forKey: .value)
        case .matching(let game):
            try container.encode(BlockType.matching, forKey: .type)
            try container.encode(game, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BlockType.self, forKey: .type)
        switch type {
        case .text:
            let str = try container.decode(String.self, forKey: .value)
            self = .text(str)
        case .dialogue:
            let lines = try container.decode([DialogueLine].self, forKey: .value)
            self = .dialogue(lines)
        case .matching:
            let game = try container.decode(MatchingGame.self, forKey: .value)
            self = .matching(game)
        }
    }
}
