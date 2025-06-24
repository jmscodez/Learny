import Foundation

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    var prompt: String
    var options: [String]
    var correctIndex: Int

    enum CodingKeys: String, CodingKey {
        case prompt, options, correctIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prompt = try container.decode(String.self, forKey: .prompt)
        self.options = try container.decode([String].self, forKey: .options)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
        self.id = UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(options, forKey: .options)
        try container.encode(correctIndex, forKey: .correctIndex)
    }

    init(id: UUID = UUID(), prompt: String, options: [String], correctIndex: Int) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.correctIndex = correctIndex
    }
}
