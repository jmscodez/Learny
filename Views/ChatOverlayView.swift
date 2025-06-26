//
//  ChatOverlayView.swift
//  Learny
//

import SwiftUI

// LessonOption is now defined in EducationalTutorService

struct FollowUpQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let allowsTextInput: Bool
}

// New interactive selection models
struct TopicPill: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let isSelected: Bool
}

struct SpecificInterest: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let description: String
    var isSelected: Bool = false
}

enum ConversationStage {
    case initial
    case selectingTopicInterests    // New: Pill selection stage
    case selectingSpecificInterests // New: Multi-select stage
    case gatheringDetails
    case generatingLessons
    case completed
}

struct ChatOverlayView: View {
    @ObservedObject var viewModel: EnhancedCourseChatViewModel
    @State private var userMessage: String = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isTyping: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Enhanced conversation flow states
    @State private var conversationStage: ConversationStage = .initial
    @State private var conversationContext: [String] = []
    @State private var specificDetails: String = ""
    @State private var finalLessonOptions: [LessonOption] = []
    @State private var showingFinalLessonOptions: Bool = false
    @State private var selectedLessonOptions: Set<String> = []
    
    // New interactive selection states
    @State private var topicPills: [TopicPill] = []
    @State private var showingTopicPills: Bool = false
    @State private var selectedTopicPill: TopicPill?
    
    @State private var specificInterests: [SpecificInterest] = []
    @State private var showingSpecificInterests: Bool = false
    @State private var selectedSpecificInterests: [SpecificInterest] = []
    
