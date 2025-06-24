import Foundation

/// A line of dialogue in a lesson activity.
struct DialogueLine: Identifiable, Codable, Hashable {
    let id: UUID
    let speaker: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case speaker, text, message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.speaker = try container.decode(String.self, forKey: .speaker)
        if let txt = try container.decodeIfPresent(String.self, forKey: .text) {
            self.text = txt
        } else {
            self.text = try container.decode(String.self, forKey: .message)
        }
        self.id = UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(speaker, forKey: .speaker)
        try container.encode(text, forKey: .text)
    }

    // Add a memberwise initializer for non-decoding creation
    init(id: UUID = UUID(), speaker: String, text: String) {
        self.id = id
        self.speaker = speaker
        self.text = text
    }
}

/// A matching game activity in a lesson.
struct MatchingGame: Identifiable, Codable, Hashable {
    let id: UUID
    let pairs: [MatchingPair]

    enum CodingKeys: String, CodingKey {
        case pairs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pairs = try container.decode([MatchingPair].self, forKey: .pairs)
        self.id = UUID()
    }

    // Add a memberwise initializer for non-decoding creation
    init(id: UUID = UUID(), pairs: [MatchingPair]) {
        self.id = id
        self.pairs = pairs
    }
}

/// A single pair in a matching game.
struct MatchingPair: Identifiable, Codable, Hashable {
    let id: UUID
    let term: String
    let definition: String

    enum CodingKeys: String, CodingKey {
        case term, definition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.term = try container.decode(String.self, forKey: .term)
        self.definition = try container.decode(String.self, forKey: .definition)
        self.id = UUID()
    }

    // Add a memberwise initializer for non-decoding creation
    init(id: UUID = UUID(), term: String, definition: String) {
        self.id = id
        self.term = term
        self.definition = definition
    }
} 