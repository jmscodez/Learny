//
//  EducationalTutorService.swift
//  Learny
//

import Foundation

class EducationalTutorService {
    static let shared = EducationalTutorService()
    private let openAIService = OpenAIService.shared
    
    private init() {}
    
    // MARK: - Core Tutor Personality & Expertise
    
    private let tutorSystemPrompt = """
    You are an expert educational tutor and lesson designer with 20+ years of experience in personalized learning. Your expertise includes:

    CORE IDENTITY:
    - Master educator specializing in adaptive learning
    - Expert in breaking down complex topics into digestible lessons
    - Skilled at identifying individual learning styles and interests
    - Passionate about creating engaging, memorable educational experiences

    YOUR TEACHING PHILOSOPHY:
    - Every learner is unique and deserves personalized content
    - Deep understanding comes from connecting new concepts to existing interests
    - Best learning happens through progressive complexity and real-world examples
    - Engagement is key - lessons should be fascinating, not just informative

    CONVERSATION STYLE:
    - Enthusiastic and encouraging, but not overly casual
    - Ask insightful follow-up questions that reveal learning preferences
    - Show genuine curiosity about the learner's specific interests
    - Use examples and analogies that resonate with their background

    LESSON CREATION EXPERTISE:
    - Design lessons that build upon each other logically
    - Include multiple learning modalities (visual, auditory, kinesthetic concepts)
    - Create clear learning objectives and outcomes
    - Ensure content is neither too basic nor overwhelming
    - Focus on practical application and real-world relevance

    CURRENT CONTEXT:
    You're helping a learner create personalized lessons for their course. Your goal is to understand their specific interests, learning style, and depth preferences to create truly customized educational content.
    """
    
    // MARK: - Conversation Stage Handlers
    
    func generateDynamicTopicPills(for topic: String) async -> [TopicPill] {
        let prompt = """
        Generate 5 highly specific, engaging topic categories for "\(topic)"
        
        CRITICAL REQUIREMENTS:
        - Make each category HIGHLY SPECIFIC to "\(topic)" (not generic)
        - Use engaging, exciting titles that spark curiosity
        - Include appropriate emojis that match the content
        - Focus on fascinating aspects that would intrigue learners
        - Ensure variety: mix historical, technical, personal, strategic, cultural angles
        
        EXAMPLES for "NHL":
        - "Stanley Cup Legends" with 🏆
        - "Modern Superstars" with ⭐
        - "Team Rivalries" with ⚔️
        - "Analytics Revolution" with 📊
        - "Playoff Drama" with 🎭
        
        EXAMPLES for "Julius Erving":
        - "ABA Revolutionary Years" with 🌟
        - "Signature Moves & Style" with 🏀
        - "Cultural Impact & Legacy" with 👑
        - "Rivalry with Kareem" with ⚔️
        - "Business Ventures" with 💼
        
        EXAMPLES for "Egypt":
        - "Pharaohs & Dynasties" with 👑
        - "Pyramids & Monuments" with 🏛️
        - "Hieroglyphics & Writing" with 📜
        - "Mummies & Afterlife" with ⚱️
        - "Modern Cairo Life" with 🌃
        
        STRICT JSON FORMAT - Return EXACTLY this structure:
        {
          "pills": [
            {
              "title": "Specific engaging title",
              "icon": "🎯",
              "description": "Brief description of what this covers"
            },
            {
              "title": "Another specific title",
              "icon": "⚡",
              "description": "Brief description"
            }
          ]
        }
        
        TOPIC: \(topic)
        
        Return ONLY valid JSON, no other text.
        """
        
        let response = await callTutorAPI(prompt: prompt) ?? ""
        return parseDynamicTopicPillsResponse(response, topic: topic)
    }
    
