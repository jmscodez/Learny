//
//  ChatCustomizationStepView.swift
//  Learny
//

import SwiftUI

struct CourseContext {
    let topic: String
    let difficulty: Difficulty
    let experience: String
    let timeCommitment: Int
    let selectedTopics: [String]
}

struct ChatCustomizationStepView: View {
    @Binding var course: Course
    let onFinalize: () -> Void
    
    @State private var messages: [ChatMessage] = []
    @State private var currentInput = ""
    @State private var isTyping = false
    @State private var conversationInsights: [String: Any] = [:]
    @State private var currentSuggestions: [String] = []
    @State private var showContinueButton = false
    @State private var conversationTurns = 0
    
    private var courseContext: CourseContext {
        CourseContext(
            topic: course.topic,
            difficulty: course.difficulty,
            experience: "Intermediate", // This should come from previous steps
            timeCommitment: 15, // This should come from previous steps
            selectedTopics: [] // This should come from previous steps
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Chat Messages
                chatMessagesView
                
                // Suggestions
                if !currentSuggestions.isEmpty {
                    suggestionsView
                }
                
                // Input Area with Continue/Skip
                inputAreaView
            }
        }
        .onAppear {
            initializeConversation()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Let's perfect your course")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Chat with our AI to customize your learning experience")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                    
                    // Typing indicator
                    if isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onChange(of: messages.count) { _ in
                withAnimation(.easeOut(duration: 0.5)) {
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: isTyping) { _ in
                if isTyping {
                    withAnimation(.easeOut(duration: 0.5)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var suggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(currentSuggestions, id: \.self) { suggestion in
                    Button(action: {
                        handleSuggestionTap(suggestion)
                    }) {
                        Text(suggestion)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
    
    private var inputAreaView: some View {
        VStack(spacing: 16) {
            // Chat input
            HStack(spacing: 12) {
                TextField("Share your thoughts or ask questions...", text: $currentInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(25)
                    .foregroundColor(.white)
                    .onSubmit {
                        if !currentInput.isEmpty {
                            sendMessage()
                        }
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: currentInput.isEmpty ? "mic.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentInput.isEmpty ? .white.opacity(0.6) : .blue)
                }
                .disabled(currentInput.isEmpty)
            }
            
            // Continue/Skip buttons
            HStack(spacing: 12) {
                // Skip button - always available
                Button(action: {
                    onFinalize()
                }) {
                    HStack {
                        Text("Skip Chat")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                }
                
                // Continue button - appears after some conversation
                if showContinueButton {
                    Button(action: onFinalize) {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    private func getMessageText(_ content: ChatMessage.ContentType) -> String {
        switch content {
        case .text(let text):
            return text
        default:
            return ""
        }
    }
    
    private func initializeConversation() {
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: .text("Hi! I'm excited to help you customize your \(course.topic) course! 🎯 What specific aspects are you most interested in learning about?")
        )
        
        messages.append(welcomeMessage)
        generateInitialSuggestions()
    }
    
    private func generateInitialSuggestions() {
        Task {
            let suggestions = await OpenAIService.shared.generateContextualSuggestions(
                conversationHistory: messages,
                courseContext: courseContext
            )
            
            await MainActor.run {
                currentSuggestions = suggestions
            }
        }
    }
    
    private func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            role: .user,
            content: .text(currentInput)
        )
        
        messages.append(userMessage)
        let messageToSend = currentInput
        currentInput = ""
        conversationTurns += 1
        
        // Show continue button after 2-3 exchanges
        if conversationTurns >= 2 {
            withAnimation(.spring()) {
                showContinueButton = true
            }
        }
        
        // Generate AI response
        Task {
            isTyping = true
            
            // Get AI response
            let aiResponse = await OpenAIService.shared.generateConversationalResponse(
                messages: messages,
                courseContext: courseContext
            )
            
            // Get new suggestions
            let newSuggestions = await OpenAIService.shared.generateContextualSuggestions(
                conversationHistory: messages,
                courseContext: courseContext
            )
            
            await MainActor.run {
                isTyping = false
                
                if let response = aiResponse {
                    let assistantMessage = ChatMessage(
                        role: .assistant,
                        content: .text(response)
                    )
                    messages.append(assistantMessage)
                }
                
                currentSuggestions = newSuggestions
            }
        }
    }
    
    private func handleSuggestionTap(_ suggestion: String) {
        currentInput = suggestion
        sendMessage()
    }
}

// MARK: - Supporting Views

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                userBubble
            } else {
                assistantBubble
                Spacer()
            }
        }
    }
    
    private var userBubble: some View {
        Text(getMessageText(message.content))
            .font(.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
    }
    
    private func getMessageText(_ content: ChatMessage.ContentType) -> String {
        switch content {
        case .text(let text):
            return text
        default:
            return ""
        }
    }
    
    private var assistantBubble: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI Avatar
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                )
            
            Text(getMessageText(message.content))
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
        }
    }
}

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI Avatar
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                )
            
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
            )
            
            Spacer()
        }
        .onAppear {
            withAnimation {
                animationPhase = 1
            }
        }
    }
}



#Preview {
    ChatCustomizationStepView(
        course: .constant(Course(
            id: UUID(),
            title: "World War 2", 
            topic: "World War 2",
            difficulty: .intermediate, 
            pace: .balanced,
            creationMethod: .aiAssistant,
            lessons: [],
            createdAt: Date()
        )),
        onFinalize: {}
    )
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.15, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 