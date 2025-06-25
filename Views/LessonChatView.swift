import SwiftUI

struct LessonChatView: View {
    @StateObject private var viewModel: LessonChatViewModel
    @State private var isOverviewExpanded: Bool = false
    @State private var currentDialogueIndex = 0
    @State private var revealedMessages: Set<Int> = [0, 1] // Start with first 2 messages
    
    // Enhanced dialogue content for immersive learning
    private let dialogueContent = [
        DialogueMessage(
            speaker: "Professor Wilson",
            content: "Welcome to our exploration of World War I! I'm excited to guide you through one of history's most pivotal moments. Let me start by painting you a picture of Europe in 1914 - imagine a continent where ancient empires ruled vast territories, where royal families were interconnected through marriage, and where the industrial revolution had created both unprecedented prosperity and dangerous rivalries.",
            avatar: "person.circle.fill",
            color: .blue
        ),
        DialogueMessage(
            speaker: "Historical Narrator",
            content: "Picture this: In the summer of 1914, Europe was like a powder keg waiting to explode. Four great empires dominated the landscape - the German Empire under Kaiser Wilhelm II, the Austro-Hungarian Empire led by the elderly Franz Joseph, the Russian Empire under Tsar Nicholas II, and the Ottoman Empire stretching from Turkey to the Middle East. These weren't just countries; they were massive multinational entities with millions of subjects speaking dozens of languages.",
            avatar: "book.circle.fill",
            color: .green
        ),
        DialogueMessage(
            speaker: "Professor Wilson",
            content: "Now, here's where it gets fascinating. These empires weren't operating in isolation - they were bound together by a complex web of alliances that would prove to be both their strength and their downfall. On one side, you had the Triple Alliance: Germany, Austria-Hungary, and Italy, bound together since 1882. Think of them as the 'Central Powers' - they controlled the heart of Europe. On the other side was the Triple Entente: France, Russia, and Britain. These weren't formal allies at first, but a series of agreements had brought them together. France and Russia had been allies since 1894, and Britain had signed the Entente Cordiale with France in 1904, followed by an agreement with Russia in 1907.",
            avatar: "person.circle.fill",
            color: .blue
        ),
        DialogueMessage(
            speaker: "Diplomatic Expert",
            content: "The alliance system was supposed to maintain peace through balance of power - the idea being that if any nation attacked another, they'd face overwhelming opposition. But here's the tragic irony: this very system that was meant to prevent war would soon ensure that a local conflict would engulf the entire continent. It was like a series of dominos, perfectly arranged so that toppling one would bring down them all.",
            avatar: "globe.europe.africa.fill",
            color: .purple
        ),
        DialogueMessage(
            speaker: "Historical Narrator",
            content: "Beyond these formal alliances, Europe was seething with nationalism. The Austro-Hungarian Empire was particularly vulnerable - it was a patchwork of different ethnic groups, many of whom wanted independence. Slavs in the south looked to Serbia for leadership, while Serbian nationalists dreamed of a 'Greater Serbia' that would unite all South Slavs. This created a perfect storm in the volatile region of the Balkans.",
            avatar: "book.circle.fill",
            color: .green
        ),
        DialogueMessage(
            speaker: "Professor Wilson",
            content: "And then came June 28, 1914 - a date that would change everything. Archduke Franz Ferdinand, heir to the Austro-Hungarian throne, decided to visit Sarajevo, the capital of Bosnia-Herzegovina, which Austria-Hungary had annexed just six years earlier. The visit was meant to show Austrian strength, but for Serbian nationalists, it was the perfect opportunity to strike a blow for their cause.",
            avatar: "person.circle.fill",
            color: .blue
        )
    ]
    
    init(lesson: LessonSuggestion) {
        _viewModel = StateObject(wrappedValue: LessonChatViewModel(lesson: lesson))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),  // Dark navy
                        Color(red: 0.15, green: 0.1, blue: 0.25),  // Deep purple
                        Color(red: 0.1, green: 0.15, blue: 0.3)   // Dark blue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header
                    EnhancedHeader(
                        title: viewModel.lesson.title,
                        currentStep: revealedMessages.count,
                        totalSteps: dialogueContent.count
                    )
                    
