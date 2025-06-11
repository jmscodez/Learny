import SwiftUI

struct TopicInputView: View {
    @EnvironmentObject private var stats: LearningStatsManager
    @StateObject private var vm = CourseChatSetupViewModel(stats: LearningStatsManager())
    @State private var showGuidedSetup = false
    @State private var showDocumentImport = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                Text("Pick any topic to learn")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 48)

                // Topic field
                TextField("e.g. World War II", text: $vm.topic)
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4))
                    )

                // Difficulty Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty Level")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        DifficultyPill(title: "Beginner", isSelected: vm.difficulty == .beginner) {
                            vm.difficulty = .beginner
                        }
                        DifficultyPill(title: "Intermediate", isSelected: vm.difficulty == .intermediate) {
                            vm.difficulty = .intermediate
                        }
                        DifficultyPill(title: "Advanced", isSelected: vm.difficulty == .advanced) {
                            vm.difficulty = .advanced
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    Text(difficultyDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(white: 0.12))
                .cornerRadius(20)

                // Pace Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Learning Pace")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        PacePill(title: "Quick Review", isSelected: vm.pace == .quickReview) {
                            vm.pace = .quickReview
                        }
                        PacePill(title: "Balanced", isSelected: vm.pace == .balanced) {
                            vm.pace = .balanced
                        }
                        PacePill(title: "Deep Dive", isSelected: vm.pace == .deepDive) {
                            vm.pace = .deepDive
                        }
                    }

                    Text(paceDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(white: 0.12))
                .cornerRadius(20)

                // Generate Button
                Button(action: {
                    Task { await vm.generateCourse() }
                }) {
                    Text(vm.isLoading ? "Generating…" : "Generate with AI")
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
                .disabled(vm.topic.isEmpty || vm.isLoading)
                .opacity(vm.topic.isEmpty ? 0.6 : 1.0)

                // OR separator
                HStack {
                    line
                    Text("OR")
                        .foregroundColor(.gray)
                    line
                }
                .padding(.horizontal, 24)

                // Guided Setup Button
                Button(action: {
                    showGuidedSetup = true
                }) {
                    Label("Guided Setup", systemImage: "arrow.right")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(16)
                }
                .sheet(isPresented: $showGuidedSetup) {
                    // TODO: replace with your GuidedSetupView
                    Text("Guided Setup Coming Soon")
                        .foregroundColor(.white)
                        .background(Color.black)
                }

                // Document Import
                Button(action: {
                    showDocumentImport = true
                }) {
                    Label("Create from Document", systemImage: "doc")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(16)
                }
                .sheet(isPresented: $showDocumentImport) {
                    // TODO: replace with DocumentImportView
                    Text("Document Import Coming Soon")
                        .foregroundColor(.white)
                        .background(Color.black)
                }

                Spacer(minLength: 48)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var difficultyDescription: String {
        switch vm.difficulty {
            case .beginner: return "Just starting out with basic concepts"
            case .intermediate: return "Building on foundational knowledge"
            case .advanced: return "Deep technical details and nuances"
        }
    }

    private var paceDescription: String {
        switch vm.pace {
            case .quickReview: return "Fast run-through of key points"
            case .balanced:   return "Standard pace with concepts & details"
            case .deepDive:   return "In-depth exploration of every topic"
        }
    }

    private var line: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.4))
    }
}

// Reusable pill buttons
private struct DifficultyPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.white : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .cornerRadius(12)
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
                .foregroundColor(isSelected ? .black : .white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.white : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .cornerRadius(12)
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
