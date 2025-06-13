import SwiftUI

// A view to generate and display course ideas from the AI
struct CourseIdeasView: View {
    @State private var ideas: [String] = []
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    let onIdeaSelected: (String) -> Void
    
    // In a real app, you'd inject these dependencies
    private let statsManager = LearningStatsManager()
    private let openAIService = OpenAIService.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
                
                if isLoading && ideas.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                } else {
                    VStack {
                        List(ideas, id: \.self) { idea in
                            Button(action: {
                                // Call the closure and dismiss the sheet
                                onIdeaSelected(idea)
                                dismiss()
                            }) {
                                Text(idea)
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                        }
                        .listStyle(.plain)
                        
                        Button(action: generateIdeas) {
                            Label("Get New Ideas", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Course Ideas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: generateIdeas)
        }
    }
    
    private func generateIdeas() {
        isLoading = true
        // TODO: Replace with a real call to OpenAI to generate course ideas
        // For now, we use a predefined list and simulate a network delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.ideas = [
                "The History of Jazz Music",
                "Introduction to Neural Networks",
                "The Art of Renaissance Painting",
                "Fundamentals of Landscape Photography",
                "Beginner's Guide to Beekeeping"
            ].shuffled()
            isLoading = false
        }
    }
}

struct CourseIdeasView_Previews: PreviewProvider {
    static var previews: some View {
        CourseIdeasView(onIdeaSelected: { _ in })
            .preferredColorScheme(.dark)
    }
} 