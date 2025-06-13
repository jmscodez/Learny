import SwiftUI

struct SelectableSuggestionView: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
    }
}

struct SelectableSuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableSuggestionView(text: "Key Eras in History", action: {})
            .padding()
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
} 