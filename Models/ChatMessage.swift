import Foundation

struct LessonSuggestion: Identifiable, Equatable, Decodable {
    let id = UUID()
    var title: String
    var description: String
    var isSelected: Bool = false
    
    // Custom coding keys to handle the JSON from the AI, which won't include our local-only properties.
    enum CodingKeys: String, CodingKey {
        case title
        case description
    }
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
        case lessonCountOptions
        case thinkingIndicator
        case descriptiveLoading(String)
        case lessonSuggestions
        case inlineLessonSuggestions([UUID])
        case clarificationOptions(originalQuery: String, options: [String])
        case infoText(String)
        case finalPrompt
        case generateMoreIdeasButton
        // Future cases will go here, e.g., for selectable lesson lists.
    }
}

extension ChatMessage.ContentType {
    // ... existing code ...
} 