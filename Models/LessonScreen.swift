import Foundation

// A screen represents a single, interactive step in a lesson.
enum LessonScreen: Codable, Identifiable, Hashable {
    case title(TitleScreen)
    case info(InfoScreen)
    case tapToReveal(TapToRevealScreen)
    case fillInTheBlank(FillInTheBlankScreen)
    case dialogue(DialogueScreen)
    case matching(MatchingGame) // Reuse existing model
    case quiz(QuizScreen)

    var id: UUID {
        switch self {
        case .title(let screen): return screen.id
        case .info(let screen): return screen.id
        case .tapToReveal(let screen): return screen.id
        case .fillInTheBlank(let screen): return screen.id
        case .dialogue(let screen): return screen.id
        case .matching(let game): return game.id
        case .quiz(let screen): return screen.id
        }
    }
    
    // Custom Codable implementation to handle the enum with associated values
    
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    enum ScreenType: String, Codable {
        case title, info, tapToReveal, fillInTheBlank, dialogue, matching, quiz
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ScreenType.self, forKey: .type)
        
        switch type {
        case .title:
            let payload = try container.decode(TitleScreen.self, forKey: .payload)
            self = .title(payload)
        case .info:
            let payload = try container.decode(InfoScreen.self, forKey: .payload)
            self = .info(payload)
        case .tapToReveal:
            let payload = try container.decode(TapToRevealScreen.self, forKey: .payload)
            self = .tapToReveal(payload)
        case .fillInTheBlank:
            let payload = try container.decode(FillInTheBlankScreen.self, forKey: .payload)
            self = .fillInTheBlank(payload)
        case .dialogue:
            let payload = try container.decode(DialogueScreen.self, forKey: .payload)
            self = .dialogue(payload)
        case .matching:
            let payload = try container.decode(MatchingGame.self, forKey: .payload)
            self = .matching(payload)
        case .quiz:
            let payload = try container.decode(QuizScreen.self, forKey: .payload)
            self = .quiz(payload)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .title(let payload):
            try container.encode(ScreenType.title, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .info(let payload):
            try container.encode(ScreenType.info, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .tapToReveal(let payload):
            try container.encode(ScreenType.tapToReveal, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .fillInTheBlank(let payload):
            try container.encode(ScreenType.fillInTheBlank, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .dialogue(let payload):
            try container.encode(ScreenType.dialogue, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .matching(let payload):
            try container.encode(ScreenType.matching, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .quiz(let payload):
            try container.encode(ScreenType.quiz, forKey: .type)
            try container.encode(payload, forKey: .payload)
        }
    }
}

// MARK: - Screen Payload Structs

struct TitleScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let title: String
    let subtitle: String?
    let hook: String

    enum CodingKeys: String, CodingKey {
        case title, subtitle, hook
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.hook = try container.decode(String.self, forKey: .hook)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), title: String, subtitle: String?, hook: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.hook = hook
    }
}

struct InfoScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let text: String

    enum CodingKeys: String, CodingKey {
        case text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.id = UUID()
    }

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

struct TapToRevealScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let question: String
    let answer: String

    enum CodingKeys: String, CodingKey {
        case question, answer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decode(String.self, forKey: .question)
        self.answer = try container.decode(String.self, forKey: .answer)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}

struct FillInTheBlankScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let promptStart: String
    let promptEnd: String
    let correctAnswer: String
    
    enum CodingKeys: String, CodingKey {
        case promptStart, promptEnd, correctAnswer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.promptStart = try container.decode(String.self, forKey: .promptStart)
        self.promptEnd = try container.decode(String.self, forKey: .promptEnd)
        self.correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
        self.id = UUID()
    }

    init(id: UUID = UUID(), promptStart: String, promptEnd: String, correctAnswer: String) {
        self.id = id
        self.promptStart = promptStart
        self.promptEnd = promptEnd
        self.correctAnswer = correctAnswer
    }
}

// Wrapper to make dialogue identifiable at the screen level
struct DialogueScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let lines: [DialogueLine]

    enum CodingKeys: String, CodingKey {
        case lines
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lines = try container.decode([DialogueLine].self, forKey: .lines)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), lines: [DialogueLine]) {
        self.id = id
        self.lines = lines
    }
}

// Wrapper for the quiz to exist as a screen
struct QuizScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let questions: [QuizQuestion]

    enum CodingKeys: String, CodingKey {
        case questions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.questions = try container.decode([QuizQuestion].self, forKey: .questions)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), questions: [QuizQuestion]) {
        self.id = id
        self.questions = questions
    }
} 