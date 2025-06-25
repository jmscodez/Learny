//
//  ChatCustomizationStepView.swift
//  Learny
//

import SwiftUI

struct ChatCustomizationStepView: View {
    @ObservedObject var viewModel: EnhancedCourseChatViewModel
    let onContinue: () -> Void
    
    @State private var currentMessage: String = ""
    @State private var isAITyping: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Customize Your Course")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Tell our AI assistant anything specific you'd like to focus on or any preferences you have")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            
            // Chat area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Initial AI message
                        if viewModel.chatMessages.isEmpty {
                            initialAIMessage
                        }
                        
                        // Chat messages
                        ForEach(viewModel.chatMessages) { message in
                            ChatMessageBubble(message: message)
                        }
                        
                        // AI typing indicator
                        if isAITyping {
                            HStack {
                                VStack {
                                    Image(systemName: "brain.head.profile")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .frame(width: 30, height: 30)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    Spacer()
                                }
                                
                                Text("AI is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.chatMessages.count) {
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            
            Spacer()
            
            // Input area
            VStack(spacing: 16) {
                // Quick suggestions
                if viewModel.chatMessages.isEmpty {
                    quickSuggestionsView
                }
                
                // Text input
                HStack(spacing: 12) {
                    TextField("Type your preferences...", text: $currentMessage, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.white)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(currentMessage.isEmpty ? .gray : .blue)
                    }
                    .disabled(currentMessage.isEmpty)
                }
                .padding(.horizontal)
                
                // Continue button
                Button(action: onContinue) {
                    HStack {
                        Text("Create My Course")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "sparkles")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .id("bottom")
    }
    
    private var initialAIMessage: some View {
        HStack {
            VStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Hi! I'm your AI course designer.")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Feel free to tell me anything specific you'd like to focus on, your learning style preferences, or any particular areas you want to emphasize. I'll tailor the course just for you!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("You can also skip this step if you're happy with the basics we've covered.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            Spacer()
        }
    }
    
    private var quickSuggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(quickSuggestions, id: \.self) { suggestion in
                    Button(action: {
                        currentMessage = suggestion
                        sendMessage()
                    }) {
                        Text(suggestion)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private let quickSuggestions = [
        "I'm a visual learner",
        "I prefer hands-on examples",
        "Keep it beginner-friendly",
        "Include real-world applications",
        "I learn better with stories",
        "Add interactive elements"
    ]
    
    private func sendMessage() {
        guard !currentMessage.isEmpty else { return }
        
        viewModel.addChatMessage(currentMessage)
        currentMessage = ""
        
        // Simulate AI response with typing indicator
        isAITyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAITyping = false
        }
    }
}



#Preview {
    ChatCustomizationStepView(
        viewModel: EnhancedCourseChatViewModel(topic: "World War 2", difficulty: .intermediate, pace: .balanced),
        onContinue: {}
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