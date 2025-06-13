import SwiftUI

struct MatchingGameView: View {
    let game: MatchingGame
    @State private var selectedLeft: String?
    @State private var matchedPairs: [String: String] = [:]
    @State private var incorrectAttempts: Set<String> = []

    // A simple layout for the matching game
    var body: some View {
        VStack {
            Text("Matching Game")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text("Match the pairs by tapping one item from each column.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)

            HStack(spacing: 20) {
                VStack(spacing: 10) {
                    ForEach(game.pairs) { pair in
                        Button(action: {
                            // TODO: Implement matching logic
                        }) {
                            Text(pair.term)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    ForEach(game.pairs) { pair in
                        Button(action: {
                            // TODO: Implement matching logic
                        }) {
                            Text(pair.definition)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
} 