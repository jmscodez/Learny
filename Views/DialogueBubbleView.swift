import SwiftUI

struct DialogueBubbleView: View {
    let line: DialogueLine
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