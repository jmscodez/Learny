import SwiftUI

// Manages the state and logic for the AI course creation chat.
@MainActor
final class CourseChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var lessonSuggestions: [LessonSuggestion] = []
    @Published var swappingLessonID: UUID? = nil
    @Published var userInput: String = ""
    
    // Controls the visibility of the interactive elements
    @Published var canShowSuggestions = false
    
    // Course parameters
    let topic: String
    let difficulty: Difficulty
    let pace: Pace
    
    // Computed property to drive the "Current Lessons" dropdown
    var selectedLessons: [LessonSuggestion] {
        lessonSuggestions.filter(\.isSelected)
    }

    // Tracks the user's selection to prevent re-tapping.
    private var didSelectLessonCount = false
    
    private var lessonCountTarget: String = ""
    
    private let aiService = OpenAIService.shared
    
    init(topic: String, difficulty: Difficulty, pace: Pace) {
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
        setupInitialConversation()
    }
    
    private func setupInitialConversation() {
        // The AI's opening messages.
        messages.append(ChatMessage(
            role: .assistant,
            content: .text("Welcome! To start, about how many lessons should we create for your course on \(topic)?")
        ))
        
        messages.append(ChatMessage(
            role: .assistant,
            content: .lessonCountOptions
        ))
    }
    
    /// Handles the user tapping on one of the lesson count options.
    func selectLessonCount(_ option: String) {
        guard !didSelectLessonCount else { return }
        didSelectLessonCount = true
        self.lessonCountTarget = option
        
        // 1. Add the user's choice to the chat.
        messages.append(ChatMessage(role: .user, content: .text(option)))
        
        // 2. Remove the interactive options.
        messages.removeAll { $0.content == .lessonCountOptions }
        
        // 3. Trigger the AI's response asynchronously.
        Task {
            // New: Add a conversational response
            let (min, max) = parseLessonCountRange(from: option) ?? (3, 5)
            let target = (min + max) / 2
            
            let conversationalText = "Great! For a course with \(option), I'll start you off with \(target) ideas. You can customize them from there."
            messages.append(ChatMessage(role: .assistant, content: .text(conversationalText)))
            
            // Give the user a moment to read before showing the loader
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            await generateAndDisplayInitialSuggestions(count: target)
        }
    }
    
    /// A reusable function to generate and display the first batch of suggestions.
    /// Also used by the "Retry" button.
    func generateAndDisplayInitialSuggestions(count: Int = 7) async {
        // Clear any previous error messages
        messages.removeAll { if case .aiError = $0.content { return true }; return false }
        
        let loadingMessage = ChatMessage(role: .assistant, content: .descriptiveLoading("Generating your first \(count) lesson ideas..."))
        messages.append(loadingMessage)
        
        if let initialSuggestions = await aiService.generateInitialLessonIdeas(for: topic, count: count) {
            messages.removeAll { $0.id == loadingMessage.id }
            
            self.lessonSuggestions = initialSuggestions
            messages.append(ChatMessage(role: .assistant, content: .lessonSuggestions))
            canShowSuggestions = true
            
            // Add the final, prominent prompt
            try? await Task.sleep(nanoseconds: 500_000_000)
            messages.append(ChatMessage(role: .assistant, content: .finalPrompt))
            messages.append(ChatMessage(role: .assistant, content: .generateMoreIdeasButton))
        } else {
            // Handle generation failure
            messages.removeAll { $0.id == loadingMessage.id }
            let errorMessage = "Sorry, I couldn't generate lesson ideas for '\(topic)' right now. Please check your connection or try again."
            messages.append(ChatMessage(role: .assistant, content: .aiError(errorMessage)))
        }
    }
    
    /// Toggles the selection state for a given lesson ID.
    func toggleLessonSelection(id: UUID) {
        guard let index = lessonSuggestions.firstIndex(where: { $0.id == id }) else { return }
        lessonSuggestions[index].isSelected.toggle()
    }
    
    /// Handles user text input, adding a new lesson.
    func addUserMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let text = userInput
        userInput = "" // Clear the input field immediately
        
        messages.append(ChatMessage(role: .user, content: .text(text)))

        Task {
            let loadingMessage = ChatMessage(role: .assistant, content: .descriptiveLoading("Thinking of new ideas..."))
            messages.append(loadingMessage)
            
            let clarification = await aiService.generateClarifyingQuestion(for: text, topic: topic)
            messages.removeAll { $0.id == loadingMessage.id }

            messages.append(ChatMessage(role: .assistant, content: .text(clarification.question)))
            messages.append(ChatMessage(role: .assistant, content: .clarificationOptions(originalQuery: text, options: clarification.options)))
        }
    }
    
    func handleClarificationResponse(originalQuery: String, response: String) {
        // Hide the clarification buttons once one is chosen
        messages.removeAll {
            if case .clarificationOptions = $0.content { return true }
            return false
        }
        
        messages.append(ChatMessage(role: .user, content: .text(response)))
        
        Task {
            let loadingMessage = ChatMessage(role: .assistant, content: .descriptiveLoading("Thinking of new ideas..."))
            messages.append(loadingMessage)
            
            let fullQuery = "\(originalQuery) with a focus on \(response)"
            if let followUpSuggestions = await aiService.generateFollowUpLessonIdeas(basedOn: fullQuery, topic: topic, existingLessons: lessonSuggestions) {
                messages.removeAll { $0.id == loadingMessage.id }
                
                // Add new suggestions to the main list
                self.lessonSuggestions.append(contentsOf: followUpSuggestions)
                let suggestionIDs = followUpSuggestions.map { $0.id }
                
                let responseText = "Perfect. Based on your interest in '\(response)', here are a few lesson ideas I've come up with:"
                messages.append(ChatMessage(role: .assistant, content: .text(responseText)))
                
                messages.append(ChatMessage(role: .assistant, content: .inlineLessonSuggestions(suggestionIDs)))
            } else {
                messages.removeAll { $0.id == loadingMessage.id }
                let errorMessage = "Sorry, I couldn't generate ideas for that. Could you try rephrasing?"
                messages.append(ChatMessage(role: .assistant, content: .aiError(errorMessage)))
            }
        }
    }
    
    func generateMoreSuggestions() {
        messages.removeAll { $0.content == .generateMoreIdeasButton }
        
        Task {
            let loadingMessage = ChatMessage(role: .assistant, content: .descriptiveLoading("Generating a few more suggestions..."))
            messages.append(loadingMessage)

            if let newSuggestions = await aiService.generateInitialLessonIdeas(for: topic, count: 3) { // Generate a smaller batch
                messages.removeAll { $0.id == loadingMessage.id }

                self.lessonSuggestions.append(contentsOf: newSuggestions)
                let suggestionIDs = newSuggestions.map { $0.id }

                let responseText = "Of course! Here are a few more ideas:"
                messages.append(ChatMessage(role: .assistant, content: .text(responseText)))
                
                messages.append(ChatMessage(role: .assistant, content: .inlineLessonSuggestions(suggestionIDs)))
                
                // Ensure we only have one final prompt at a time
                messages.removeAll { $0.content == .finalPrompt }
                messages.append(ChatMessage(role: .assistant, content: .finalPrompt))
                messages.append(ChatMessage(role: .assistant, content: .generateMoreIdeasButton))
            } else {
                messages.removeAll { $0.id == loadingMessage.id }
                let errorMessage = "Sorry, I couldn't generate more ideas right now. Please try again in a moment."
                messages.append(ChatMessage(role: .assistant, content: .aiError(errorMessage)))
            }
        }
    }

    /// Replaces a specific lesson suggestion with a new one from the AI.
    func swapSuggestion(_ lessonToSwap: LessonSuggestion) {
        Task {
            swappingLessonID = lessonToSwap.id
            
            if let newSuggestion = await aiService.swapLessonSuggestion(for: topic, existingLessons: lessonSuggestions, lessonToSwap: lessonToSwap) {
                // Find the index of the old lesson and replace it
                if let index = lessonSuggestions.firstIndex(where: { $0.id == lessonToSwap.id }) {
                    lessonSuggestions[index] = newSuggestion
                }
            } else {
                // Handle failure - maybe show an alert or a temporary error message in the chat
                let errorMessage = "Sorry, I couldn't swap that suggestion. Please try again."
                messages.append(ChatMessage(role: .assistant, content: .aiError(errorMessage)))
            }
            
            swappingLessonID = nil
        }
    }

    func validateAndProceed(completion: @escaping (Bool) -> Void) {
        guard let range = parseLessonCountRange(from: lessonCountTarget) else {
            completion(true) // If no target is set, allow proceeding
            return
        }
        
        let minimumLessons = range.min
        if selectedLessons.count < minimumLessons {
            Task {
                await fulfillLessonTarget()
                completion(false) // Don't proceed to finalize view yet
            }
        } else {
            completion(true) // Proceed to finalize view
        }
    }

    func generateCourse() {
        Task {
            await fulfillLessonTarget()
            print("Generating course with \(selectedLessons.count) lessons.")
            // Future: Transition to the next screen with the generated course
        }
    }
    
    private func parseLessonCountRange(from option: String) -> (min: Int, max: Int)? {
        let numbers = option.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        if numbers.count == 2 {
            return (min: numbers[0], max: numbers[1])
        } else if numbers.count == 1 {
            return (min: numbers[0], max: numbers[0] + 2) // Handle cases like "3-5" vs "3+"
        }
        return nil
    }
    
    private func fulfillLessonTarget() async {
        guard let range = parseLessonCountRange(from: lessonCountTarget) else { return }
        
        let lessonsToGenerate = range.min - selectedLessons.count
        
        guard lessonsToGenerate > 0 else { return }
        
        messages.append(ChatMessage(role: .assistant, content: .text("You were aiming for at least \(range.min) lessons, but only had \(selectedLessons.count). I'll add \(lessonsToGenerate) more to help you meet your goal.")))
        
        let loadingMessage = ChatMessage(role: .assistant, content: .descriptiveLoading("Adding lessons to your plan..."))
        messages.append(loadingMessage)
        
        if let finalSuggestions = await aiService.fulfillLessonPlan(topic: topic, existingLessons: lessonSuggestions, count: lessonsToGenerate) {
            messages.removeAll { $0.id == loadingMessage.id }

            lessonSuggestions.append(contentsOf: finalSuggestions)
            
            messages.append(ChatMessage(role: .assistant, content: .text("I've added \(lessonsToGenerate) more lessons to your plan.")))
        } else {
            messages.removeAll { $0.id == loadingMessage.id }
            let errorMessage = "Sorry, I couldn't add the final lessons to your plan. You can continue to the next step, or try generating more ideas manually."
            messages.append(ChatMessage(role: .assistant, content: .aiError(errorMessage)))
        }
    }
} 