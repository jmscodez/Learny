import Foundation

struct LessonSuggestion: Identifiable, Equatable, Decodable {
    let id = UUID()
    var title: String
    var description: String
    var isSelected: Bool = false
    
    // Additional properties for enhanced UI
    var shortDescription: String { 
        description.count > 100 ? String(description.prefix(100)) + "..." : description 
    }
    var estimatedMinutes: String = "15-20 min"
    var hasPractice: Bool = true
    
    // Custom coding keys to handle the JSON from the AI, which won't include our local-only properties.
    enum CodingKeys: String, CodingKey {
        case title
        case description
    }
}

// Helper struct to make clarification options equatable
struct ClarificationOption: Equatable {
    let key: String
    let value: String
}

// Defines the structure for a single message in the chat history.
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    var content: ContentType

    enum Role {
        case user, assistant
    }
    
    // Defines the different kinds of content a message bubble can display.
    enum ContentType: Equatable {
        case text(String)
        case lessonCountOptions([String])
        case thinkingIndicator
        case descriptiveLoading(String)
        case lessonSuggestions([LessonSuggestion])
        case inlineLessonSuggestions([LessonSuggestion])
        case clarificationOptions([ClarificationOption])
        case infoText(String)
        case finalPrompt(String)
        case generateMoreIdeasButton
        case errorMessage(String) // Updated from aiError for consistency
        // Future cases will go here, e.g., for selectable lesson lists.
    }
}

extension ChatMessage.ContentType {
    var isBubble: Bool {
        switch self {
        case .text, .lessonSuggestions, .infoText, .inlineLessonSuggestions: return true
        default: return false
        }
    }
} 