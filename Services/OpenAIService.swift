import Foundation

/// A service that connects to a live AI language model to generate course content.
struct OpenAIService {
    
    /// A shared singleton instance of the service.
    static let shared = OpenAIService()
    private init() {}
    
    private let apiKey = "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"
    private let model = "mistralai/mistral-7b-instruct"
    private let endpointURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    /// Generates the initial set of lesson ideas based on a topic.
    func generateInitialLessonIdeas(for topic: String, count: Int = 5) async -> [LessonSuggestion] {
        let prompt = "You are an expert curriculum designer. A user wants to create a course about '\(topic)'. Generate \(count) diverse, high-level lesson ideas for this course. Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON."
        return await generateSuggestions(with: prompt)
    }
    
    /// Generates follow-up ideas based on user input and existing context.
    func generateFollowUpLessonIdeas(basedOn userQuery: String, topic: String, existingLessons: [LessonSuggestion]) async -> [LessonSuggestion] {
        let existingTitles = existingLessons.map { $0.title }.joined(separator: ", ")
        let prompt = "You are an expert curriculum designer. A user is creating a course about '\(topic)'. They have already selected the following lessons: \(existingTitles). The user just asked to add lessons about '\(userQuery)'. Generate 2-3 new, specific lesson ideas based on the user's request that complement the existing lessons. Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON."
        return await generateSuggestions(with: prompt)
    }
    
    /// Generates a clarifying question with options based on a user's query.
    func generateClarifyingQuestion(for userQuery: String, topic: String) async -> (question: String, options: [String]) {
        // Simulate network latency
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real implementation, an LLM would generate these based on the query.
        if userQuery.lowercased().contains("lebron") {
            return (
                question: "Great question! LeBron James has had a long and multi-faceted career. Are you more interested in his on-court achievements, or his off-court impact?",
                options: ["On-court achievements", "Off-court impact"]
            )
        }
        
        return (
            question: "Interesting! Can you tell me a bit more about what aspects of '\(userQuery)' you'd like to focus on?",
            options: ["The basics", "Advanced concepts", "Historical context"]
        )
    }
    
    /// Fills out the lesson plan to meet a target number of lessons.
    func fulfillLessonPlan(topic: String, existingLessons: [LessonSuggestion], count: Int) async -> [LessonSuggestion] {
        let existingTitles = existingLessons.map { $0.title }.joined(separator: ", ")
        let prompt = "You are an expert curriculum designer. A user is finalizing a course about '\(topic)'. They have already selected the following lessons: \(existingTitles). To meet their desired course length, you need to generate \(count) more lesson ideas that are distinct from and complementary to the existing ones. Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON."
        
        var suggestions = await generateSuggestions(with: prompt)
        // Ensure the generated suggestions are marked as selected
        for i in 0..<suggestions.count {
            suggestions[i].isSelected = true
        }
        return suggestions
    }
    
    // MARK: - Private Helper
    
    private func generateSuggestions(with prompt: String) async -> [LessonSuggestion] {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a JSON-only curriculum assistant."],
                ["role": "user", "content": prompt]
            ],
            "response_format": ["type": "json_object"]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // The API returns JSON where the lesson array is nested.
            // We need to define structs to match this structure for decoding.
            struct AIResponse: Decodable {
                struct Choice: Decodable {
                    struct Message: Decodable {
                        let content: String
                    }
                    let message: Message
                }
                let choices: [Choice]
            }
            
            struct LessonPayload: Decodable {
                let lessons: [LessonSuggestion]
            }

            let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
            guard let contentString = aiResponse.choices.first?.message.content else {
                print("Failed to get content from AI response")
                return []
            }
            
            // The 'content' is a JSON *string*, so we need to decode it again.
            // The prompt also needs to instruct the AI to nest the array in a "lessons" key.
            // Let's assume the AI returns a top-level key "lessons".
            let nestedData = Data(contentString.utf8)
            let lessonPayload = try JSONDecoder().decode(LessonPayload.self, from: nestedData)
            
            return lessonPayload.lessons
            
        } catch {
            print("AI Service Error: \(error.localizedDescription)")
            return []
        }
    }
} 