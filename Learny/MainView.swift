import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @EnvironmentObject private var generationManager: CourseGenerationManager

    var body: some View {
        ZStack {
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
            .blur(radius: generationManager.isGenerating ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: generationManager.isGenerating)
            
            if generationManager.isGenerating {
                SubtleLoadingOverlay()
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .animation(.easeInOut(duration: 0.3), value: generationManager.isGenerating)
                    .allowsHitTesting(false) // Allow taps to pass through to underlying content
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Subtle loading overlay that appears over the current screen
private struct SubtleLoadingOverlay: View {
    @EnvironmentObject var generationManager: CourseGenerationManager
    @State private var rotationAngle = 0.0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Loading card
            VStack(spacing: 20) {
                // Animated loading indicator
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotationAngle)
                }
                
                VStack(spacing: 8) {
                    Text("Creating Your Course")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(generationManager.statusMessage)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Progress bar
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * generationManager.generationProgress, height: 4)
                                .cornerRadius(2)
                                .animation(.easeInOut(duration: 0.3), value: generationManager.generationProgress)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(Int(generationManager.generationProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Button("Cancel") {
                    generationManager.cancelGeneration()
                }
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            rotationAngle = 360
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(CourseGenerationManager())
    }
}
