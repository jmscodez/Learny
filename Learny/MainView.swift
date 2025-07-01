import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var showCompletionBanner = false
    @State private var completedCourse: Course?
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
            // Remove blur effect so tabs remain fully accessible
            
            // Compact top banner for course generation
            if generationManager.isGenerating {
                VStack {
                    CompactGenerationBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: generationManager.isGenerating)
                    
                    Spacer()
                }
                .allowsHitTesting(false) // Allow taps to pass through to underlying content
            }
            
            // Course completion banner
            if showCompletionBanner, let course = completedCourse {
                VStack {
                    CourseCompletionBanner(course: course) {
                        // Navigate to courses tab and dismiss banner
                        selectedTab = 1
                        withAnimation(.spring()) {
                            showCompletionBanner = false
                        }
                    } onDismiss: {
                        withAnimation(.spring()) {
                            showCompletionBanner = false
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCompletionBanner)
                    
                    Spacer()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: generationManager.generatedCourse) { _, newCourse in
            // Show completion banner when course generation finishes
            if let course = newCourse, !generationManager.isGenerating {
                completedCourse = course
                withAnimation(.spring().delay(0.5)) {
                    showCompletionBanner = true
                }
                
                // Auto-dismiss after 10 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    if showCompletionBanner {
                        withAnimation(.spring()) {
                            showCompletionBanner = false
                        }
                    }
                }
            }
        }
    }
}

// Compact banner that appears at the top during course generation
private struct CompactGenerationBanner: View {
    @EnvironmentObject var generationManager: CourseGenerationManager
    @State private var rotationAngle = 0.0
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main banner content
            HStack(spacing: 16) {
                // Animated loading indicator
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotationAngle)
                }
                
                // Status text and progress
                VStack(alignment: .leading, spacing: 4) {
                    Text("Creating Your Course")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(generationManager.statusMessage)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Progress percentage
                Text("\(Int(generationManager.generationProgress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cyan)
                
                // Expand/collapse button
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 20, height: 20)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Expanded details section
            if isExpanded {
                VStack(spacing: 12) {
                    // Progress bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(Int(generationManager.generationProgress * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.cyan)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * generationManager.generationProgress, height: 4)
                                    .animation(.easeInOut(duration: 0.3), value: generationManager.generationProgress)
                            }
                        }
                        .frame(height: 4)
                    }
                    
                    // Current status with icon
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.cyan)
                        
                        Text(generationManager.statusMessage)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                    
                    // Navigation tip
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("You can browse other tabs while your course is being created")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(
                    Color(red: 0.08, green: 0.08, blue: 0.18)
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 0 : 16))
        .overlay(
            RoundedRectangle(cornerRadius: isExpanded ? 0 : 16)
                .stroke(
                    LinearGradient(
                        colors: [.cyan.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal, isExpanded ? 0 : 16)
        .padding(.top, 8)
                 .onAppear {
             rotationAngle = 360
         }
     }
}

// Course completion banner that appears when generation is finished
private struct CourseCompletionBanner: View {
    let course: Course
    let onViewCourse: () -> Void
    let onDismiss: () -> Void
    
    @State private var celebrationScale = 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            // Success icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(celebrationScale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: celebrationScale)
            }
            
            // Success message
            VStack(alignment: .leading, spacing: 4) {
                Text("🎉 Course Ready!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("'\(course.title)' has been created successfully")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                // View Course button
                Button(action: onViewCourse) {
                    Text("View")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
                
                // Dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.1),
                    Color(red: 0.15, green: 0.25, blue: 0.15)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.green.opacity(0.4), .mint.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear {
            celebrationScale = 1.2
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(CourseGenerationManager())
    }
}
