import Foundation

// A screen represents a single, interactive step in a lesson.
enum LessonScreen: Codable, Identifiable, Hashable {
    case title(TitleScreen)
    case info(InfoScreen)
    case tapToReveal(TapToRevealScreen)
    case multipleChoice(MultipleChoiceScreen)
    case trueFalse(TrueFalseScreen)
    case dragToOrder(DragToOrderScreen)
    case cardSort(CardSortScreen)
    case dialogue(DialogueScreen)
    case matching(MatchingGame) // Reuse existing model
    case quiz(QuizScreen)

    var id: UUID {
        switch self {
        case .title(let screen): return screen.id
        case .info(let screen): return screen.id
        case .tapToReveal(let screen): return screen.id
        case .multipleChoice(let screen): return screen.id
        case .trueFalse(let screen): return screen.id
        case .dragToOrder(let screen): return screen.id
        case .cardSort(let screen): return screen.id
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
        case title, info, tapToReveal, multipleChoice, trueFalse, dragToOrder, cardSort, dialogue, matching, quiz
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
        case .multipleChoice:
            let payload = try container.decode(MultipleChoiceScreen.self, forKey: .payload)
            self = .multipleChoice(payload)
        case .trueFalse:
            let payload = try container.decode(TrueFalseScreen.self, forKey: .payload)
            self = .trueFalse(payload)
        case .dragToOrder:
            let payload = try container.decode(DragToOrderScreen.self, forKey: .payload)
            self = .dragToOrder(payload)
        case .cardSort:
            let payload = try container.decode(CardSortScreen.self, forKey: .payload)
            self = .cardSort(payload)
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
        case .multipleChoice(let payload):
            try container.encode(ScreenType.multipleChoice, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .trueFalse(let payload):
            try container.encode(ScreenType.trueFalse, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .dragToOrder(let payload):
            try container.encode(ScreenType.dragToOrder, forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .cardSort(let payload):
            try container.encode(ScreenType.cardSort, forKey: .type)
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

struct MultipleChoiceScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case question, options, correctIndex, explanation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decode(String.self, forKey: .question)
        self.options = try container.decode([String].self, forKey: .options)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.id = UUID()
    }

    init(id: UUID = UUID(), question: String, options: [String], correctIndex: Int, explanation: String) {
        self.id = id
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
    }
}

struct TrueFalseScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let statement: String
    let isTrue: Bool
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case statement, isTrue, explanation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statement = try container.decode(String.self, forKey: .statement)
        self.isTrue = try container.decode(Bool.self, forKey: .isTrue)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), statement: String, isTrue: Bool, explanation: String) {
        self.id = id
        self.statement = statement
        self.isTrue = isTrue
        self.explanation = explanation
    }
}

struct DragToOrderScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let instruction: String
    let items: [String]
    let correctOrder: [Int] // Indices representing correct order
    
    enum CodingKeys: String, CodingKey {
        case instruction, items, correctOrder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.instruction = try container.decode(String.self, forKey: .instruction)
        self.items = try container.decode([String].self, forKey: .items)
        self.correctOrder = try container.decode([Int].self, forKey: .correctOrder)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), instruction: String, items: [String], correctOrder: [Int]) {
        self.id = id
        self.instruction = instruction
        self.items = items
        self.correctOrder = correctOrder
    }
}

struct CardSortScreen: Codable, Identifiable, Hashable {
    var id = UUID()
    let instruction: String
    let categories: [String]
    let cards: [SortCard]
    
    enum CodingKeys: String, CodingKey {
        case instruction, categories, cards
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.instruction = try container.decode(String.self, forKey: .instruction)
        self.categories = try container.decode([String].self, forKey: .categories)
        self.cards = try container.decode([SortCard].self, forKey: .cards)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), instruction: String, categories: [String], cards: [SortCard]) {
        self.id = id
        self.instruction = instruction
        self.categories = categories
        self.cards = cards
    }
}

struct SortCard: Codable, Identifiable, Hashable {
    var id = UUID()
    let text: String
    let correctCategoryIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case text, correctCategoryIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.correctCategoryIndex = try container.decode(Int.self, forKey: .correctCategoryIndex)
        self.id = UUID()
    }
    
    init(id: UUID = UUID(), text: String, correctCategoryIndex: Int) {
        self.id = id
        self.text = text
        self.correctCategoryIndex = correctCategoryIndex
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