    func generateInitialResponse(for topic: String) async -> String {
        let prompt = """
        \(tutorSystemPrompt)
        
        TASK: Generate an enthusiastic, personalized welcome message for a learner who wants to create custom lessons about "\(topic)".
        
        FORMATTING REQUIREMENTS:
        - Use **bold text** for key terms and emphasis (surround with **)
        - Use bullet points (•) for lists of aspects or features
        - Break content into digestible paragraphs with line breaks
        - Make important concepts stand out visually
        
        CONTENT REQUIREMENTS:
        - Show expertise and passion for the subject
        - Acknowledge the complexity and richness of the topic
        - Highlight 2-3 specific fascinating aspects as bullet points
        - Ask an engaging question that reveals their specific interests
        - Keep it conversational but professional
        
        EXAMPLE FORMAT:
        "That's fascinating! **[Topic]** has so many incredible layers:
        
        • **[Specific aspect]** and its impact
        • **[Another aspect]** that shaped history
        • **[Third aspect]** that continues today
        
        **What aspect draws you in most?** Is it [specific area], [another area], or perhaps [third area]?"
        
        TOPIC: \(topic)
        """
        
        return await callTutorAPI(prompt: prompt) ?? "I'm excited to help you explore **\(topic)**! What specific aspects interest you most?"
    }
    
    func generateFollowUpQuestions(for topic: String, userInput: String) async -> [String] {
        let prompt = """
        \(tutorSystemPrompt)
        
        CRITICAL INSTRUCTION: You are generating SHORT TOPIC NAMES for interactive pill buttons and checkboxes, NOT questions or paragraphs.
        
        CONTEXT:
        - Main Topic: \(topic)
        - User selected: "\(userInput)"
        
        TASK: Generate exactly 5-6 SHORT, SPECIFIC sub-topics related to "\(userInput)" within "\(topic)".
        
        STRICT REQUIREMENTS:
        - Each item must be 1-3 words ONLY
        - NO sentences, NO questions, NO explanations
        - Focus on concrete, actionable sub-topics
        - Make them immediately clear and specific
        - These become selectable options in the app
        
        GOOD Examples for "Modern Relevance" + "McDonald's":
        - Brand Evolution
        - Menu Innovation  
        - Global Expansion
        - Digital Strategy
        - Sustainability Efforts
        - Health Initiatives
        
        BAD Examples:
        - "How do you think McDonald's has adapted to changing consumer preferences"
        - "I'm thrilled to help you explore"
        - Any sentence or question format
        
        FORMAT: Return ONLY the short topic names, one per line, no emojis, no explanations.
        
        Topic: \(topic)
        Selected Area: \(userInput)
        """
        
        let response = await callTutorAPI(prompt: prompt) ?? ""
        let topics = response.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.contains("?") && $0.count < 50 } // Filter out questions and long text
        
        // Fallback if AI doesn't follow instructions
        if topics.isEmpty || topics.first?.contains("?") == true {
            return generateFallbackTopics(for: userInput, topic: topic)
        }
        
