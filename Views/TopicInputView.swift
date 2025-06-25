import SwiftUI

struct TopicInputView: View {
    @EnvironmentObject private var generationManager: CourseGenerationManager
    @EnvironmentObject private var navManager: NavigationManager
    @EnvironmentObject private var statsManager: LearningStatsManager
    @EnvironmentObject private var notesManager: NotificationsManager
    
    @State private var topic: String = ""
    @State private var difficulty: Difficulty = .beginner
    @State private var pace: Pace = .balanced
    @State private var showAIChat = false

    private var difficultyDescription: String {
        switch difficulty {
        case .beginner: 
            return "🎯 Perfect for newcomers! Starts with fundamentals, uses simple language, includes lots of examples, and assumes no prior knowledge. Concepts are introduced step-by-step with plenty of context."
        case .intermediate: 
            return "⚡ Assumes basic familiarity with the topic. Moves at a moderate pace, introduces complex relationships between concepts, and includes some technical terminology. Great for building on existing knowledge."
        case .advanced: 
            return "🚀 For experts seeking deep understanding! Uses technical language, explores nuanced concepts, analyzes complex theories, and assumes strong foundational knowledge. Minimal hand-holding."
        }
    }
    
    private var paceDescription: String {
        switch pace {
        case .quickReview: 
            return "⚡ Fast-paced overview hitting the key highlights. Perfect for refreshing knowledge or getting familiar with main concepts quickly. Light on deep explanations."
        case .balanced: 
            return "🎯 Perfect middle ground! Thorough explanations with practical examples, interactive exercises, and time to absorb concepts. Most comprehensive learning experience."
        case .deepDive: 
            return "🔬 Comprehensive, in-depth exploration. Detailed analysis, multiple perspectives, extensive examples, and thorough coverage of subtopics. Maximum learning depth."
        }
    }
    
    private var customizationView: some View {
        VStack(spacing: 20) {
            Text("Customize Your Learning")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            OptionGroupView(title: "Difficulty Level") {
                HStack(spacing: 12) {
                    ForEach(Difficulty.allCases, id: \.self) { level in
                        DifficultyPill(title: level.rawValue.capitalized, isSelected: self.difficulty == level) {
                            self.difficulty = level
                        }
                    }
                }
                Text(difficultyDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(minHeight: 40, alignment: .top)
                    .multilineTextAlignment(.leading)
            }
            
            OptionGroupView(title: "Learning Pace") {
                HStack(spacing: 12) {
                    ForEach(Pace.allCases, id: \.self) { level in
                        PacePill(title: level.displayName, isSelected: self.pace == level) {
                            self.pace = level
                        }
                    }
                }
                Text(paceDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(minHeight: 40, alignment: .top)
                    .multilineTextAlignment(.leading)
            }
        }
        .transition(.opacity.combined(with: .slide))
        .animation(.easeInOut(duration: 0.3), value: topic.isEmpty)
    }
    
    var body: some View {
        NavigationStack(path: $navManager.path) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 32) {
                        Text("Create with AI")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 48)
                        
                        // Main topic input
                        VStack(spacing: 16) {
                            TextField("", text: $topic, prompt: Text("What would you like to learn about?").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            // Quick create button - main CTA
                            Button(action: { showAIChat = true }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                    Text("Create Course")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .disabled(topic.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(topic.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                        }
                        
                        // Advanced options - secondary
                        if !topic.isEmpty {
                            customizationView
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Learn")
            .navigationBarHidden(true)
            .navigationDestination(for: Course.self) { course in
                LessonMapView(course: course)
            }
            .fullScreenCover(isPresented: $showAIChat) {
                CourseChatSetupView(topic: topic, difficulty: difficulty, pace: pace, isPresented: $showAIChat)
            }
        }
        .onAppear(perform: notesManager.requestAuthorization)
        .onChange(of: generationManager.generatedCourse) { newCourse in
            if let course = newCourse {
                navManager.path.append(course)
                // The tab switch is no longer needed, navigation is handled directly.
                // selectedTab = 1 
            }
        }
    }
}

// This view has been moved to MainView to be presented as a full-screen cover.
/*
private struct GeneratingView: View {
    @EnvironmentObject var generationManager: CourseGenerationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Generating Your Course...")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            
            SwiftUI.ProgressView(value: generationManager.generationProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                .padding(.horizontal)
                .shadow(color: .purple.opacity(0.4), radius: 5)
            
            Text(generationManager.statusMessage)
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer().frame(height: 20)
            
            Button("Cancel", role: .destructive, action: generationManager.cancelGeneration)
                .buttonStyle(.bordered)
                .tint(.red)
        }
        .padding()
        .foregroundColor(.white)
    }
}
*/

private struct OptionGroupView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
            
            content
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

private struct DifficultyPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
    }
}

private struct PacePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
    }
}

struct TopicInputView_Previews: PreviewProvider {
    @State static var tab = 0
    static var previews: some View {
        TopicInputView()
            .environmentObject(CourseGenerationManager())
            .environmentObject(NavigationManager())
            .environmentObject(LearningStatsManager())
            .environmentObject(NotificationsManager())
            .preferredColorScheme(.dark)
    }
}