    // Conversation encouragement
    @State private var showingConversationPrompt: Bool = false
    @State private var conversationPrompts: [String] = []
    @State private var showingPostCreationOptions: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.25),
                    Color(red: 0.15, green: 0.1, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Perfect Your Course")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Interactive AI Tutor")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("") // Placeholder for balance
                        .frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Chat Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatMessages, id: \.id) { message in
                                ChatMessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                            
                            // Topic Pills Selection
                            if showingTopicPills && !topicPills.isEmpty {
                                TopicPillsView(
                                    pills: topicPills,
                                    onPillSelected: { pill in
                                        handleTopicPillSelection(pill)
                                    }
                                )
                                .id("topicpills")
                            }
                            
                            // Specific Interests Multi-Select
                            if showingSpecificInterests && !specificInterests.isEmpty {
                                SpecificInterestsView(
                                    interests: $specificInterests,
                                    onContinue: {
                                        handleSpecificInterestsSelection()
                                    },
                                    onCustomInput: {
                                        handleCustomInterestInput()
                                    }
                                )
                                .id("specificinterests")
                            }
                            
                            // Final lesson options
                            if showingFinalLessonOptions && !finalLessonOptions.isEmpty {
                                FinalLessonOptionsView(
                                    options: finalLessonOptions,
                                    selectedOptions: $selectedLessonOptions,
                                    onContinue: {
                                        handleFinalLessonSelection()
                                    }
                                )
                                .id("finallessons")
                            }
                            
                            // Conversation Encouragement
                            if showingConversationPrompt && !conversationPrompts.isEmpty {
                                ConversationEncouragementView(
                                    prompts: conversationPrompts,
                                    onPromptSelected: { prompt in
                                        handleConversationPrompt(prompt)
                                    }
                                )
                                .id("conversation")
                            }
                            
                            // Post-Creation Options
                            if showingPostCreationOptions {
                                PostCreationOptionsView(
                                    onCreateMore: {
                                        handleCreateMoreLessons()
                                    },
                                    onReturnToSelection: {
                                        handleReturnToSelection()
                                    }
                                )
                                .id("postcreation")
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .onChange(of: chatMessages.count) { _ in
                        if let lastMessage = chatMessages.last {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isTyping) { _ in
                        if isTyping {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area (only show when appropriate)
                if conversationStage == .gatheringDetails || conversationStage == .completed {
                    VStack(spacing: 12) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack(spacing: 12) {
                            TextField("Share your thoughts or ask a question...", text: $userMessage)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: userMessage.isEmpty ? [.gray] : [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .disabled(userMessage.isEmpty)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(Color.black.opacity(0.3))
                }
            }
        }
        .onAppear {
            setupInitialMessage()
        }
    }
    
    // MARK: - Message Handling
    
    private func sendMessage() {
        guard !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let text = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        userMessage = ""
        
        // Add user message
        let userChatMessage = ChatMessage(role: .user, content: .text(text))
        chatMessages.append(userChatMessage)
        
        // Show typing indicator
        isTyping = true
        
        // Generate AI response
        Task {
            let response = await generateAIResponse(for: text)
            
            DispatchQueue.main.async {
                self.isTyping = false
                let aiChatMessage = ChatMessage(role: .assistant, content: .text(response))
                self.chatMessages.append(aiChatMessage)
            }
        }
    }
    
    private func generateAIResponse(for message: String) async -> String {
        // Add to conversation context
        conversationContext.append(message)
        viewModel.addChatDiscussion(message)
        
        // Handle based on conversation stage
        switch conversationStage {
        case .initial:
            return "This shouldn't happen - initial stage handled in setupInitialMessage"
        case .selectingTopicInterests:
            return "Please select one of the topic areas above to continue."
        case .selectingSpecificInterests:
            return "Please select your specific interests above and tap Continue."
        case .gatheringDetails:
            return await handleDetailGathering(message)
        case .generatingLessons:
            return "Creating your personalized lessons..."
        case .completed:
            return await handleCompletedConversation(message)
        }
    }
    
    // MARK: - Enhanced Conversation Handlers
    
    private func handleDetailGathering(_ message: String) async -> String {
        specificDetails = message
        conversationStage = .generatingLessons
        
        // Generate final lesson options based on the full conversation
        generateFinalLessonOptions()
        
        return "Excellent! Based on our conversation, I'm creating personalized lessons that match your specific interests. Here are the custom lessons I've designed for you:"
    }
    
    private func handleCompletedConversation(_ message: String) async -> String {
        // Generate more specific lessons or refinements
        return await EducationalTutorService.shared.generateEngagingResponse(
            for: message, 
            context: "Refining lessons for \(viewModel.topic) based on interests: \(selectedSpecificInterests.map { $0.title }.joined(separator: ", "))"
        )
    }
    
    // MARK: - Interactive Selection Handlers
    
    private func handleTopicPillSelection(_ pill: TopicPill) {
        selectedTopicPill = pill
        showingTopicPills = false
        
        // Handle "Suggest Your Own" differently
        if pill.title == "Suggest Your Own" {
            // Add user selection as message
            let userMessage = ChatMessage(role: .user, content: .text("I'd like to suggest my own area of interest"))
            chatMessages.append(userMessage)
            
            // Show AI response encouraging them to type their own interest
            let aiResponse = "Perfect! I love when learners have specific interests in mind. Please type what aspect of \(viewModel.topic) you're most curious about, and I'll create personalized options based on your input."
            let aiMessage = ChatMessage(role: .assistant, content: .text(aiResponse))
            chatMessages.append(aiMessage)
            
            // Switch to detail gathering stage so they can type
            conversationStage = .gatheringDetails
            return
        }
        
        // Handle normal pill selection
        // Add user selection as message
        let userMessage = ChatMessage(role: .user, content: .text(pill.title))
        chatMessages.append(userMessage)
        
        // Show typing and generate specific interests
        isTyping = true
        
        Task {
            let interests = await generateSpecificInterests(for: pill)
            let response = await EducationalTutorService.shared.generateEngagingResponse(
                for: pill.title,
                context: "User selected \(pill.title) for \(viewModel.topic)"
            )
            
            DispatchQueue.main.async {
                self.isTyping = false
                
                // Add AI response
                let aiMessage = ChatMessage(role: .assistant, content: .text(response))
                self.chatMessages.append(aiMessage)
                
                // Show specific interests selection
                self.specificInterests = interests
                self.showingSpecificInterests = true
                self.conversationStage = .selectingSpecificInterests
            }
        }
    }
    
    private func handleSpecificInterestsSelection() {
        selectedSpecificInterests = specificInterests.filter { $0.isSelected }
        showingSpecificInterests = false
        
        guard !selectedSpecificInterests.isEmpty else { return }
        
        // Add user selections as message
        let selections = selectedSpecificInterests.map { $0.title }.joined(separator: ", ")
        let userMessage = ChatMessage(role: .user, content: .text("Selected: \(selections)"))
        chatMessages.append(userMessage)
        
        // Show typing and go directly to lesson generation (skip the extra question)
        isTyping = true
        conversationStage = .generatingLessons
        
        Task {
            let response = "Excellent! Based on your selections, I'm creating personalized lessons that match your specific interests. Here are the custom lessons I've designed for you:"
            
            DispatchQueue.main.async {
                self.isTyping = false
                
                let aiMessage = ChatMessage(role: .assistant, content: .text(response))
                self.chatMessages.append(aiMessage)
                
                // Generate lessons directly
                self.generateFinalLessonOptions()
            }
        }
    }
    
    private func handleCustomInterestInput() {
        showingSpecificInterests = false
        conversationStage = .gatheringDetails
        
        // Add user message indicating they want to add custom interest
        let userMessage = ChatMessage(role: .user, content: .text("I'd like to add my own specific interest"))
        chatMessages.append(userMessage)
        
        // Add AI response encouraging them to type
        let aiResponse = "Perfect! Please tell me exactly what aspect of \(viewModel.topic) interests you most, and I'll create personalized lessons based on your input."
        let aiMessage = ChatMessage(role: .assistant, content: .text(aiResponse))
        chatMessages.append(aiMessage)
    }
    
    private func handleConversationPrompt(_ prompt: String) {
        // Add as user message and continue conversation
        let userMessage = ChatMessage(role: .user, content: .text(prompt))
        chatMessages.append(userMessage)
        
        sendMessage() // This will trigger the AI response
    }
    
    // MARK: - Content Generation
    
    private func generateFinalLessonOptions() {
        Task {
            // Use either detailed input or a summary of selected interests
            let detailsToUse = specificDetails.isEmpty ? 
                "User is interested in: \(selectedSpecificInterests.map { $0.title }.joined(separator: ", "))" : 
                specificDetails
            
            let lessons = await EducationalTutorService.shared.generatePersonalizedLessons(
                topic: viewModel.topic,
                interests: selectedSpecificInterests.map { $0.title },
                detailedInput: detailsToUse,
                conversationContext: conversationContext
            )
            
            DispatchQueue.main.async {
                self.finalLessonOptions = lessons
                self.showingFinalLessonOptions = true
                self.conversationStage = .completed
                
                // Also show conversation encouragement
                self.generateConversationPrompts()
            }
        }
    }
    
    private func generateConversationPrompts() {
        // Generate topic-specific conversation starters
        let prompts = generateConversationPromptsFor(topic: viewModel.topic, interests: selectedSpecificInterests)
        
        DispatchQueue.main.async {
            self.conversationPrompts = prompts
            self.showingConversationPrompt = true
        }
    }
    
    private func handleFinalLessonSelection() {
        guard !selectedLessonOptions.isEmpty else { return }
        
        showingFinalLessonOptions = false
        showingConversationPrompt = false
        
        // Create lessons for selected options
        for optionId in selectedLessonOptions {
            if let option = finalLessonOptions.first(where: { $0.id.uuidString == optionId }) {
                viewModel.addChatLesson(title: option.title, description: option.description)
            }
        }
        
        let count = selectedLessonOptions.count
        let response = "Perfect! I've created \(count) personalized lesson\(count > 1 ? "s" : "") based on our conversation. They now appear in your course selection with the 'AI Custom' badge."
        let aiMessage = ChatMessage(role: .assistant, content: .text(response))
        chatMessages.append(aiMessage)
        
        // Show post-creation options
        showPostLessonCreationOptions()
    }
    
    private func showPostLessonCreationOptions() {
        let optionsMessage = "What would you like to do next?"
        let optionsAIMessage = ChatMessage(role: .assistant, content: .text(optionsMessage))
        chatMessages.append(optionsAIMessage)
        
        showingPostCreationOptions = true
    }
    
    private func handleCreateMoreLessons() {
        showingPostCreationOptions = false
        
        // Reset to allow creating more lessons
        conversationStage = .selectingTopicInterests
        showingTopicPills = true
        
        let response = "Great! Let's create more personalized lessons. What other aspects of \(viewModel.topic) would you like to explore?"
        let aiMessage = ChatMessage(role: .assistant, content: .text(response))
        chatMessages.append(aiMessage)
    }
    
    private func handleReturnToSelection() {
        showingPostCreationOptions = false
        
        let response = "Perfect! You can now see your custom lessons in the course selection screen. Select the lessons you want and tap 'Continue' to build your course!"
        let aiMessage = ChatMessage(role: .assistant, content: .text(response))
        chatMessages.append(aiMessage)
        
        // Auto-dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupInitialMessage() {
        Task {
            let welcomeMessage = await EducationalTutorService.shared.generateInitialResponse(for: viewModel.topic)
            let pills = await generateTopicPills(for: viewModel.topic)
            
            DispatchQueue.main.async {
                let initialMessage = ChatMessage(role: .assistant, content: .text(welcomeMessage))
                self.chatMessages.append(initialMessage)
                
                // Show topic pills
                self.topicPills = pills
                self.showingTopicPills = true
                self.conversationStage = .selectingTopicInterests
            }
        }
    }
}

// MARK: - Content Generation Functions

extension ChatOverlayView {
    private func generateTopicPills(for topic: String) async -> [TopicPill] {
        // Use AI to generate fully dynamic topic pills with JSON structure
        let dynamicPills = await EducationalTutorService.shared.generateDynamicTopicPills(for: topic)
        
        // Always add a "Suggest Your Own" option at the end
        var pills = dynamicPills
        pills.append(TopicPill(title: "Suggest Your Own", icon: "💭", isSelected: false))
        
        return pills
    }
    
    private func generateSpecificInterests(for pill: TopicPill) async -> [SpecificInterest] {
        // Always use AI to generate fully dynamic, contextual interests
        let detailedInterests = await EducationalTutorService.shared.generateDetailedInterests(
            topic: viewModel.topic,
            category: pill.title
        )
        
        return detailedInterests.map { interest in
            SpecificInterest(
                title: interest.title,
                icon: interest.icon,
                description: interest.description
            )
        }
    }
    
    private func generateConversationPromptsFor(topic: String, interests: [SpecificInterest]) -> [String] {
        let topicLower = topic.lowercased()
        let interestTitles = interests.map { $0.title }.joined(separator: ", ")
        
        if topicLower.contains("physics") {
            return [
                "What level of math are you comfortable with for these topics?",
                "Are you more interested in theoretical concepts or practical applications?",
                "Do you prefer learning through visual demonstrations or equations?",
                "Any specific real-world scenarios you're curious about?",
                "Would you like to explore the history behind these discoveries?"
            ]
        } else if topicLower.contains("world war") {
            return [
                "Which specific battles or campaigns interest you most?",
                "Are you more interested in the European or Pacific theater?",
                "Do you want to focus on military tactics or broader historical impact?",
                "Any particular countries or leaders you'd like to study?",
                "Would you like to explore primary sources and firsthand accounts?"
            ]
        } else {
            return [
                "What specific aspects of \(interestTitles) fascinate you most?",
                "Are you looking for beginner-friendly or advanced content?",
                "Do you prefer learning through examples or theory?",
                "Any particular applications or use cases you're curious about?",
                "Would you like to explore current developments in this field?"
            ]
        }
    }
}

// MARK: - UI Components

struct FollowUpQuestionView: View {
    let question: FollowUpQuestion
    let onAnswerSelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.question)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            if question.allowsTextInput {
                // Text input for detailed responses
                VStack(spacing: 8) {
                    Text("Type your detailed response:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Share your thoughts...", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            // Handle text input submission
                        }
                }
            } else {
                // Multiple choice options
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                    ForEach(question.options, id: \.self) { option in
                        Button(action: {
                            onAnswerSelected(option)
                        }) {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

struct FinalLessonOptionsView: View {
    let options: [LessonOption]
    @Binding var selectedOptions: Set<String>
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Your Custom Lessons")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Select the lessons you'd like me to create for your course:")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(options) { option in
                    FinalLessonOptionRow(
                        option: option,
                        isSelected: selectedOptions.contains(option.id.uuidString),
                        onToggle: {
                            if selectedOptions.contains(option.id.uuidString) {
                                selectedOptions.remove(option.id.uuidString)
                            } else {
                                selectedOptions.insert(option.id.uuidString)
                            }
                        }
                    )
                }
            }
            
            if !selectedOptions.isEmpty {
                Button(action: onContinue) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create \(selectedOptions.count) Lesson\(selectedOptions.count > 1 ? "s" : "")")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

struct FinalLessonOptionRow: View {
    let option: LessonOption
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .cyan : .white.opacity(0.6))
                
                // Icon
                Text(option.icon)
                    .font(.title2)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(option.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.cyan.opacity(0.6) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                userMessageBubble
            } else {
                assistantMessageBubble
                Spacer()
            }
        }
    }
    
    private var userMessageBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            switch message.content {
            case .text(let text):
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .trailing)
            default:
                // Handle other content types if needed
                Text("Message")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .trailing)
            }
        }
    }
    
    private var assistantMessageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            switch message.content {
            case .text(let text):
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .leading)
            default:
                // Handle other content types if needed
                Text("Message")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .leading)
            }
        }
    }
}

struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                // Animated dots
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.cyan.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationPhase == index ? 1.4 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animationPhase
                            )
                    }
                }
                
                // Loading text with shimmer effect
                Text("AI is thinking...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50)
                            .offset(x: shimmerOffset)
                            .clipped()
                    )
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                        ) {
                            shimmerOffset = 200
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer()
        }
        .onAppear {
            animationPhase = 0
        }
    }
}

// MARK: - New Interactive UI Components

struct TopicPillsView: View {
    let pills: [TopicPill]
    let onPillSelected: (TopicPill) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What sparks your curiosity?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(pills) { pill in
                    Button(action: {
                        onPillSelected(pill)
                    }) {
                        HStack(spacing: 8) {
                            Text(pill.icon)
                                .font(.title2)
                            
                            Text(pill.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            // Add indicator for custom option
                            if pill.title == "Suggest Your Own" {
                                Image(systemName: "keyboard")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: pill.title == "Suggest Your Own" ? 
                                            [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)] :
                                            [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: pill.title == "Suggest Your Own" ? 
                                                    [Color.orange.opacity(0.6), Color.yellow.opacity(0.6)] :
                                                    [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SpecificInterestsView: View {
    @Binding var interests: [SpecificInterest]
    let onContinue: () -> Void
    let onCustomInput: () -> Void
    
    private var selectedCount: Int {
        interests.filter { $0.isSelected }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Your Specific Interests")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Select multiple areas that fascinate you most:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(interests.indices, id: \.self) { index in
                    SpecificInterestRow(
                        interest: $interests[index]
                    )
                }
                
                // Add "Suggest Your Own" option
                Button(action: onCustomInput) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        
                        Text("💭")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Suggest Your Own")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("Add your specific area")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "keyboard")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if selectedCount > 0 {
                Button(action: onContinue) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Continue with \(selectedCount) selection\(selectedCount > 1 ? "s" : "")")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cyan.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
        .animation(.spring(response: 0.3), value: selectedCount)
    }
}

struct SpecificInterestRow: View {
    @Binding var interest: SpecificInterest
    
    var body: some View {
        Button(action: {
            interest.isSelected.toggle()
        }) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: interest.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(interest.isSelected ? .cyan : .white.opacity(0.6))
                
                // Icon
                Text(interest.icon)
                    .font(.title2)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(interest.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(interest.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(interest.isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                interest.isSelected ? Color.cyan.opacity(0.6) : Color.white.opacity(0.2),
                                lineWidth: interest.isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2), value: interest.isSelected)
    }
}

struct PostCreationOptionsView: View {
    let onCreateMore: () -> Void
    let onReturnToSelection: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Button(action: onCreateMore) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.cyan)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create More Custom Lessons")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Continue our conversation to build more personalized lessons")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cyan.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onReturnToSelection) {
                    HStack(spacing: 12) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Return to Lesson Selection")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Go back to choose lessons and finalize your course")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ConversationEncouragementView: View {
    let prompts: [String]
    let onPromptSelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("💬")
                        .font(.title2)
                    Text("Keep Refining Your Lessons")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text("Want more specific lessons? Continue our conversation! Here are some ideas:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                ForEach(prompts, id: \.self) { prompt in
                    Button(action: {
                        onPromptSelected(prompt)
                    }) {
                        HStack {
                            Text("💭")
                                .font(.caption)
                            Text(prompt)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("The more specific you are, the better I can tailor your lessons!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .italic()
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ChatOverlayView(
        viewModel: EnhancedCourseChatViewModel(
            topic: "World War 2",
            difficulty: .beginner,
            pace: .balanced
        )
    )
} 