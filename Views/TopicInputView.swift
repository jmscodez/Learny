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
        case .beginner: return "Great for new learners. Covers the basics."
        case .intermediate: return "Assumes some prior knowledge."
        case .advanced: return "For experts looking for a deep dive."
        }
    }
    
    private var paceDescription: String {
        switch pace {
        case .quickReview: return "A fast-paced overview of the key topics."
        case .balanced: return "A steady, comprehensive learning experience."
        case .deepDive: return "An in-depth, thorough exploration of the subject."
        }
    }
    
    var body: some View {
        NavigationStack(path: $navManager.path) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Create a New Course")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 48)
                        
                        TextField("", text: $topic, prompt: Text("e.g., The History of the NBA").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.bottom, 24)

                        // Grouped Choosers
                        VStack(spacing: 20) {
                            OptionGroupView(title: "Choose Difficulty") {
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
                                    .frame(height: 30, alignment: .top)
                            }
                            
                            OptionGroupView(title: "Choose Pace") {
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
                                    .frame(height: 30, alignment: .top)
                            }
                        }

                        Button(action: { showAIChat = true }) {
                            Label("Create with AI", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(topic.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(topic.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                        .fullScreenCover(isPresented: $showAIChat) {
                            CourseChatSetupView(topic: topic, difficulty: difficulty, pace: pace, isPresented: $showAIChat)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Learn")
            .navigationBarHidden(true)
            .navigationDestination(for: Course.self) { course in
                LessonMapView(course: course)
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
