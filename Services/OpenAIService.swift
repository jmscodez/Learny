import Foundation

// MARK: - Data Structures for AI Service

typealias LessonOverview = String

struct AIRequest: Codable {
    let model: String
    let messages: [AIMessage]
    let temperature: Double
    let max_tokens: Int
    let response_format: [String: String]?
    
    init(model: String, messages: [AIMessage], temperature: Double = 0.7, max_tokens: Int = 1024, response_format: [String: String]? = nil) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.response_format = response_format
    }
}

struct AIMessage: Codable {
    let role: String
    let content: String
}

struct AIResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: Message
}

struct Message: Decodable {
    let content: String
}

struct LessonPayload: Decodable {
    let lessons: [LessonSuggestion]
}

/// A service that connects to a live AI language model to generate course content.
final class OpenAIService {
    
    /// A shared singleton instance of the service.
    static let shared = OpenAIService()
    private init() {}
    
    private let apiKey = "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"
    private let model = "meta-llama/llama-4-scout"
    private let endpointURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    /// Generates the initial set of lesson ideas based on a topic.
    func generateInitialLessonIdeas(for topic: String, count: Int = 5) async -> [LessonSuggestion]? {
        let prompt = "You are an expert curriculum designer. A user wants to create a course about '\(topic)'. Generate \(count) diverse, high-level lesson ideas for this course. Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON."
        return await generateSuggestions(with: prompt)
    }
    
    /// Generates follow-up ideas based on user input and existing context.
    func generateFollowUpLessonIdeas(basedOn userQuery: String, topic: String, existingLessons: [LessonSuggestion]) async -> [LessonSuggestion]? {
        let existingTitles = existingLessons.map { $0.title }.joined(separator: ", ")
        let prompt = "You are an expert curriculum designer. A user is creating a course about '\(topic)'. They have already selected the following lessons: \(existingTitles). The user just asked to add lessons about '\(userQuery)'. Generate 2-3 new, specific lesson ideas based on the user's request that complement the existing lessons. Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON."
        return await generateSuggestions(with: prompt)
    }
    
    /// Generates a single new lesson suggestion to replace an existing one.
    func swapLessonSuggestion(for topic: String, existingLessons: [LessonSuggestion], lessonToSwap: LessonSuggestion) async -> LessonSuggestion? {
        let existingTitles = existingLessons.map { $0.title }.joined(separator: ", ")
        let prompt = """
        You are an expert curriculum designer for a course on '\(topic)'.
        The current lesson plan is: \(existingTitles).
        The user wants to replace the lesson titled '\(lessonToSwap.title)'.
        Generate a single, new, and distinct lesson idea that fits well with the rest of the plan.
        Your response MUST be a single valid JSON object with 'title' and 'description' keys. Do not include any other text, just the raw JSON.
        """
        
        guard let suggestions = await generateSuggestions(with: prompt, singleObject: true) else {
            return nil
        }
        return suggestions.first
    }
    
