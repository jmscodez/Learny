import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @EnvironmentObject private var generationManager: CourseGenerationManager

    var body: some View {
        TabView(selection: $selectedTab) {
            TopicInputView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Learn")
                }
                .tag(0)

            SavedCoursesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Courses")
                }
                .tag(1)

            ProgressView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Progress")
                }
                .tag(2)
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $generationManager.isGenerating) {
            GeneratingView()
        }
    }
}

// A new view for the generation process
private struct GeneratingView: View {
    @EnvironmentObject var generationManager: CourseGenerationManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(CourseGenerationManager())
    }
}
