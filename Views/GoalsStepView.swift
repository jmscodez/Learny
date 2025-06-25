//
//  GoalsStepView.swift
//  Learny
//

import SwiftUI

struct GoalsStepView: View {
    @Binding var selectedGoals: [LearningGoal]
    let onContinue: () -> Void
    
    @State private var animationProgress: Double = 0
    
    private let learningGoals = [
        LearningGoal(
            title: "Master the fundamentals",
            description: "Build a strong foundation with core concepts and principles",
            icon: "book.fill",
            color: .blue
        ),
        LearningGoal(
            title: "Develop practical skills",
            description: "Learn hands-on techniques you can apply immediately",
            icon: "wrench.and.screwdriver.fill",
            color: .green
        ),
        LearningGoal(
            title: "Advance my career",
            description: "Gain knowledge that will help me professionally",
            icon: "briefcase.fill",
            color: .orange
        ),
        LearningGoal(
            title: "Personal enrichment",
            description: "Learn for personal growth and satisfaction",
            icon: "heart.fill",
            color: .pink
        ),
        LearningGoal(
            title: "Stay current with trends",
            description: "Keep up with the latest developments in the field",
            icon: "chart.line.uptrend.xyaxis",
            color: .purple
        ),
        LearningGoal(
            title: "Problem-solving skills",
            description: "Develop critical thinking and analytical abilities",
            icon: "puzzlepiece.fill",
            color: .cyan
        ),
        LearningGoal(
            title: "Teaching others",
            description: "Learn so I can share knowledge with others",
            icon: "person.3.fill",
            color: .mint
        ),
        LearningGoal(
            title: "Start a new project",
            description: "Gain skills to launch something I'm passionate about",
            icon: "rocket.fill",
            color: .red
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                headerSection
                goalsGrid
                
                Spacer(minLength: 40)
                continueButton
                selectionCounter
                Spacer(minLength: 60)
            }
        }
        .onAppear {
            if selectedGoals.isEmpty {
                selectedGoals = learningGoals.map { goal in
                    LearningGoal(
                        title: goal.title,
                        description: goal.description,
                        icon: goal.icon,
                        color: goal.color
                    )
                }
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("What are your learning goals?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaleEffect(animationProgress)
                .opacity(animationProgress)
            
            Text("Select all that apply to personalize your learning journey")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(animationProgress)
        }
    }
    
    private var goalsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(Array(learningGoals.enumerated()), id: \.element.id) { index, goal in
                GoalCard(
                    goal: binding(for: goal),
                    animationDelay: Double(index) * 0.05
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var hasSelectedGoals: Bool {
        selectedGoals.contains(where: { goal in
            learningGoals.contains { $0.id == goal.id }
        })
    }
    
    private var selectedGoalsCount: Int {
        selectedGoals.filter { goal in 
            learningGoals.contains { $0.id == goal.id } 
        }.count
    }
    
    @ViewBuilder
    private var continueButton: some View {
        if hasSelectedGoals {
            Button(action: onContinue) {
                HStack(spacing: 12) {
                    Text("Create My Course")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "sparkles")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .purple.opacity(0.4), radius: 15, y: 8)
            }
            .scaleEffect(animationProgress)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private var selectionCounter: some View {
        if hasSelectedGoals {
            Text("\(selectedGoalsCount) goals selected")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .transition(.opacity)
        }
    }
    
    private func binding(for goal: LearningGoal) -> Binding<LearningGoal> {
        guard let index = selectedGoals.firstIndex(where: { $0.id == goal.id }) else {
            // Create a new goal if it doesn't exist
            let newGoal = LearningGoal(
                title: goal.title,
                description: goal.description,
                icon: goal.icon,
                color: goal.color
            )
            selectedGoals.append(newGoal)
            return Binding(
                get: { newGoal },
                set: { updatedGoal in
                    if let idx = selectedGoals.firstIndex(where: { $0.id == newGoal.id }) {
                        selectedGoals[idx] = updatedGoal
                    }
                }
            )
        }
        return $selectedGoals[index]
    }
}

// Extension to add selection state to LearningGoal
extension LearningGoal {
    var isSelected: Bool {
        // This will be managed by the parent view
        false
    }
}

struct GoalCard: View {
    @Binding var goal: LearningGoal
    let animationDelay: Double
    
    @State private var isSelected: Bool = false
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isSelected.toggle()
            }
        }) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            goal.color :
                            goal.color.opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                    
                    Image(systemName: goal.icon)
                        .font(.title2)
                        .foregroundColor(
                            isSelected ? .white : goal.color
                        )
                }
                .animation(.spring(), value: isSelected)
                
                // Content
                VStack(spacing: 8) {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(isSelected ? goal.color : .white.opacity(0.3))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(), value: isSelected)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        goal.color.opacity(0.1) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                goal.color.opacity(0.5) :
                                Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? goal.color.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0,
                y: isSelected ? 4 : 0
            )
            .animation(.spring(), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: animationOffset)
        .opacity(animationOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(animationDelay)) {
                animationOffset = 0
                animationOpacity = 1
            }
        }
    }
}

#Preview {
    GoalsStepView(selectedGoals: .constant([])) {
        print("Continue tapped")
    }
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.05, blue: 0.2),
                Color(red: 0.05, green: 0.1, blue: 0.3),
                Color(red: 0.08, green: 0.15, blue: 0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 