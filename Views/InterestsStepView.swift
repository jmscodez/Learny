//
//  InterestsStepView.swift
//  Learny
//

import SwiftUI

struct InterestsStepView: View {
    let topic: String
    @Binding var selectedInterests: [InterestArea]
    let onContinue: () -> Void
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                headerSection
                interestGrid
                
                Spacer(minLength: 40)
                continueButton
                selectionCounter
                Spacer(minLength: 60)
            }
        }
        .onAppear {
            if selectedInterests.isEmpty {
                selectedInterests = getInterestAreas(for: topic)
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("What interests you most?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaleEffect(animationProgress)
                .opacity(animationProgress)
            
            Text("Choose areas within **\(topic)** that you're most excited to explore")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(animationProgress)
        }
    }
    
    private var interestGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 16) {
            ForEach(Array(getInterestAreas(for: topic).enumerated()), id: \.element.id) { index, interest in
                InterestCard(
                    interest: binding(for: interest),
                    animationDelay: Double(index) * 0.05
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var continueButton: some View {
        if selectedInterests.contains(where: \.isSelected) {
            Button(action: onContinue) {
                HStack(spacing: 12) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
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
        if selectedInterests.contains(where: \.isSelected) {
            Text("\(selectedInterests.filter(\.isSelected).count) interests selected")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .transition(.opacity)
        }
    }
    
    private func binding(for interest: InterestArea) -> Binding<InterestArea> {
        guard let index = selectedInterests.firstIndex(where: { $0.id == interest.id }) else {
            return .constant(interest)
        }
        return $selectedInterests[index]
    }
    
    private func getInterestAreas(for topic: String) -> [InterestArea] {
        // Dynamic interest areas based on topic
        let topicLower = topic.lowercased()
        
        if topicLower.contains("finance") || topicLower.contains("money") || topicLower.contains("invest") {
            return [
                InterestArea(title: "Budgeting & Saving", icon: "dollarsign.circle.fill", color: .green),
                InterestArea(title: "Investment Basics", icon: "chart.line.uptrend.xyaxis.circle.fill", color: .blue),
                InterestArea(title: "Retirement Planning", icon: "clock.circle.fill", color: .orange),
                InterestArea(title: "Real Estate", icon: "house.circle.fill", color: .purple),
                InterestArea(title: "Tax Strategies", icon: "doc.text.fill", color: .red),
                InterestArea(title: "Credit & Debt", icon: "creditcard.circle.fill", color: .yellow),
                InterestArea(title: "Insurance", icon: "shield.fill", color: .cyan),
                InterestArea(title: "Side Hustles", icon: "briefcase.circle.fill", color: .mint)
            ]
        } else if topicLower.contains("program") || topicLower.contains("code") || topicLower.contains("software") {
            return [
                InterestArea(title: "Web Development", icon: "globe", color: .blue),
                InterestArea(title: "Mobile Apps", icon: "iphone", color: .green),
                InterestArea(title: "Data Science", icon: "chart.bar.fill", color: .purple),
                InterestArea(title: "AI & Machine Learning", icon: "brain.head.profile", color: .orange),
                InterestArea(title: "Game Development", icon: "gamecontroller.fill", color: .red),
                InterestArea(title: "Cybersecurity", icon: "lock.shield.fill", color: .cyan),
                InterestArea(title: "Cloud Computing", icon: "cloud.fill", color: .mint),
                InterestArea(title: "DevOps", icon: "gear", color: .yellow)
            ]
        } else if topicLower.contains("market") || topicLower.contains("business") {
            return [
                InterestArea(title: "Digital Marketing", icon: "megaphone.fill", color: .blue),
                InterestArea(title: "Content Creation", icon: "pencil.and.outline", color: .green),
                InterestArea(title: "Social Media", icon: "person.3.fill", color: .purple),
                InterestArea(title: "SEO & Analytics", icon: "magnifyingglass", color: .orange),
                InterestArea(title: "Email Marketing", icon: "envelope.fill", color: .red),
                InterestArea(title: "Brand Strategy", icon: "star.fill", color: .yellow),
                InterestArea(title: "E-commerce", icon: "cart.fill", color: .cyan),
                InterestArea(title: "Customer Psychology", icon: "brain.head.profile", color: .mint)
            ]
        } else {
            // Generic interests
            return [
                InterestArea(title: "Fundamentals", icon: "book.fill", color: .blue),
                InterestArea(title: "Practical Applications", icon: "wrench.and.screwdriver.fill", color: .green),
                InterestArea(title: "Advanced Concepts", icon: "graduationcap.fill", color: .purple),
                InterestArea(title: "Case Studies", icon: "doc.text.magnifyingglass", color: .orange),
                InterestArea(title: "Best Practices", icon: "checkmark.seal.fill", color: .red),
                InterestArea(title: "Tools & Resources", icon: "hammer.fill", color: .yellow),
                InterestArea(title: "Industry Trends", icon: "chart.line.uptrend.xyaxis", color: .cyan),
                InterestArea(title: "Expert Insights", icon: "lightbulb.fill", color: .mint)
            ]
        }
    }
}

struct InterestCard: View {
    @Binding var interest: InterestArea
    let animationDelay: Double
    
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                interest.isSelected.toggle()
            }
        }) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            interest.isSelected ?
                            interest.color :
                            interest.color.opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(interest.isSelected ? 1.1 : 1.0)
                    
                    Image(systemName: interest.icon)
                        .font(.title2)
                        .foregroundColor(
                            interest.isSelected ? .white : interest.color
                        )
                }
                .animation(.spring(), value: interest.isSelected)
                
                // Title
                Text(interest.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Selection indicator
                Image(systemName: interest.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(interest.isSelected ? interest.color : .white.opacity(0.3))
                    .scaleEffect(interest.isSelected ? 1.2 : 1.0)
                    .animation(.spring(), value: interest.isSelected)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        interest.isSelected ?
                        interest.color.opacity(0.1) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                interest.isSelected ?
                                interest.color.opacity(0.5) :
                                Color.white.opacity(0.2),
                                lineWidth: interest.isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(interest.isSelected ? 1.05 : 1.0)
            .shadow(
                color: interest.isSelected ? interest.color.opacity(0.3) : .clear,
                radius: interest.isSelected ? 8 : 0,
                y: interest.isSelected ? 4 : 0
            )
            .animation(.spring(), value: interest.isSelected)
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
    InterestsStepView(
        topic: "Personal Finance",
        selectedInterests: .constant([])
    ) {
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