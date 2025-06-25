import SwiftUI

@MainActor
final class LessonChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var lessonOverview: LessonOverview?
    @Published var isLoadingDescription: Bool = true
    
    let lesson: LessonSuggestion
    private let aiService = OpenAIService.shared
    
    init(lesson: LessonSuggestion) {
        self.lesson = lesson
        Task {
            await fetchDetailedDescription()
        }
    }
    
    func fetchDetailedDescription() async {
        if let overview = await aiService.generateDetailedLessonOverview(for: lesson) {
            self.lessonOverview = overview
        } else {
            self.lessonOverview = nil
        }
        self.isLoadingDescription = false
        
        let welcomeMessage = "This overview covers the key topics in the lesson. What are you curious about? Ask a question or tell me what you'd like to explore first!"
        messages.append(ChatMessage(role: .assistant, content: .infoText(welcomeMessage)))
    }
    
    func sendMessage(_ text: String) {
        messages.append(ChatMessage(role: .user, content: .text(text)))
        
        Task {
            let thinkingMessage = ChatMessage(role: .assistant, content: .thinkingIndicator)
            messages.append(thinkingMessage)
            
            if let response = await aiService.getLessonTutoringResponse(lesson: lesson, question: text) {
                if let index = messages.firstIndex(where: { $0.id == thinkingMessage.id }) {
                    messages[index] = ChatMessage(role: .assistant, content: .text(response))
                }
            } else {
                if let index = messages.firstIndex(where: { $0.id == thinkingMessage.id }) {
                    let errorMessage = "Sorry, I ran into an issue. Please try asking your question again."
                    messages[index] = ChatMessage(role: .assistant, content: .errorMessage(errorMessage))
                }
            }
        }
    }
} 