import SwiftUI

struct TopicInputView: View {
    @EnvironmentObject var stats: LearningStatsManager
    @State private var topic: String = ""
    @State private var difficulty: Difficulty = .beginner
    @State private var pace: Pace = .balanced
    @State private var showGuidedSetup = false // For the placeholder sheet
    @State private var showAIChat = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Create a New Course")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 48)

                    // Topic field
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
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: { showAIChat = true }) {
                            Label("Create with AI", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(topic.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(topic.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                        .fullScreenCover(isPresented: $showAIChat) {
                            CourseChatSetupView(topic: topic)
                        }
                        
                        HStack {
                            line
                            Text("OR")
                                .foregroundColor(.gray)
                            line
                        }
                        
                        Button(action: { showGuidedSetup = true }) {
                            Label("Guided Setup", systemImage: "wand.and.stars")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal.opacity(0.8))
                                .cornerRadius(16)
                        }
                        .sheet(isPresented: $showGuidedSetup) {
                            VStack {
                                Text("Coming Soon!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("The Guided Setup will provide a step-by-step wizard to build your course.")
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                    }
                    .padding(.top)

                    Spacer(minLength: 48)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    private var difficultyDescription: String {
        switch difficulty {
        case .beginner:
            return "Assumes no prior knowledge. Perfect for starting out."
        case .intermediate:
            return "Builds on foundational concepts. For those with some experience."
        case .advanced:
            return "Dives into complex topics and nuances. For experts."
        }
    }
    
    private var paceDescription: String {
        switch pace {
        case .quickReview:
            return "A fast-paced overview focusing on key points."
        case .balanced:
            return "A standard pace covering concepts and details."
        case .deepDive:
            return "An in-depth exploration of the topic with extensive detail."
        }
    }

    private var line: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.4))
    }
}

struct OptionGroupView<Content: View>: View {
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
    static var previews: some View {
        TopicInputView()
            .environmentObject(LearningStatsManager())
            .preferredColorScheme(.dark)
    }
}
