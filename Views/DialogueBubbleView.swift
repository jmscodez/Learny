import SwiftUI

// DialogueMessage struct used by LessonChatView
struct DialogueMessage {
    let speaker: String
    let content: String
    let avatar: String
    let color: Color
}

struct DialogueBubbleView: View {
    let dialogue: DialogueMessage
    let index: Int
    let screenWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Speaker Header
            HStack(spacing: 12) {
                Image(systemName: dialogue.avatar)
                    .font(.system(size: 20))
                    .foregroundColor(dialogue.color)
                    .frame(width: 32, height: 32)
                    .background(dialogue.color.opacity(0.2), in: Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(dialogue.speaker)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(dialogue.color)
                    
                    Text("Section \(index + 1)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Spacer()
            }
            
            // Content
            Text(dialogue.content)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.95))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: screenWidth - 40, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(dialogue.color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// Legacy DialogueBubbleView for existing code that might still use DialogueLine from Activity.swift
struct LegacyDialogueBubbleView: View {
    let line: DialogueLine  // This now refers to the DialogueLine from Activity.swift
    let isCurrentUser: Bool // To alternate sides

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(line.speaker)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isCurrentUser ? .white : .gray)
                
                Text(line.text)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.5))
                    .cornerRadius(15)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
} 