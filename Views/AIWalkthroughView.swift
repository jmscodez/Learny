import SwiftUI

struct AIWalkthroughView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasSeenAIWalkthrough") var hasSeenAIWalkthrough: Bool = false
    
    @State private var currentStep = 0
    private let steps: [WalkthroughStep] = [
        .init(
            title: "Lesson Suggestions",
            text: "The AI will suggest a list of lessons. You can tap to select or deselect them.",
            highlightPosition: .top
        ),
        .init(
            title: "Customize with Chat",
            text: "Use the chat bar to ask for new topics, suggest changes, or generate more ideas.",
            highlightPosition: .bottom
        ),
        .init(
            title: "Generate Your Course",
            text: "When you're happy with your lesson plan, tap here to finalize and save your course.",
            highlightPosition: .top
        )
    ]
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Allow tapping background to dismiss
                    dismissWalkthrough()
                }

            VStack {
                if steps[currentStep].highlightPosition == .top {
                    WalkthroughBubble(step: steps[currentStep], dismissAction: dismissWalkthrough, nextAction: nextStep)
                    Spacer()
                } else {
                    Spacer()
                    WalkthroughBubble(step: steps[currentStep], dismissAction: dismissWalkthrough, nextAction: nextStep)
                }
            }
            .padding(20)
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            dismissWalkthrough()
        }
    }
    
    private func dismissWalkthrough() {
        withAnimation {
            isPresented = false
        }
        hasSeenAIWalkthrough = true
    }
}

private struct WalkthroughStep {
    let title: String
    let text: String
    let highlightPosition: Position
    
    enum Position {
        case top, bottom
    }
}

private struct WalkthroughBubble: View {
    let step: WalkthroughStep
    let dismissAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(step.text)
                .font(.subheadline)
            
            HStack {
                Button(action: dismissAction) {
                    Text("Skip for good")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: nextAction) {
                    Text("Next")
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(16)
        .foregroundColor(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
} 