                    // Main Content
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                // Lesson Overview Card
                                LessonOverviewCard(
                                    isExpanded: $isOverviewExpanded,
                                    lesson: viewModel.lesson,
                                    isLoading: viewModel.isLoadingDescription,
                                    overview: viewModel.lessonOverview
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                
                                // Dialogue Messages
                                ForEach(Array(dialogueContent.enumerated()), id: \.offset) { index, dialogue in
                                    if revealedMessages.contains(index) {
                                        DialogueBubbleView(
                                            dialogue: dialogue,
                                            index: index,
                                            screenWidth: geometry.size.width
                                        )
                                        .id("message_\(index)")
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                    }
                                }
                                
                                // Progress indicator
                                if revealedMessages.count < dialogueContent.count {
                                    ProgressIndicator(
                                        current: revealedMessages.count,
                                        total: dialogueContent.count
                                    )
                                    .padding(.top, 20)
                                }
                                
                                Spacer(minLength: 120)
                            }
                            .animation(.easeInOut(duration: 0.6), value: revealedMessages)
                        }
                        .onChange(of: revealedMessages.count) { _ in
                            // Auto-scroll to latest message
                            if let lastIndex = revealedMessages.max() {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    proxy.scrollTo("message_\(lastIndex)", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Bottom Action Area
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        bottomActionArea
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.3))
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load initial content if needed
            if viewModel.lessonOverview == nil && !viewModel.isLoadingDescription {
                // Trigger loading of lesson overview
            }
        }
    }
    
    private var bottomActionArea: some View {
        VStack(spacing: 12) {
            if revealedMessages.count < dialogueContent.count {
                // Continue Learning Button
                Button(action: revealNextMessage) {
                    HStack(spacing: 12) {
                        Text("Continue Learning")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .cyan.opacity(0.3), radius: 4)
                }
                .disabled(false)
                
                // Progress Text
                Text("\(revealedMessages.count) of \(dialogueContent.count) sections revealed")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            } else {
                // Lesson Complete Button
                Button(action: completeLesson) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        
                        Text("Complete Lesson")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .green.opacity(0.3), radius: 4)
                }
            }
        }
    }
    
    private func revealNextMessage() {
        let nextIndex = revealedMessages.count
        if nextIndex < dialogueContent.count {
            withAnimation(.easeInOut(duration: 0.6)) {
                revealedMessages.insert(nextIndex)
            }
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    private func completeLesson() {
        // Handle lesson completion
        print("Lesson completed!")
        // This could trigger navigation back to the lesson map or show completion UI
    }
}

// MARK: - Enhanced UI Components

// Using DialogueMessage from DialogueBubbleView.swift

private struct EnhancedHeader: View {
    let title: String
    let currentStep: Int
    let totalSteps: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                        .background(Color.black.opacity(0.3), in: Circle())
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text("Interactive Lesson")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.cyan)
                        .textCase(.uppercase)
                        .tracking(1)
                }
                
                Spacer()
                
                // Progress indicator
                VStack(spacing: 4) {
                    Text("\(currentStep)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("of \(totalSteps)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(width: 44)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(currentStep) / Double(totalSteps)), height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

private struct LessonOverviewCard: View {
    @Binding var isExpanded: Bool
    let lesson: LessonSuggestion
    let isLoading: Bool
    let overview: String?
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lesson Overview")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Tap to explore what you'll learn")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.cyan)
                }
                .padding(16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                                .scaleEffect(0.8)
                            
                            Text("Loading lesson overview...")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if let overview = overview {
                        Text(overview)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .padding()
                    } else {
                        Text(lesson.description)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .padding()
                    }
                }
                .background(Color.white.opacity(0.05))
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}



private struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < current ? Color.cyan : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index < current ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: current)
                }
            }
            
            Text("Learning Progress")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .tracking(1)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        LessonChatView(lesson: LessonSuggestion(title: "The Causes of World War I", description: "This lesson explores the complex web of alliances, imperial rivalries, and nationalist tensions that led to the outbreak of World War I, including the role of key figures and events such as the assassination of Archduke Franz Ferdinand."))
    }
    .preferredColorScheme(.dark)
} 