    /// Generates a more detailed overview for a lesson, including a paragraph and bullet points.
    func generateDetailedLessonOverview(for lesson: LessonSuggestion) async -> LessonOverview? {
        let prompt = "You are an expert, friendly tutor. A user wants to learn about the lesson: '\(lesson.title)'. Provide a single, engaging, and informative paragraph (around 50-70 words) that summarizes the key concepts of this lesson. This summary will be the first thing the user sees. Do not use markdown or special formatting. Just return the raw text."
        
        let messages = [
            AIMessage(role: "user", content: prompt)
        ]
        
        let request = AIRequest(model: model, messages: messages, max_tokens: 256)
        
        do {
            let data = try await performRequest(request)
            let response = try JSONDecoder().decode(AIResponse.self, from: data)
            return response.choices.first?.message.content
        } catch {
            print("AI Service Error during detailed overview generation: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Generates a helpful, conversational response to a user's question about a specific lesson.
    func getLessonTutoringResponse(lesson: LessonSuggestion, question: String) async -> String? {
        let prompt = """
        You are an expert, friendly tutor. The user is currently studying a lesson with the following details:
        - Title: "\(lesson.title)"
        - Description: "\(lesson.description)"

        The user has asked the following question:
        "\(question)"

        Please provide a clear, helpful, and encouraging answer to the user's question. Address them directly.
        """
        let messages = [AIMessage(role: "system", content: prompt)]
        let request = AIRequest(model: model, messages: messages, max_tokens: 512)
        
        do {
            let data = try await performRequest(request)
            let response = try JSONDecoder().decode(AIResponse.self, from: data)
            return response.choices.first?.message.content
        } catch {
            print("AI Service Error during tutoring response: \(error.localizedDescription)")
            return nil
        }
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
    func fulfillLessonPlan(topic: String, existingLessons: [LessonSuggestion], count: Int) async -> [LessonSuggestion]? {
        let existingTitles = existingLessons.map { $0.title }.joined(separator: ", ")
        let prompt = "You are an expert curriculum designer. A user is finalizing a course about '\(topic)'. They have already selected the following lessons: \(existingTitles). To meet their desired course length, you need to generate \(count) more lesson ideas that are distinct from and complementary to the existing ones. Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON."
        
        guard var suggestions = await generateSuggestions(with: prompt) else { return nil }
        // Ensure the generated suggestions are marked as selected
        for i in 0..<suggestions.count {
            suggestions[i].isSelected = true
        }
        return suggestions
    }
    
    /// Generates detailed content blocks for a specific lesson using the AI.
    func generateLessonContent(for lessonTitle: String, topic: String) async -> [ContentBlock] {
        let prompt = "You are an expert curriculum designer. Create a detailed lesson for a course on '\(topic)'. The lesson title is '\(lessonTitle)'. Your response MUST be a valid JSON object with a single key 'blocks'. The value of 'blocks' should be an array of content blocks. Each block is an object with a 'type' key ('text', 'dialogue', or 'matching') and associated content. \n- For 'text', include a 'text' field with a paragraph summary.\n- For 'dialogue', include a 'lines' array of objects, where each object has a 'speaker' and a 'message' key.\n- For 'matching', include a 'pairs' array of objects, where each object has a 'term' and 'definition' key.\nReturn ONLY the raw JSON object, with no other text or formatting."
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("Learny App", forHTTPHeaderField: "X-Title")
        request.addValue("https://learny.app", forHTTPHeaderField: "HTTP-Referer")
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
            struct AIResponse: Decodable {
                struct Choice: Decodable {
                    struct Message: Decodable { let content: String }
                    let message: Message
                }
                let choices: [Choice]
            }
            let aiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
            guard let contentString = aiResponse.choices.first?.message.content else {
                print("Failed to get lesson content string from AI response.")
                return []
            }
            
            print("[AI RESPONSE CHECKER] Raw content string for lesson content:\n---\n\(contentString)\n---")


            // Clean the string if it's wrapped in markdown
            let cleanedContentString = contentString.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("[AI RESPONSE CHECKER] Cleaned content string for parsing: \(cleanedContentString)")

            // Decode the nested JSON
            struct BlockPayload: Decodable {
                let blocks: [RawBlock]
            }
            struct RawBlock: Decodable {
                let type: String
                let text: String?
                let lines: [RawDialogueLine]?
                let pairs: [RawMatchingPair]?
            }
            struct RawDialogueLine: Decodable {
                let speaker: String
                let message: String
            }
            struct RawMatchingPair: Decodable {
                let term: String
                let definition: String
            }
            
            let nested = Data(cleanedContentString.utf8)
            let payloadData = try JSONDecoder().decode(BlockPayload.self, from: nested)
            // Map RawBlock to ContentBlock
            let blocks: [ContentBlock] = payloadData.blocks.map { raw in
                switch raw.type {
                case "text": return .text(raw.text ?? "")
                case "dialogue":
                    let dialogueLines = raw.lines?.map { DialogueLine(id: UUID(), speaker: $0.speaker, text: $0.message) }
                    return .dialogue(dialogueLines ?? [])
                case "matching":
                    let matches = raw.pairs?.map { MatchingPair(id: UUID(), term: $0.term, definition: $0.definition) } ?? []
                    let game = MatchingGame(id: UUID(), pairs: matches)
                    return .matching(game)
                default: return .text("")
                }
            }
            return blocks
        } catch {
            print("Error generating lesson content: \(error)")
            return []
        }
    }
    
    // MARK: - Private Helper
    
    private func generateSuggestions(with prompt: String, singleObject: Bool = false) async -> [LessonSuggestion]? {
        let messages = [AIMessage(role: "user", content: prompt)]
        let request = AIRequest(model: model, messages: messages)
        
        do {
            let data = try await performRequest(request)
            return parseSuggestions(from: data, singleObject: singleObject)
        } catch {
            print("AI Service Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func performRequest(_ requestPayload: AIRequest) async throws -> Data {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"

        // Authentication & Routing Headers
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("Learny App", forHTTPHeaderField: "X-Title")
        request.addValue("https://learny.app", forHTTPHeaderField: "HTTP-Referer")
        
        // Content Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(requestPayload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("AI Service HTTP Error. Status: \(statusCode). Body: \(responseBody)")
            throw NSError(domain: "AIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "AI service returned a non-200 status code. Body: \(responseBody)"])
        }
        
        return data
    }
    
    private func parseSuggestions(from data: Data, singleObject: Bool) -> [LessonSuggestion]? {
        // 1. Decode the initial response to get the content string
        guard let aiResponse = try? JSONDecoder().decode(AIResponse.self, from: data),
              let contentString = aiResponse.choices.first?.message.content,
              !contentString.isEmpty else {
            print("[AI PARSING CHECKER] Failed to decode initial AIResponse or content is empty.")
            return nil
        }

        print("[AI RESPONSE CHECKER] Raw content string from AI:\n---\n\(contentString)\n---")

        // 2. Clean the JSON string to extract only the JSON object
        guard let jsonString = extractJsonString(from: contentString) else {
            print("[AI PARSING CHECKER] No valid JSON object found in content.")
            return nil
        }
        
        print("[AI RESPONSE CHECKER] Cleaned content string for parsing: \(jsonString)")

        guard let nestedData = jsonString.data(using: .utf8), !nestedData.isEmpty else {
            print("[AI PARSING CHECKER] Cleaned content resulted in empty data.")
            return nil
        }

        // 3. Decode the actual suggestions from the cleaned string
        let decoder = JSONDecoder()
        
        if singleObject {
            if let suggestion = try? decoder.decode(LessonSuggestion.self, from: nestedData) {
                print("[AI PARSING CHECKER] Successfully parsed a single LessonSuggestion.")
                return [suggestion]
            }
        } else {
            // First, try to decode { "lessons": [...] }
            if let payload = try? decoder.decode(LessonPayload.self, from: nestedData) {
                print("[AI PARSING CHECKER] Successfully parsed LessonPayload with \(payload.lessons.count) lessons.")
                return payload.lessons
            }
            // If that fails, try to decode a direct array [...]
            if let lessons = try? decoder.decode([LessonSuggestion].self, from: nestedData) {
                print("[AI PARSING CHECKER] Successfully parsed a direct array of \(lessons.count) lessons.")
                return lessons
            }
        }
        
        print("[AI PARSING CHECKER] All parsing attempts failed for the cleaned JSON.")
        return nil
    }
    
    // Fallback content in case the AI service fails
    private func generateFallbackSuggestions() -> [LessonSuggestion] {
        return [
            LessonSuggestion(title: "Introduction to [Topic]", description: "A foundational overview to get you started."),
            LessonSuggestion(title: "Core Concepts of [Topic]", description: "Essential principles and ideas you need to understand."),
            LessonSuggestion(title: "Practical Applications", description: "How to apply what you've learned in real-world situations."),
            LessonSuggestion(title: "Advanced Techniques", description: "Taking your knowledge to the next level with sophisticated approaches."),
            LessonSuggestion(title: "Historical Context", description: "Understanding the origins and evolution of the topic.")
        ]
    }
    
    private func extractJsonString(from text: String) -> String? {
        if text.contains("```json") {
            let parts = text.components(separatedBy: "```")
            if parts.count >= 2 {
                // The JSON is likely in the second part, after the "json" tag
                var jsonPart = parts[1]
                if jsonPart.starts(with: "json") {
                    jsonPart = String(jsonPart.dropFirst(4))
                }
                return jsonPart.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        // Fallback for non-markdown responses
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        
        if let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]") {
            return String(text[start...end])
        }

        return nil
    }
} 