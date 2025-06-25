//
//  TopicSelectionStepView.swift
//  Learny
//

import SwiftUI

struct TopicSelectionStepView: View {
    let topic: String
    @Binding var selectedTopics: [String]
    let onContinue: () -> Void
    
    @State private var availableTopics: [TopicItem] = []
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Text("What specific areas of")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(topic)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("would you like to cover?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select the topics that interest you most")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Topic checklist
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 1), spacing: 12) {
                    ForEach(availableTopics) { topicItem in
                        TopicChecklistItem(
                            topicItem: topicItem,
                            isSelected: selectedTopics.contains(topicItem.title)
                        ) {
                            toggleTopicSelection(topicItem.title)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Continue button
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: selectedTopics.isEmpty ? [.gray, .gray.opacity(0.8)] : [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: selectedTopics.isEmpty ? .clear : .purple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(selectedTopics.isEmpty)
            .padding(.horizontal)
        }
        .onAppear {
            generateTopicsForSubject()
        }
    }
    
    private func toggleTopicSelection(_ topic: String) {
        if selectedTopics.contains(topic) {
            selectedTopics.removeAll { $0 == topic }
        } else {
            selectedTopics.append(topic)
        }
    }
    
    private func generateTopicsForSubject() {
        // Generate dynamic topics based on the course subject
        let topics = getTopicsFor(subject: topic)
        availableTopics = topics.map { TopicItem(title: $0.title, description: $0.description, icon: $0.icon) }
    }
    
    private func getTopicsFor(subject: String) -> [(title: String, description: String, icon: String)] {
        let lowercaseSubject = subject.lowercased()
        
        if lowercaseSubject.contains("world war") || lowercaseSubject.contains("ww2") || lowercaseSubject.contains("wwii") {
            return [
                ("Causes and Origins", "Political tensions and events leading to war", "globe"),
                ("Major Battles", "Key military campaigns and turning points", "shield"),
                ("Key Figures", "Important leaders and personalities", "person.3"),
                ("Home Front", "Civilian life during wartime", "house"),
                ("Technology & Weapons", "Military innovations and equipment", "gear"),
                ("Holocaust", "Persecution and genocide", "heart.slash"),
                ("Pacific Theater", "War in Asia and the Pacific", "water.waves"),
                ("European Theater", "War in Europe and Africa", "mountain.2"),
                ("Aftermath", "Post-war consequences and rebuilding", "building.2")
            ]
        } else if lowercaseSubject.contains("programming") || lowercaseSubject.contains("coding") {
            return [
                ("Fundamentals", "Basic concepts and syntax", "book"),
                ("Data Structures", "Arrays, objects, and organization", "square.stack.3d.up"),
                ("Functions", "Reusable code blocks", "function"),
                ("Control Flow", "Loops, conditions, and logic", "arrow.triangle.branch"),
                ("Debugging", "Finding and fixing errors", "wrench.and.screwdriver"),
                ("Best Practices", "Writing clean, maintainable code", "checkmark.seal"),
                ("Projects", "Building real applications", "hammer"),
                ("Testing", "Ensuring code quality", "checkmark.circle")
            ]
        } else if lowercaseSubject.contains("science") {
            return [
                ("Scientific Method", "How science works", "flask"),
                ("Physics", "Matter, energy, and motion", "atom"),
                ("Chemistry", "Elements and reactions", "testtube.2"),
                ("Biology", "Life and living systems", "leaf"),
                ("Earth Science", "Our planet and environment", "globe"),
                ("Space", "Astronomy and the universe", "moon.stars"),
                ("Experiments", "Hands-on learning", "eyedropper"),
                ("Applications", "Science in daily life", "lightbulb")
            ]
        } else {
            // Generic topics for any subject
            return [
                ("Fundamentals", "Core concepts and principles", "book"),
                ("History", "Background and development", "clock"),
                ("Key Concepts", "Important ideas to understand", "lightbulb"),
                ("Practical Applications", "Real-world uses", "hammer"),
                ("Advanced Topics", "Deeper exploration", "mountain.2"),
                ("Current Trends", "Modern developments", "chart.line.uptrend.xyaxis")
            ]
        }
    }
}

struct TopicItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct TopicChecklistItem: View {
    let topicItem: TopicItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .blue : .white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                // Icon
                Image(systemName: topicItem.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.6))
                    .frame(width: 32)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(topicItem.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(topicItem.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .blue.opacity(0.3) : .white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TopicSelectionStepView(
        topic: "World War 2",
        selectedTopics: .constant(["Causes and Origins", "Major Battles"]),
        onContinue: {}
    )
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.15, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 