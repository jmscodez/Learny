import SwiftUI

struct LessonChatView: View {
    @StateObject private var viewModel: LessonChatViewModel
    @State private var isOverviewExpanded: Bool = true
    @State private var userInput: String = ""
    
    init(lesson: LessonSuggestion) {
        _viewModel = StateObject(wrappedValue: LessonChatViewModel(lesson: lesson))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                CustomHeader(title: viewModel.lesson.title)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DisclosureGroup(isExpanded: $isOverviewExpanded) {
                            if viewModel.isLoadingDescription {
                                ProgressView()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            } else if let overview = viewModel.lessonOverview {
                                Text(overview)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                                    .padding()
                            } else {
                                Text("Could not load overview.")
                                    .foregroundColor(.white)
                            }
                        } label: {
                            Text("Lesson Overview")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }
                        .padding(.horizontal)
                        .background(Color(white: 0.1))
                        .cornerRadius(12)
                        
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }

                InputBar(userInput: $userInput) {
                    viewModel.sendMessage(userInput)
                    userInput = ""
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - View Components
private struct CustomHeader: View {
    let title: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle).bold()
                .foregroundColor(.cyan)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            
            Spacer()
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

private struct InputBar: View {
    @Binding var userInput: String
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Ask a question...", text: $userInput, prompt: Text("Ask a question...").foregroundColor(.white.opacity(0.7)))
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(userInput.isEmpty ? .gray : .purple)
            }
            .disabled(userInput.isEmpty)
        }
        .padding()
        .background(Color(white: 0.05))
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                Image(systemName: "sparkle")
                    .font(.title)
                    .foregroundColor(.cyan)
                
                VStack(alignment: .leading, spacing: 10) {
                    switch message.content {
                    case .text(let text):
                        if let attributedString = try? AttributedString(markdown: text) {
                             Text(attributedString)
                        } else {
                             Text(text)
                        }
                    case .infoText(let text):
                        Text(text)
                            .foregroundColor(.white)
                    case .thinkingIndicator:
                        ThinkingIndicatorView()
                    case .errorMessage(let text):
                        Text("Error: \(text)")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            } else { // User
                Spacer()
                if case .text(let text) = message.content {
                    Text(text)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
            }
        }
        .tint(.cyan)
    }
}

private struct ThinkingIndicatorView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.2), value: scale)
            }
        }
        .foregroundColor(.white.opacity(0.5))
        .onAppear { scale = 0.5 }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        LessonChatView(lesson: LessonSuggestion(title: "The Causes of World War I", description: "This lesson explores the complex web of alliances, imperial rivalries, and nationalist tensions that led to the outbreak of World War I, including the role of key figures and events such as the assassination of Archduke Franz Ferdinand."))
    }
    .preferredColorScheme(.dark)
} 