        return Array(topics.prefix(6))
    }
    
    private func generateFallbackTopics(for userInput: String, topic: String) -> [String] {
        // Provide hardcoded fallbacks based on common patterns
        if userInput.lowercased().contains("modern") || userInput.lowercased().contains("relevance") {
            return ["Brand Evolution", "Digital Strategy", "Global Expansion", "Innovation", "Market Trends", "Future Outlook"]
        } else if userInput.lowercased().contains("historical") {
            return ["Key Events", "Timeline", "Milestones", "Turning Points", "Legacy", "Impact"]
        } else {
            return ["Core Concepts", "Key Principles", "Applications", "Examples", "Techniques", "Best Practices"]
        }
    }
    
    func generateDeepDivePrompt(for topic: String, interests: [String]) async -> String {
        let prompt = """
        \(tutorSystemPrompt)
        
        CONTEXT:
        - Topic: \(topic)
        - User's interests: \(interests.joined(separator: ", "))
        
        TASK: Generate an encouraging prompt that asks the user to share detailed thoughts about their interests.
        
        REQUIREMENTS:
        - Reference their specific interests to show you were listening
        - Encourage them to share as much detail as possible
        - Explain how their detailed input will lead to better lessons
        - Make it feel like an exciting opportunity to dive deep
        - Keep it warm and encouraging
        
        LENGTH: 2-3 sentences maximum
        """
        
        return await callTutorAPI(prompt: prompt) ?? "Perfect! Now tell me in detail - what specific aspects fascinate you most? The more detail you provide, the better I can tailor your lessons."
    }
    
    func generatePersonalizedLessons(
        topic: String,
        interests: [String],
        detailedInput: String,
        conversationContext: [String]
    ) async -> [LessonOption] {
        
        let prompt = """
        \(tutorSystemPrompt)
        
        CONTEXT:
        - Main Topic: \(topic)
        - User's Interests: \(interests.joined(separator: ", "))
        - Detailed Input: "\(detailedInput)"
        - Full Conversation: \(conversationContext.joined(separator: " | "))
        
        TASK: Create 5 highly personalized lesson options based on this learner's specific interests and learning preferences.
        
        LESSON CREATION REQUIREMENTS:
        - Each lesson should be directly connected to their expressed interests
        - Titles should be engaging and specific (not generic)
        - Descriptions should show clear learning outcomes and practical value
        - Vary the approach: some analytical, some narrative, some practical
        - Ensure progressive complexity across the lessons
        - Include real-world applications and examples
        - Make each lesson feel essential and exciting
        
        FORMAT: Return exactly 5 lessons in this format:
        LESSON 1:
        Title: [Engaging, specific title]
        Description: [Clear description of what they'll learn and why it matters]
        Icon: [Single relevant emoji]
        
        LESSON 2:
        [Continue same format...]
        
        EXAMPLE (for NBA/Player Skills interest):
        LESSON 1:
        Title: Deconstructing Elite Shooting Mechanics
        Description: Analyze the biomechanics behind Steph Curry's shot, including footwork, release point, and consistency techniques you can apply to understand precision in any field
        Icon: 🎯
        """
        
        let response = await callTutorAPI(prompt: prompt) ?? ""
        return parseLessonResponse(response)
    }
    
    func generateDetailedInterests(topic: String, category: String) async -> [DetailedInterest] {
        let prompt = """
        \(tutorSystemPrompt)
        
        CONTEXT:
        - Main Topic: \(topic)
        - Category: \(category)
        
        TASK: Generate 6 highly specific, engaging interest areas within "\(category)" for the topic "\(topic)".
        
        CRITICAL REQUIREMENTS:
        - Make each interest HIGHLY SPECIFIC to the actual topic (not generic)
        - Include detailed descriptions that show expertise and intrigue
        - Use appropriate emojis that match the content
        - Focus on fascinating, lesser-known aspects that would excite learners
        - Ensure each interest is unique and valuable
        
        EXAMPLES for Julius Erving + "Player Skills":
        - His revolutionary ABA slam dunk techniques and aerial artistry
        - Signature finger roll layup and its biomechanical precision
        - Transition from playground style to professional fundamentals
        - Leadership skills developed through team captain roles
        - Clutch performance psychology in high-pressure moments
        - Adaptation of playing style as he aged in the NBA
        
        FORMAT: Return exactly 6 interests in this format:
        INTEREST 1:
        Title: [Specific, engaging title]
        Description: [Detailed description showing why this is fascinating]
        Icon: [Single relevant emoji]
        
        INTEREST 2:
        [Continue same format...]
        
        Make sure every title and description is specific to \(topic) and not generic educational content.
        """
        
        let response = await callTutorAPI(prompt: prompt) ?? ""
        return parseDetailedInterestsResponse(response, topic: topic, category: category)
    }
    
    func generateEngagingResponse(for userInput: String, context: String) async -> String {
        let prompt = """
        \(tutorSystemPrompt)
        
        CONTEXT: \(context)
        USER INPUT: "\(userInput)"
        
        TASK: Generate an enthusiastic, insightful response that shows you understand their interest and guides them to the next step.
        
        FORMATTING REQUIREMENTS:
        - Use **bold text** for key terms and emphasis (surround with **)
        - Use bullet points (•) for lists when appropriate
        - Break content into digestible parts with line breaks
        - Make important concepts stand out visually
        
        CONTENT REQUIREMENTS:
        - Show genuine excitement about their specific interest
        - Demonstrate subject matter expertise
        - Connect their interest to broader learning opportunities
        - Guide them naturally to the next conversation step
        - Keep it conversational and encouraging
        
        EXAMPLE FORMAT:
        "**Excellent choice!** [Specific topic] is absolutely fascinating because:
        
        • **[Key aspect]** that most people don't know about
        • **[Another aspect]** that connects to modern day
        
        **What specifically draws you to this area?** [Follow-up question]"
        """
        
        return await callTutorAPI(prompt: prompt) ?? "**That's fascinating!** Let me ask you some more specific questions to create the perfect lessons for you."
    }
    
    // MARK: - API Integration
    
    private func callTutorAPI(prompt: String) async -> String? {
        // Use the existing OpenAIService method but with better prompt formatting
        let systemPrompt = "You are an expert educational tutor and curriculum designer. You MUST always follow the exact format requested. When asked to return JSON, return ONLY valid JSON with no additional text, markdown, or explanations."
        
        // Create a combined prompt that ensures proper formatting
        let fullPrompt = systemPrompt + "\n\n" + prompt
        
        // Use the existing service method
        let dummyLesson = LessonSuggestion(title: "Dynamic Content", description: fullPrompt)
        let response = await openAIService.getLessonTutoringResponse(lesson: dummyLesson, question: "Generate the requested content.")
        
        print("AI Response for topic pills: \(response ?? "nil")")
        return response
    }
    
    // MARK: - Response Parsing
    
    private func parseLessonResponse(_ response: String) -> [LessonOption] {
        let lessons = response.components(separatedBy: "LESSON")
            .dropFirst() // Remove empty first element
            .compactMap { lessonText -> LessonOption? in
                let lines = lessonText.components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                var title = ""
                var description = ""
                var icon = "📚"
                
                for line in lines {
                    if line.hasPrefix("Title:") {
                        title = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.hasPrefix("Description:") {
                        description = String(line.dropFirst(12)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.hasPrefix("Icon:") {
                        icon = String(line.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                guard !title.isEmpty && !description.isEmpty else { return nil }
                
                return LessonOption(
                    title: title,
                    description: description,
                    icon: icon
                )
            }
        
        // Fallback lessons if parsing fails
        if lessons.isEmpty {
            return createFallbackLessons()
        }
        
        return Array(lessons.prefix(5)) // Ensure we have exactly 5 lessons
    }
    
    private func parseDetailedInterestsResponse(_ response: String, topic: String, category: String) -> [DetailedInterest] {
        let interests = response.components(separatedBy: "INTEREST")
            .dropFirst() // Remove empty first element
            .compactMap { interestText -> DetailedInterest? in
                let lines = interestText.components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                var title = ""
                var description = ""
                var icon = "🎯"
                
                for line in lines {
                    if line.hasPrefix("Title:") {
                        title = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.hasPrefix("Description:") {
                        description = String(line.dropFirst(12)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.hasPrefix("Icon:") {
                        icon = String(line.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                guard !title.isEmpty && !description.isEmpty else { return nil }
                
                return DetailedInterest(
                    title: title,
                    description: description,
                    icon: icon
                )
            }
        
        // Fallback interests if parsing fails
        if interests.isEmpty {
            return createFallbackDetailedInterests(topic: topic, category: category)
        }
        
        return Array(interests.prefix(6)) // Ensure we have exactly 6 interests
    }
    
    private func parseDynamicTopicPillsResponse(_ response: String, topic: String) -> [TopicPill] {
        print("Parsing response for topic: \(topic)")
        print("Raw response: \(response)")
        
        // Clean the response - remove any markdown or extra text
        let cleanedResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to find JSON in the response
        var jsonString = cleanedResponse
        if let jsonStart = cleanedResponse.firstIndex(of: "{"),
           let jsonEnd = cleanedResponse.lastIndex(of: "}") {
            jsonString = String(cleanedResponse[jsonStart...jsonEnd])
        }
        
        print("Cleaned JSON string: \(jsonString)")
        
        // Try to parse JSON response
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert string to data")
            return createFallbackTopicPills(topic: topic)
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let pillsArray = json["pills"] as? [[String: Any]] {
                
                print("Successfully parsed JSON with \(pillsArray.count) pills")
                
                let pills = pillsArray.compactMap { pillDict -> TopicPill? in
                    guard let title = pillDict["title"] as? String,
                          let icon = pillDict["icon"] as? String else {
                        print("Failed to parse pill: \(pillDict)")
                        return nil
                    }
                    
                    return TopicPill(title: title, icon: icon, isSelected: false)
                }
                
                // Ensure we have at least some pills
                if pills.count >= 3 {
                    print("Returning \(pills.count) dynamic pills")
                    return Array(pills.prefix(5)) // Return up to 5 pills
                } else {
                    print("Not enough valid pills parsed, using fallback")
                }
            } else {
                print("JSON structure doesn't match expected format")
            }
        } catch {
            print("Failed to parse topic pills JSON: \(error)")
        }
        
        // Fallback if parsing fails
        print("Using fallback pills for topic: \(topic)")
        return createFallbackTopicPills(topic: topic)
    }
    
    private func createFallbackTopicPills(topic: String) -> [TopicPill] {
        // Create topic-specific fallbacks
        let topicLower = topic.lowercased()
        
        if topicLower.contains("egypt") {
            return [
                TopicPill(title: "Ancient Pharaohs", icon: "👑", isSelected: false),
                TopicPill(title: "Pyramids & Tombs", icon: "🏛️", isSelected: false),
                TopicPill(title: "Hieroglyphics", icon: "📜", isSelected: false),
                TopicPill(title: "Mummification", icon: "⚱️", isSelected: false),
                TopicPill(title: "Modern Egypt", icon: "🌃", isSelected: false)
            ]
        } else if topicLower.contains("nhl") || topicLower.contains("hockey") {
            return [
                TopicPill(title: "Stanley Cup History", icon: "🏆", isSelected: false),
                TopicPill(title: "Legendary Players", icon: "⭐", isSelected: false),
                TopicPill(title: "Team Rivalries", icon: "⚔️", isSelected: false),
                TopicPill(title: "Modern Analytics", icon: "📊", isSelected: false),
                TopicPill(title: "Playoff Drama", icon: "🎭", isSelected: false)
            ]
        } else if topicLower.contains("basketball") || topicLower.contains("nba") {
            return [
                TopicPill(title: "Legendary Careers", icon: "🏀", isSelected: false),
                TopicPill(title: "Championship Runs", icon: "🏆", isSelected: false),
                TopicPill(title: "Playing Styles", icon: "⚡", isSelected: false),
                TopicPill(title: "Cultural Impact", icon: "🌟", isSelected: false),
                TopicPill(title: "Team Dynasties", icon: "👑", isSelected: false)
            ]
        } else {
            // Try to generate smart fallbacks based on the topic
            return [
                TopicPill(title: "\(topic) Basics", icon: "🎯", isSelected: false),
                TopicPill(title: "Key \(topic) Figures", icon: "👤", isSelected: false),
                TopicPill(title: "\(topic) History", icon: "📚", isSelected: false),
                TopicPill(title: "Modern \(topic)", icon: "🚀", isSelected: false),
                TopicPill(title: "\(topic) Analysis", icon: "🔬", isSelected: false)
            ]
        }
    }
    
    private func createFallbackDetailedInterests(topic: String, category: String) -> [DetailedInterest] {
        // Create topic-specific fallbacks
        return [
            DetailedInterest(title: "Core \(category) Concepts", description: "Fundamental aspects of \(category) in \(topic)", icon: "🎯"),
            DetailedInterest(title: "Advanced \(category) Techniques", description: "Sophisticated approaches and methodologies", icon: "🔬"),
            DetailedInterest(title: "Historical \(category) Development", description: "Evolution and key milestones over time", icon: "📚"),
            DetailedInterest(title: "Modern \(category) Applications", description: "Contemporary relevance and current practices", icon: "⚡"),
            DetailedInterest(title: "Expert \(category) Insights", description: "Professional perspectives and industry knowledge", icon: "🌟"),
            DetailedInterest(title: "Future \(category) Trends", description: "Emerging developments and future possibilities", icon: "🚀")
        ]
    }
    
    private func createFallbackLessons() -> [LessonOption] {
        return [
            LessonOption(title: "Core Fundamentals", description: "Essential concepts and foundational knowledge", icon: "🎯"),
            LessonOption(title: "Advanced Analysis", description: "Deep dive into complex aspects and nuanced understanding", icon: "🔬"),
            LessonOption(title: "Practical Applications", description: "Real-world implementation and hands-on examples", icon: "⚡"),
            LessonOption(title: "Expert Perspectives", description: "Insights from industry leaders and thought experts", icon: "🌟"),
            LessonOption(title: "Future Implications", description: "Emerging trends and future developments", icon: "🚀")
        ]
    }
}

// MARK: - Supporting Models

struct LessonOption: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct DetailedInterest: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

// MARK: - Uses existing AI models from OpenAIService 