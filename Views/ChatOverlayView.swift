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
    @State private var showingFollowUpOptions: Bool = false
    @State private var currentFollowUpOptions: [String] = []
    @State private var lastUserQuery: String = ""
    @Environment(\.dismiss) private var dismiss
    
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
                        
                        Text("Chat with AI to customize")
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
                            
                            // Multiple choice follow-up options
                            if showingFollowUpOptions && !currentFollowUpOptions.isEmpty {
                                FollowUpOptionsView(
                                    options: currentFollowUpOptions,
                                    onOptionSelected: { option in
                                        handleFollowUpSelection(option)
                                    }
                                )
                                .id("followup")
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
                
                // Input Area
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
        .onAppear {
            setupInitialMessage()
        }
    }
    
    private func setupInitialMessage() {
        let welcomeMessage = "Hi! I'm excited to help you customize your \(viewModel.topic) course! 🎯"
        let aiMessage = ChatMessage(role: .assistant, content: .text(welcomeMessage))
        chatMessages.append(aiMessage)
        
        // Add a follow-up with suggestions
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let suggestionMessage = "What specific aspects are you most interested in learning about?"
            let aiSuggestion = ChatMessage(role: .assistant, content: .text(suggestionMessage))
            chatMessages.append(aiSuggestion)
            
            // Add topic-specific quick options
            if viewModel.topic.lowercased().contains("eagles") || viewModel.topic.lowercased().contains("philadelphia") {
                currentFollowUpOptions = ["Howie Roseman's career", "Draft strategy", "Super Bowl championship", "Team management"]
                showingFollowUpOptions = true
            } else if viewModel.topic.lowercased().contains("mlb") || viewModel.topic.lowercased().contains("baseball") {
                currentFollowUpOptions = ["Steroid era", "Player statistics", "Team strategies", "Baseball history"]
                showingFollowUpOptions = true
            } else if viewModel.topic.lowercased().contains("finance") {
                currentFollowUpOptions = ["Budgeting basics", "Investment strategies", "Saving techniques", "Debt management"]
                showingFollowUpOptions = true
            } else {
                currentFollowUpOptions = ["Fundamentals", "Advanced topics", "Practical applications", "Real-world examples"]
                showingFollowUpOptions = true
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
        let topic = viewModel.topic.lowercased()
        
        // Add the discussion to the viewModel for lesson generation
        viewModel.addChatDiscussion(message)
        
        // Sports/MLB specific handling
        if topic.contains("mlb") || topic.contains("baseball") {
            if messageLower.contains("steroid") {
                viewModel.addChatLesson(
                    title: "The Steroid Era: Impact on Performance",
                    description: "Comprehensive analysis of how steroids affected player statistics, including home run rates, career longevity, and the lasting impact on baseball records."
                )
                viewModel.addChatLesson(
                    title: "Key Players in the Steroid Scandal",
                    description: "In-depth look at Barry Bonds, Mark McGwire, Sammy Sosa, and other players involved in steroid use, including their careers before and after allegations."
                )
                return "Perfect! I've added two specialized lessons about the steroid era: 'The Steroid Era: Impact on Performance' and 'Key Players in the Steroid Scandal'. These will appear in your course with a 💬 icon. Would you like me to add a lesson about the investigations and policy changes that followed?"
            } else if messageLower.contains("pitch") {
                viewModel.addChatLesson(
                    title: "The Art of Pitching: Types and Strategies",
                    description: "Examine the different types of pitches, including fastballs, curveballs, sliders, and changeups, along with strategic pitching approaches."
                )
                return "Great! I've added 'The Art of Pitching: Types and Strategies' to your course. You'll see it marked with 💬. Want to explore specific pitchers or batting strategies next?"
            } else if messageLower.contains("statistic") || messageLower.contains("analytics") {
                viewModel.addChatLesson(
                    title: "Advanced Baseball Analytics",
                    description: "Discover how sabermetrics and advanced statistics like WAR, OPS+, and FIP have revolutionized baseball analysis and player evaluation."
                )
                return "Excellent! I've added 'Advanced Baseball Analytics' covering sabermetrics and modern statistical analysis. Look for the 💬 icon! Are you interested in specific stats or historical vs modern analytics?"
            }
        }
        
        // Finance specific handling
        else if topic.contains("finance") || topic.contains("money") || topic.contains("budget") {
            if messageLower.contains("budget") || messageLower.contains("saving") {
                viewModel.addChatLesson(
                    title: "Zero-Based Budgeting Method",
                    description: "Learn how to allocate every dollar of income to specific categories, ensuring no money goes unaccounted for."
                )
                viewModel.addChatLesson(
                    title: "Emergency Fund Building Strategies",
                    description: "Practical steps to build and maintain an emergency fund that covers 3-6 months of expenses."
                )
                return "Perfect! I've added two new lessons: 'Zero-Based Budgeting Method' and 'Emergency Fund Building Strategies'. These will appear with a 💬 icon. Want to explore investment strategies or debt management next?"
            } else if messageLower.contains("invest") {
                viewModel.addChatLesson(
                    title: "Investment Portfolio Fundamentals",
                    description: "Learn about asset allocation, diversification, and building a balanced investment portfolio based on your risk tolerance and goals."
                )
                return "Great! I've added 'Investment Portfolio Fundamentals' to your course. You'll see it with a 💬 icon. Are you more interested in stocks, bonds, or alternative investments?"
            }
        }
        
        // Programming/Tech specific handling
        else if topic.contains("program") || topic.contains("code") || topic.contains("software") {
            if messageLower.contains("debug") || messageLower.contains("error") {
                viewModel.addChatLesson(
                    title: "Debugging Strategies and Tools",
                    description: "Master systematic approaches to finding and fixing bugs, including debugging tools, logging techniques, and problem-solving methodologies."
                )
                return "Excellent! I've added 'Debugging Strategies and Tools' covering systematic bug-finding approaches. Look for the 💬 icon! Want to explore specific debugging tools or testing strategies?"
            } else if messageLower.contains("algorithm") {
                viewModel.addChatLesson(
                    title: "Algorithm Design and Analysis",
                    description: "Learn to design efficient algorithms, analyze time and space complexity, and choose the right algorithmic approach for different problems."
                )
                return "Perfect! I've added 'Algorithm Design and Analysis' to your course. You'll see it marked with 💬. Are you interested in specific algorithm types or complexity analysis?"
            }
        }
        
        // Physics specific handling
        else if topic.contains("physics") {
            if messageLower.contains("quantum") {
                viewModel.addChatLesson(
                    title: "Quantum Mechanics Fundamentals",
                    description: "Explore the strange world of quantum physics, including wave-particle duality, superposition, and quantum entanglement with practical examples."
                )
                return "Fascinating! I've added 'Quantum Mechanics Fundamentals' covering wave-particle duality and quantum phenomena. Look for the 💬 icon! Want to dive into specific quantum experiments or applications?"
            } else if messageLower.contains("force") || messageLower.contains("motion") {
                viewModel.addChatLesson(
                    title: "Forces and Motion in Everyday Life",
                    description: "Understand Newton's laws through real-world examples, from car crashes to rocket launches, with practical physics applications."
                )
                return "Great! I've added 'Forces and Motion in Everyday Life' with practical physics examples. You'll see it with a 💬 icon. Are you more interested in specific forces or motion analysis?"
            }
        }
        
        // History specific handling
        else if topic.contains("history") || topic.contains("war") {
            if messageLower.contains("cause") || messageLower.contains("origin") {
                viewModel.addChatLesson(
                    title: "Historical Causes and Origins",
                    description: "Deep dive into the underlying causes, political tensions, and key events that led to this significant historical period."
                )
                return "Excellent! I've added 'Historical Causes and Origins' exploring the underlying factors and tensions. Look for the 💬 icon! Want to explore specific events or key figures next?"
            } else if messageLower.contains("impact") || messageLower.contains("consequence") {
                viewModel.addChatLesson(
                    title: "Long-term Historical Impact",
                    description: "Analyze the lasting consequences and how this period shaped modern society, politics, and culture."
                )
                return "Perfect! I've added 'Long-term Historical Impact' covering lasting consequences and modern relevance. You'll see it with a 💬 icon. Interested in specific impacts or comparative analysis?"
            }
        }
        
        // General handling for any topic
        else {
            // Extract key terms from the message to create a relevant lesson
            let messageWords = message.split(separator: " ").map { String($0).capitalized }
            let keyTerms = messageWords.prefix(3).joined(separator: " ")
            
            if !keyTerms.isEmpty {
                viewModel.addChatLesson(
                    title: "\(keyTerms) in \(viewModel.topic)",
                    description: "A specialized lesson covering \(keyTerms.lowercased()) within the context of \(viewModel.topic.lowercased()), based on our conversation and your specific interests."
                )
                return "Great question! I've created a custom lesson '\(keyTerms) in \(viewModel.topic)' based on our discussion. You'll see it in your course with a 💬 icon. Want to explore any related topics or dive deeper into specific aspects?"
            }
        }
        
        // Fallback for general questions
        return "That's an interesting point! I've noted your interest in this area. Feel free to ask about any specific aspects of \(viewModel.topic) you'd like to explore, and I'll create custom lessons based on our conversation. What would you like to learn more about?"
    }
    
    private func handleFollowUpSelection(_ option: String) {
        // Hide the options
        showingFollowUpOptions = false
        currentFollowUpOptions = []
        
        // Add user's selection as a message
        let userMessage = ChatMessage(role: .user, content: .text(option))
        chatMessages.append(userMessage)
        
        // Store for potential follow-up
        lastUserQuery = option
        
        // Handle action buttons (those with emojis and specific actions)
        if option.contains("✅") {
            // User is satisfied with current lessons, offer to continue or add more
            isTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isTyping = false
                let response = "Great! Your custom lessons have been added to your course selection below. You can continue building your course or ask me about other topics you'd like to explore."
                let aiResponse = ChatMessage(role: .assistant, content: .text(response))
                chatMessages.append(aiResponse)
                
                // Offer to add more lessons or finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentFollowUpOptions = [
                        "🎯 Add lessons on a different topic",
                        "🔄 Modify existing lessons", 
                        "✨ I'm happy with my course"
                    ]
                    showingFollowUpOptions = true
                }
            }
            return
        } else if option.contains("🏆") || option.contains("📈") || option.contains("🤝") || 
                 option.contains("🎯") || option.contains("⭐") || option.contains("📊") ||
                 option.contains("🏈") || option.contains("👥") || option.contains("⚖️") ||
                 option.contains("🏛️") || option.contains("📚") || option.contains("🔍") {
            
            // Handle specific action button requests
            handleActionButtonRequest(option)
            return
        }
        
        // Generate AI response with potential follow-up
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            
            let response = generateFollowUpResponse(for: option)
            let aiResponse = ChatMessage(role: .assistant, content: .text(response))
            chatMessages.append(aiResponse)
        }
    }
    
    private func handleActionButtonRequest(_ option: String) {
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            
            var responseText = ""
            let topic = viewModel.topic.lowercased()
            
            if option.contains("🏆") && topic.contains("eagles") {
                viewModel.addChatLesson(
                    title: "Super Bowl Strategy: X's and O's",
                    description: "Detailed breakdown of the strategic game plans, play-calling decisions, and tactical adjustments that led to Eagles' Super Bowl victory."
                )
                responseText = "Added 'Super Bowl Strategy: X's and O's' lesson! You'll see it with a 💬 icon in your course selection."
                
            } else if option.contains("📈") && topic.contains("eagles") {
                viewModel.addChatLesson(
                    title: "Salary Cap Management: The Roseman Way",
                    description: "Learn how Howie Roseman navigates NFL salary cap constraints, structures contracts, and manages long-term financial planning."
                )
                responseText = "Added 'Salary Cap Management: The Roseman Way' lesson! Look for the 💬 icon below."
                
            } else if option.contains("🤝") && topic.contains("eagles") {
                viewModel.addChatLesson(
                    title: "Blockbuster Trades & Key Signings",
                    description: "Analysis of Roseman's most impactful trades and free agent signings, including the strategies behind acquiring key players."
                )
                responseText = "Added 'Blockbuster Trades & Key Signings' lesson! You'll find it marked with 💬 in your course."
                
            } else if option.contains("⚖️") {
                viewModel.addChatLesson(
                    title: "MLB Steroid Investigations: The Mitchell Report",
                    description: "Comprehensive look at the investigations that exposed steroid use, including the Mitchell Report and its impact on baseball."
                )
                responseText = "Added 'MLB Steroid Investigations: The Mitchell Report' lesson! Check for the 💬 icon below."
                
            } else if option.contains("📊") {
                viewModel.addChatLesson(
                    title: "Statistical Analysis of the Steroid Era",
                    description: "Deep dive into how statistics changed during the steroid era, analyzing home run rates, player performance, and record validity."
                )
                responseText = "Added 'Statistical Analysis of the Steroid Era' lesson! You'll see it with a 💬 icon."
                
            } else {
                // Generic lesson creation for other action buttons
                let cleanOption = option.replacingOccurrences(of: "🎯 Add lesson about ", with: "")
                    .replacingOccurrences(of: "📚 Add more lessons on ", with: "")
                    .replacingOccurrences(of: "🔍 Explore ", with: "")
                
                viewModel.addChatLesson(
                    title: "\(cleanOption.capitalized) in \(viewModel.topic)",
                    description: "A specialized lesson covering \(cleanOption.lowercased()) based on our conversation and your specific interests."
                )
                responseText = "Added '\(cleanOption.capitalized) in \(viewModel.topic)' lesson! Look for the 💬 icon."
            }
            
            let aiResponse = ChatMessage(role: .assistant, content: .text(responseText))
            chatMessages.append(aiResponse)
            
            // Offer next steps
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentFollowUpOptions = [
                    "🎯 Add lessons on a different topic",
                    "📚 Add more lessons like this",
                    "✅ I'm satisfied with my lessons"
                ]
                showingFollowUpOptions = true
            }
        }
    }
    
    private func generateFollowUpResponse(for option: String) -> String {
        let optionLower = option.lowercased()
        let topic = viewModel.topic.lowercased()
        
        if topic.contains("eagles") || topic.contains("philadelphia") || topic.contains("nfl") {
            if optionLower.contains("howie") || optionLower.contains("roseman") {
                // Create specific lessons about Howie Roseman
                viewModel.addChatLesson(
                    title: "Howie Roseman's Draft Strategy",
                    description: "Analyze Roseman's approach to the NFL Draft, including his key picks like Carson Wentz, and how his draft philosophy has evolved over the years."
                )
                viewModel.addChatLesson(
                    title: "Building a Super Bowl Team: Roseman's Methods",
                    description: "Examine the strategic decisions, trades, and roster construction that led to the Eagles' Super Bowl LII victory under Roseman's leadership."
                )
                
                // Show action buttons for more interactivity
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentFollowUpOptions = [
                        "🏆 Add lesson about Super Bowl strategy",
                        "📈 Add lesson about salary cap management", 
                        "🤝 Add lesson about key trades & signings",
                        "✅ These lessons look good, continue"
                    ]
                    showingFollowUpOptions = true
                }
                
                return "Perfect! I've created two lessons about Howie Roseman that will appear in your course selection below with a 💬 chat icon. What else would you like to explore?"
                
            } else if optionLower.contains("draft") || optionLower.contains("pick") {
                viewModel.addChatLesson(
                    title: "Eagles Draft Analysis: Hit or Miss",
                    description: "Deep dive into the Eagles' draft history, analyzing successful picks, draft busts, and the evolution of their scouting approach."
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentFollowUpOptions = [
                        "🎯 Add lesson about specific draft classes",
                        "⭐ Add lesson about draft day trades",
                        "📊 Add lesson about draft evaluation metrics",
                        "✅ This lesson looks good, continue"
                    ]
                    showingFollowUpOptions = true
                }
                
                return "Great! I've added 'Eagles Draft Analysis: Hit or Miss' to your course. You'll see it marked with 💬 below. Want to explore more draft-related topics?"
                
            } else if optionLower.contains("super bowl") || optionLower.contains("championship") {
                viewModel.addChatLesson(
                    title: "Road to Super Bowl LII: Strategy & Execution",
                    description: "Comprehensive analysis of the Eagles' championship season, from roster construction to game-day execution that led to their first Super Bowl victory."
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentFollowUpOptions = [
                        "🏈 Add lesson about playoff game strategies",
                        "👥 Add lesson about key player contributions",
                        "🎯 Add lesson about coaching decisions",
                        "✅ This lesson looks good, continue"
                    ]
                    showingFollowUpOptions = true
                }
                
                return "Excellent! I've created 'Road to Super Bowl LII: Strategy & Execution' lesson. Look for it with the 💬 icon in your lesson selection. What aspect interests you most?"
            }
        }
        
        // Handle MLB/Baseball topics
        else if topic.contains("mlb") || topic.contains("baseball") {
            if optionLower.contains("steroid") {
                viewModel.addChatLesson(
                    title: "The Steroid Era: Impact on Performance",
                    description: "Comprehensive analysis of how steroids affected player statistics, including home run rates, career longevity, and the lasting impact on baseball records."
                )
                viewModel.addChatLesson(
                    title: "Key Players in the Steroid Scandal",
                    description: "In-depth look at Barry Bonds, Mark McGwire, Sammy Sosa, and other players involved in steroid use, including their careers before and after allegations."
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentFollowUpOptions = [
                        "⚖️ Add lesson about MLB investigations",
                        "📊 Add lesson about statistical analysis",
                        "🏛️ Add lesson about policy changes",
                        "✅ These lessons look good, continue"
                    ]
                    showingFollowUpOptions = true
                }
                
                return "Perfect! I've added two specialized lessons about the steroid era. You'll see them with 💬 icons in your lesson selection below. What would you like to explore next?"
            }
        }
        
        // Generic response with action buttons
        let words = option.split(separator: " ").map { String($0).capitalized }
        let keyTerms = words.prefix(2).joined(separator: " ")
        
        viewModel.addChatLesson(
            title: "\(keyTerms) in \(viewModel.topic)",
            description: "A specialized lesson focusing on \(keyTerms.lowercased()) within the context of \(viewModel.topic.lowercased()), tailored to your specific interests from our conversation."
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentFollowUpOptions = [
                "📚 Add more lessons on this topic",
                "🔍 Explore related concepts", 
                "📈 Add advanced version of this lesson",
                "✅ This lesson looks good, continue"
            ]
            showingFollowUpOptions = true
        }
        
        return "Great! I've created a custom lesson about \(keyTerms.lowercased()) that you'll see with a 💬 icon below. What would you like to do next?"
    }
    
    private func shouldOfferMoreOptions(for option: String) -> Bool {
        let optionLower = option.lowercased()
        return optionLower.contains("steroid") || optionLower.contains("statistic") || optionLower.contains("budget") || optionLower.contains("invest")
    }
    
    private func showFollowUpOptions(for option: String) {
        let optionLower = option.lowercased()
        
        if optionLower.contains("steroid") {
            currentFollowUpOptions = [
                "Impact on player performance",
                "Investigations and scandals", 
                "Policy changes and testing"
            ]
            showingFollowUpOptions = true
        } else if optionLower.contains("statistic") {
            currentFollowUpOptions = [
                "Traditional stats vs analytics",
                "Player evaluation metrics",
                "Team performance analysis"
            ]
            showingFollowUpOptions = true
        } else if optionLower.contains("budget") {
            currentFollowUpOptions = [
                "50/30/20 budgeting rule",
                "Emergency fund strategies",
                "Expense tracking methods"
            ]
            showingFollowUpOptions = true
        } else if optionLower.contains("invest") {
            currentFollowUpOptions = [
                "Risk tolerance assessment",
                "Diversification strategies",
                "Long-term vs short-term investing"
            ]
            showingFollowUpOptions = true
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
                                .fill(Color.white.opacity(0.1))
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
                    .fill(Color.white.opacity(0.1))
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

struct FollowUpOptionsView: View {
    let options: [String]
    let onOptionSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Choose an option:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        onOptionSelected(option)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text(option)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
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