//
//  ChatOverlayView.swift
//  Learny
//

import SwiftUI

struct ChatOverlayView: View {
    @ObservedObject var viewModel: EnhancedCourseChatViewModel
    @State private var userMessage: String = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isTyping: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                chatHeaderView
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Initial AI greeting
                            if chatMessages.isEmpty {
                                initialGreetingView
                            }
                            
                            // Chat messages
                            ForEach(chatMessages) { message in
                                ChatMessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Typing indicator
                            if isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .onChange(of: chatMessages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: isTyping) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                
                // Input area
                chatInputView
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.05, blue: 0.2),
                        Color(red: 0.05, green: 0.1, blue: 0.3),
                        Color(red: 0.08, green: 0.15, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
        }
    }
    
    private var chatHeaderView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("AI Assistant")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Ask me about your course")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .frame(width: 44)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.2))
        }
        .background(.ultraThinMaterial)
    }
    
    private var initialGreetingView: some View {
        VStack(spacing: 20) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
            
            // Greeting message
            VStack(spacing: 12) {
                Text("Hi! I'm here to help you perfect your course.")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Ask me questions about:\n• Specific lesson topics\n• Difficulty adjustments\n• Additional content suggestions\n• Course structure recommendations")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Quick action buttons
            VStack(spacing: 12) {
                QuickActionButton(
                    text: "Add more lessons about budgeting",
                    icon: "plus.circle.fill"
                ) {
                    sendQuickMessage("Can you suggest more lessons about budgeting and saving strategies?")
                }
                
                QuickActionButton(
                    text: "Make lessons more practical",
                    icon: "wrench.and.screwdriver.fill"
                ) {
                    sendQuickMessage("Can you make the lessons more hands-on and practical?")
                }
                
                QuickActionButton(
                    text: "Adjust difficulty level",
                    icon: "slider.horizontal.3"
                ) {
                    sendQuickMessage("Can you adjust the difficulty level of the lessons?")
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
    
    private var chatInputView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 12) {
                TextField("Ask about your course...", text: $userMessage, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                    .lineLimit(1...4)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: userMessage.trimmingCharacters(in: .whitespaces).isEmpty ?
                                    [Color.gray.opacity(0.3)] : [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(
                            color: userMessage.trimmingCharacters(in: .whitespaces).isEmpty ?
                                .clear : .purple.opacity(0.3),
                            radius: 4
                        )
                }
                .disabled(userMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                if isTyping {
                    proxy.scrollTo("typing", anchor: .bottom)
                } else if let lastMessage = chatMessages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private func sendMessage() {
        let message = userMessage.trimmingCharacters(in: .whitespaces)
        guard !message.isEmpty else { return }
        
        userMessage = ""
        sendQuickMessage(message)
    }
    
    private func sendQuickMessage(_ text: String) {
        // Add user message
        let userChatMessage = ChatMessage(role: .user, content: .text(text))
        chatMessages.append(userChatMessage)
        
        // Show typing indicator
        isTyping = true
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            
            let aiResponse = generateAIResponse(for: text)
            let aiChatMessage = ChatMessage(role: .assistant, content: .text(aiResponse))
            chatMessages.append(aiChatMessage)
        }
    }
    
    private func generateAIResponse(for message: String) -> String {
        let messageLower = message.lowercased()
        
        if messageLower.contains("budget") || messageLower.contains("saving") {
            return "Great question! I can suggest additional lessons on budgeting fundamentals, expense tracking methods, and automated savings strategies. Would you like me to add specific lessons on creating a zero-based budget or emergency fund building?"
        } else if messageLower.contains("practical") || messageLower.contains("hands-on") {
            return "Absolutely! I can make the lessons more practical by adding real-world exercises, interactive calculators, and case studies. For example, we could include worksheets for creating actual budgets and tracking real expenses."
        } else if messageLower.contains("difficult") || messageLower.contains("level") {
            return "I can adjust the complexity level! Would you like me to make the content more beginner-friendly with simpler explanations, or would you prefer more advanced topics with deeper analysis and complex scenarios?"
        } else if messageLower.contains("time") || messageLower.contains("length") {
            return "I can help optimize the lesson timing! Would you like shorter, more focused lessons that are easier to fit into your schedule, or longer, comprehensive sessions that cover topics in greater depth?"
        } else {
            return "That's a great question! I can help you customize any aspect of your course. Feel free to ask about specific topics you'd like to add, difficulty adjustments, lesson structure, or any other preferences you have in mind."
        }
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                // Message content
                if case .text(let text) = message.content {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                
                // User message
                if case .text(let text) = message.content {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // User Avatar
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
        }
    }
}

struct QuickActionButton: View {
    let text: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TypingIndicatorView: View {
    @State private var animationPhase: Int = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            // Typing animation
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationPhase = 0
        }
    }
}

#Preview {
    ChatOverlayView(
        viewModel: EnhancedCourseChatViewModel(
            topic: "Personal Finance",
            difficulty: .beginner,
            pace: .balanced
        )
    )
} 