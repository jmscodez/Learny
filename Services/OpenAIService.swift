import Foundation
import SwiftUI

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

struct CourseMetadata: Decodable {
    let overview: String
    let learningObjectives: [String]
    let whoIsThisFor: String
    let estimatedTime: String
    
    enum CodingKeys: String, CodingKey {
        case overview
        case learningObjectives = "learning_objectives"
        case whoIsThisFor = "who_is_this_for"
        case estimatedTime = "estimated_time"
    }
}

/// A service that connects to a live AI language model to generate course content.
final class OpenAIService {
    
    /// A shared singleton instance of the service.
    static let shared = OpenAIService()
    private init() {}
    
    private let apiKey = APIKey.openRouterKey
    private let model = "meta-llama/llama-4-scout"
    private let endpointURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    /// Generates the initial set of lesson ideas based on a topic.
    func generateInitialLessonIdeas(for topic: String, difficulty: Difficulty = .beginner, pace: Pace = .balanced, count: Int = 5) async -> [LessonSuggestion]? {
        let difficultyGuide = getDifficultyInstructions(for: difficulty)
        let paceGuide = getPaceInstructions(for: pace)
        
        let prompt = """
        You are an expert curriculum designer. A user wants to create a course about '\(topic)' with the following specifications:
        
        **DIFFICULTY LEVEL: \(difficulty.rawValue.uppercased())**
        \(difficultyGuide)
        
        **PACE LEVEL: \(pace.rawValue.uppercased())**
        \(paceGuide)
        
        Generate \(count) diverse, high-level lesson ideas for this course that match the specified difficulty and pace levels. 
        
        For \(difficulty.rawValue) level:
        - Adjust the complexity and depth of topics accordingly
        - Use appropriate terminology for the target audience
        - Consider the assumed prior knowledge level
        
        For \(pace.rawValue) pace:
        - Adjust the scope and depth of each lesson
        - Consider the time investment per lesson
        - Balance breadth vs depth appropriately
        
        Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object in the array should have a 'title' and a 'description' key. Do not include any other text, just the raw JSON.
        """
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
    
    /// Generates topic-specific interest areas using AI
    func generateTopicSpecificInterests(for topic: String) async -> [InterestArea]? {
        print("🤖 [AI DEBUG] Starting to generate interests for topic: '\(topic)'")
        
        let prompt = """
        You are an expert curriculum designer. A user wants to learn about '\(topic)'. 
        
        Generate 8 HIGHLY SPECIFIC interest areas within this topic. AVOID generic terms like "fundamentals", "basics", "key concepts", "practical applications", "advanced topics", "best practices", or "core concepts".
        
        Instead, focus on SPECIFIC aspects unique to \(topic). For example:
        - If topic is "Soccer": use "Ball Control & Dribbling", "Tactical Formations", "Shooting Techniques", "Famous Players", etc.
        - If topic is "Civil War": use "Causes & Origins", "Major Battles", "Key Figures", "Reconstruction Era", etc.
        - If topic is "Cooking": use "Knife Skills", "Sauce Making", "Baking Techniques", "International Cuisines", etc.
        
        Requirements:
        - Each title should be 2-4 words and SPECIFIC to \(topic)
        - Avoid generic educational terms
        - Focus on concrete, actionable subtopics
        - Make them engaging and clearly differentiated
        - Include diverse aspects of the subject
        
        For each interest area, provide:
        - 'title': Specific title (NO generic terms)
        - 'description': Brief description of what this covers
        - 'icon': SF Symbol name (like "soccerball", "figure.run", "target", "star.fill", etc.)
        - 'color': Color name (blue, green, red, purple, orange, yellow, cyan, mint, pink, brown)
        
        Your response MUST be a valid JSON object with a single key 'interests' containing an array of objects.
        
        Do not include any other text, just the raw JSON.
        """
        
        let messages = [
            AIMessage(role: "user", content: prompt)
        ]
        
        let request = AIRequest(model: model, messages: messages, max_tokens: 1024, response_format: ["type": "json_object"])
        
        do {
            print("🤖 [AI DEBUG] Making API request...")
            let data = try await performRequest(request)
            print("🤖 [AI DEBUG] Received response data")
            
            guard let aiResponse = try? JSONDecoder().decode(AIResponse.self, from: data),
                  let contentString = aiResponse.choices.first?.message.content else {
                print("🤖 [AI DEBUG] Failed to decode AI response or content is empty")
                return nil
            }
            
            print("🤖 [AI DEBUG] Raw AI response: \(contentString)")
            
            guard let jsonString = extractJsonString(from: contentString),
                  let nestedData = jsonString.data(using: .utf8) else {
                print("🤖 [AI DEBUG] Failed to extract JSON from response")
                return nil
            }
            
            print("🤖 [AI DEBUG] Extracted JSON: \(jsonString)")
            
            struct InterestPayload: Decodable {
                let interests: [AIInterestArea]
            }
            
            struct AIInterestArea: Decodable {
                let title: String
                let description: String
                let icon: String
                let color: String
            }
            
            let payload = try JSONDecoder().decode(InterestPayload.self, from: nestedData)
            print("🤖 [AI DEBUG] Successfully decoded \(payload.interests.count) interests")
            
            // Convert to InterestArea objects
            let interestAreas = payload.interests.map { aiInterest in
                InterestArea(
                    title: aiInterest.title,
                    icon: aiInterest.icon,
                    color: colorFromString(aiInterest.color),
                    isSelected: false
                )
            }
            
            print("🤖 [AI DEBUG] Generated interests: \(interestAreas.map { $0.title })")
            return interestAreas
            
        } catch {
            print("🤖 [AI DEBUG] Error during interest generation: \(error)")
            print("🤖 [AI DEBUG] Error details: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Generates personalized lesson ideas based on comprehensive user preferences.
    func generatePersonalizedLessonIdeas(
        for topic: String,
        difficulty: Difficulty,
        pace: Pace,
        experience: String,
        interests: [String],
        goals: [String],
        timeCommitment: Int
    ) async -> [LessonSuggestion]? {
        let difficultyGuide = getDifficultyInstructions(for: difficulty)
        let paceGuide = getPaceInstructions(for: pace)
        
        let prompt = """
        You are an expert curriculum designer creating a highly personalized course about '\(topic)'. Use the following user profile to generate the most relevant and engaging lesson ideas:
        
        **USER PROFILE:**
        - Experience Level: \(experience.isEmpty ? "Not specified" : experience)
        - Specific Interests: \(interests.isEmpty ? "General" : interests.joined(separator: ", "))
        - Learning Goals: \(goals.isEmpty ? "General knowledge" : goals.joined(separator: ", "))
        - Time per Lesson: \(timeCommitment) minutes
        
        **COURSE SPECIFICATIONS:**
        - Difficulty: \(difficulty.rawValue.uppercased()) - \(difficultyGuide)
        - Pace: \(pace.rawValue.uppercased()) - \(paceGuide)
        
        **PERSONALIZATION REQUIREMENTS:**
        1. Tailor lessons to match their stated interests and goals
        2. Consider their experience level when setting depth and complexity
        3. Design each lesson to fit within \(timeCommitment) minutes
        4. Create a progressive learning path that builds knowledge systematically
        5. Include practical, applicable content that aligns with their goals
        
        Generate 8-10 diverse, personalized lesson ideas that create a comprehensive learning journey. Each lesson should feel custom-made for this specific learner.
        
        Your response MUST be a valid JSON object with a single key 'lessons' that contains an array of objects. Each object should have:
        - 'title': Engaging lesson title
        - 'description': Clear description explaining what they'll learn and why it matters to their goals
        
        Do not include any other text, just the raw JSON.
        """
        
        return await generateSuggestions(with: prompt)
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
    
    /// Generates rich, descriptive metadata for a course.
    func generateCourseMetadata(for topic: String, lessonTitles: [String]) async -> CourseMetadata? {
        let titles = lessonTitles.joined(separator: ", ")
        let prompt = """
        You are an expert curriculum designer. A user is creating a course about "\(topic)".
        The course has the following lessons: \(titles).

        Please generate the following metadata for this course. Your response MUST be a valid JSON object.
        1. "overview": A single, engaging paragraph (around 50-70 words) that summarizes what the course is about.
        2. "learning_objectives": An array of 2-3 strings. Each string is a key takeaway or skill the user will gain.
        3. "who_is_this_for": A single, encouraging sentence describing the ideal student for this course.
        4. "estimated_time": A string representing the approximate total time to complete the course (e.g., "Approx. 45-60 minutes").

        Return ONLY the raw JSON object, with no other text or formatting.
        """
        
        let messages = [AIMessage(role: "user", content: prompt)]
        let request = AIRequest(model: model, messages: messages, response_format: ["type": "json_object"])
        
        do {
            let data = try await performRequest(request)
            guard let aiResponse = try? JSONDecoder().decode(AIResponse.self, from: data),
                  let contentString = aiResponse.choices.first?.message.content,
                  let nestedData = contentString.data(using: .utf8) else {
                return nil
            }
            let metadata = try JSONDecoder().decode(CourseMetadata.self, from: nestedData)
            return metadata
        } catch {
            print("AI Service Error during course metadata generation: \(error)")
            return nil
        }
    }
    
    /// Generates the rich, interactive screens for a full lesson.
    func generateLessonScreens(for lessonTitle: String, topic: String, difficulty: Difficulty = .beginner, pace: Pace = .balanced) async -> [LessonScreen] {
        let difficultyInstructions = getDifficultyInstructions(for: difficulty)
        let paceInstructions = getPaceInstructions(for: pace)
        let screenCount = getScreenCount(for: pace)
        
        let prompt = """
        You are a world-class instructional designer, and your specialty is creating unforgettable, specific, and vivid learning experiences for a mobile app. Your goal is not to be generic, but to use concrete examples, names, and data to tell a compelling story.

        The course is about "\(topic)" and this lesson is titled "\(lessonTitle)".
        
        **DIFFICULTY LEVEL: \(difficulty.rawValue.uppercased())**
        \(difficultyInstructions)
        
        **PACE LEVEL: \(pace.rawValue.uppercased())**
        \(paceInstructions)

        **Your Core Principles:**
        1.  **Be Specific, Not Vague:** Instead of "players have influence," say "LeBron James' 'I PROMISE' school in Akron has provided resources for over 1,600 students." Use names, numbers, and specific events.
        2.  **Tell a Story:** Structure the lesson with a clear beginning, middle, and end. Create a narrative arc.
        3.  **Focus on Surprising Details:** Uncover fascinating facts or perspectives that the average person might not know.
        4.  **Vary Interactivity:** Use a mix of screen types to keep the user engaged and active.

        Your response MUST be a valid JSON object with a single key, "screens".
        The value of "screens" is an array of \(screenCount) screen objects. Each object must have a "type" and a "payload".

        **Screen Types & How To Use Them Effectively:**

        1.  `"type": "title"`
            -   `"payload": { "title": String, "subtitle": String (optional), "hook": String }`
            -   **Usage:** The hook must be a fascinating, non-obvious question that sparks immediate curiosity.

        2.  `"type": "info"`
            -   `"payload": { "text": String }`
            -   **Usage:** Present a single, powerful idea or fact. Use it to introduce a key person, event, or concept with specific details.

        3.  `"type": "tapToReveal"`
            -   `"payload": { "question": String, "answer": String }`
            -   **Usage:** Pose a "What happened next?" or "What was the result?" style question. The answer should be a surprising or impactful outcome.

        4.  `"type": "multipleChoice"`
            -   `"payload": { "question": String, "options": [String], "correctIndex": Int, "explanation": String }`
            -   **Usage:** Test understanding with 3-4 options. The explanation should clarify why the answer is correct and why others are wrong.

        5.  `"type": "trueFalse"`
            -   `"payload": { "statement": String, "isTrue": Bool, "explanation": String }`
            -   **Usage:** Present a statement that challenges common assumptions or tests specific facts. Great for misconceptions.

        6.  `"type": "dragToOrder"`
            -   `"payload": { "instruction": String, "items": [String], "correctOrder": [Int] }`
            -   **Usage:** Have users arrange events chronologically, steps in a process, or items by importance. Items should be meaningful and specific.

        7.  `"type": "cardSort"`
            -   `"payload": { "instruction": String, "categories": [String], "cards": [{ "text": String, "correctCategoryIndex": Int }] }`
            -   **Usage:** Sort concepts, people, or examples into categories. Great for classification and understanding relationships.

        8.  `"type": "dialogue"`
            -   `"payload": { "lines": [{ "speaker": String, "message": String }] }`
            -   **Usage:** Create a short, impactful exchange between real, named individuals. It could be a quote or a simulated conversation that reveals different perspectives.

        9.  `"type": "matching"`
            -   `"payload": { "pairs": [{ "term": String, "definition": String }] }`
            -   **Usage:** Help the user connect key concepts, people, or projects to their impact.

        10. `"type": "quiz"`
            -   `"payload": { "questions": [{ "prompt": String, "options": [String], "correctIndex": Int }] }`
            -   **Usage:** End the lesson with EXACTLY 5 high-quality multiple-choice questions that test understanding of the content. Each question must have 4 options, be contextual to the lesson, and test comprehension rather than memorization. Students need 4 out of 5 correct to pass. Include explanations for correct answers where helpful.

        **Task:**
        Generate a sequence of \(screenCount) screens for the lesson "\(lessonTitle)".
        Start with a "title" screen.
        End with a "quiz" screen.
        Return ONLY the raw JSON object, with no other text, markdown, or explanations.
        """
        
        let messages = [
            AIMessage(role: "system", content: "You are a JSON-only curriculum design expert."),
            AIMessage(role: "user", content: prompt)
        ]
        
        let request = AIRequest(model: model, messages: messages, max_tokens: 4096, response_format: ["type": "json_object"])

        do {
            let data = try await performRequest(request)
            
            struct ScreenPayload: Decodable {
                let screens: [LessonScreen]
            }

            guard let aiResponse = try? JSONDecoder().decode(AIResponse.self, from: data),
                  let contentString = aiResponse.choices.first?.message.content else {
                print("Failed to get lesson content string from AI response.")
                return []
            }
            
            guard let jsonString = extractJsonString(from: contentString),
                  let nestedData = jsonString.data(using: .utf8) else {
                print("Could not extract or encode JSON string from AI response.")
                return []
            }

            let payloadData = try JSONDecoder().decode(ScreenPayload.self, from: nestedData)
            return payloadData.screens
        } catch {
            print("Error generating lesson screens: \(error)")
            // Consider returning a fallback lesson here
            return []
        }
    }
    
    // MARK: - Difficulty & Pace Customization
    
    private func getDifficultyInstructions(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .beginner:
            return """
            - Use simple, everyday language and avoid jargon
            - Explain concepts step-by-step with plenty of context
            - Include lots of concrete examples and analogies
            - Assume no prior knowledge of the topic
            - Break complex ideas into smaller, digestible pieces
            - Use encouraging, supportive tone
            - Provide clear definitions for any necessary terms
            """
        case .intermediate:
            return """
            - Assume basic familiarity with core concepts
            - Use moderate technical terminology with brief explanations
            - Focus on relationships between concepts
            - Include practical applications and real-world examples
            - Move at a steady pace without excessive hand-holding
            - Challenge users to make connections
            - Balance theory with practice
            """
        case .advanced:
            return """
            - Use sophisticated language and technical terminology freely
            - Assume strong foundational knowledge
            - Dive deep into nuanced concepts and edge cases
            - Explore theoretical frameworks and complex relationships
            - Include expert-level insights and analysis
            - Challenge assumptions and present multiple perspectives
            - Minimal explanations of basic concepts
            """
        }
    }
    
    private func getPaceInstructions(for pace: Pace) -> String {
        switch pace {
        case .quickReview:
            return """
            - Hit only the key highlights and main points
            - Focus on essential concepts without extensive detail
            - Use efficient, concise explanations
            - Minimize deep exploration of subtopics
            - Perfect for refreshing existing knowledge
            - Prioritize breadth over depth
            """
        case .balanced:
            return """
            - Provide thorough explanations with good detail
            - Include practical examples and interactive exercises
            - Balance theory with application
            - Allow time for concept absorption
            - Mix different learning activities for engagement
            - Most comprehensive learning experience
            """
        case .deepDive:
            return """
            - Explore topics in extensive detail
            - Include multiple perspectives and viewpoints
            - Cover subtopics, edge cases, and advanced applications
            - Provide comprehensive analysis and context
            - Use varied, rich examples and case studies
            - Maximum depth and thoroughness
            """
        }
    }
    
    private func getScreenCount(for pace: Pace) -> String {
        switch pace {
        case .quickReview: return "4-5"
        case .balanced: return "6-8"
        case .deepDive: return "8-12"
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

        return text
    }

    /// Generates a conversational AI response based on the conversation history and context
    func generateConversationalResponse(
        messages: [ChatMessage],
        courseContext: CourseContext
    ) async -> String? {
        
        // Convert ChatMessage to AIMessage format
        let aiMessages = messages.map { message in
            let contentText: String
            switch message.content {
            case .text(let text):
                contentText = text
            default:
                contentText = "Non-text message"
            }
            
            return AIMessage(
                role: message.role == .user ? "user" : "assistant",
                content: contentText
            )
        }
        
        // Add system context for the conversation
        let systemMessage = AIMessage(
            role: "system",
            content: """
            You are an enthusiastic AI learning assistant helping a user customize their course about "\(courseContext.topic)". 
            
            Context:
            - Course Topic: \(courseContext.topic)
            - User Experience: \(courseContext.experience)
            - Difficulty Level: \(courseContext.difficulty.rawValue)
            - Time per Lesson: \(courseContext.timeCommitment) minutes
            - Selected Topics: \(courseContext.selectedTopics.joined(separator: ", "))
            
            Your role is to:
            1. Ask engaging follow-up questions about what they want to learn
            2. Understand their specific interests and goals
            3. Suggest relevant topics and approaches
            4. Keep the conversation natural and helpful
            5. Use emojis occasionally to be friendly
            6. Remember what they've told you and build on it
            
            Be conversational, enthusiastic, and focus on understanding what will make this course perfect for them. Ask one clear question at a time and provide 2-3 relevant suggestions when appropriate.
            """
        )
        
        let allMessages = [systemMessage] + aiMessages
        let request = AIRequest(model: model, messages: allMessages, max_tokens: 512)
        
        do {
            let data = try await performRequest(request)
            let response = try JSONDecoder().decode(AIResponse.self, from: data)
            return response.choices.first?.message.content
        } catch {
            print("AI Service Error during conversational response: \(error.localizedDescription)")
            return "I'm having trouble connecting right now. Could you tell me more about what specific aspects of \(courseContext.topic) interest you most?"
        }
    }
    
    /// Generates contextual suggestions based on the conversation state
    func generateContextualSuggestions(
        conversationHistory: [ChatMessage],
        courseContext: CourseContext
    ) async -> [String] {
        
        let recentMessages = conversationHistory.suffix(4).map { message in
            let contentText: String
            switch message.content {
            case .text(let text):
                contentText = text
            default:
                contentText = "Non-text message"
            }
            return "\(message.role == .user ? "User" : "AI"): \(contentText)"
        }.joined(separator: "\n")
        
        let prompt = """
        Based on this conversation about a "\(courseContext.topic)" course:
        
        \(recentMessages)
        
        Generate 3 short, relevant suggestion phrases (4-6 words each) that would help continue the conversation naturally. Focus on specific aspects, learning approaches, or follow-up topics that would be valuable to explore.
        
        Return only a JSON array of strings, no other text.
        """
        
        let messages = [AIMessage(role: "user", content: prompt)]
        let request = AIRequest(model: model, messages: messages, max_tokens: 256, response_format: ["type": "json_object"])
        
        do {
            let data = try await performRequest(request)
            guard let aiResponse = try? JSONDecoder().decode(AIResponse.self, from: data),
                  let contentString = aiResponse.choices.first?.message.content,
                  let jsonData = contentString.data(using: String.Encoding.utf8) else {
                return defaultSuggestions(for: courseContext.topic)
            }
            
            let suggestions = try JSONDecoder().decode([String].self, from: jsonData)
            return suggestions
        } catch {
            print("Error generating contextual suggestions: \(error)")
            return defaultSuggestions(for: courseContext.topic)
        }
    }
    
    private func defaultSuggestions(for topic: String) -> [String] {
        let topicLower = topic.lowercased()
        
        if topicLower.contains("programming") || topicLower.contains("coding") {
            return ["Practical projects", "Best practices", "Common mistakes"]
        } else if topicLower.contains("history") {
            return ["Key events", "Important figures", "Cultural impact"]
        } else if topicLower.contains("science") {
            return ["Real-world applications", "Latest discoveries", "Hands-on experiments"]
        } else {
            return ["Practical examples", "Advanced concepts", "Real-world applications"]
        }
    }
    
    /// Helper function to convert color string to SwiftUI Color
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "mint": return .mint
        case "pink": return .pink
        case "brown": return .brown
        case "gray", "grey": return .gray
        case "black": return .black
        case "white": return .white
        default: return .blue // Default fallback
        }
    }
} 