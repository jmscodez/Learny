import SwiftUI

struct MatchingGameView: View {
    let payload: MatchingGame
    @Binding var state: MatchingGameState
    let shuffledDefinitions: [MatchingPair]

    init(payload: MatchingGame, state: Binding<MatchingGameState>) {
        self.payload = payload
        self._state = state

        let hash = payload.id.hashValue
        let seed = hash == Int.min ? UInt64.max : UInt64(abs(hash))
        var generator = SeededRandomNumberGenerator(seed: seed)
        self.shuffledDefinitions = payload.pairs.shuffled(using: &generator)
    }

    var body: some View {
        VStack {
            Text("Matching Game").font(.title).bold()
            Text("Match the pairs by tapping one from each column.").font(.subheadline).foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer(minLength: 30)
            
            HStack(alignment: .top, spacing: 15) {
                // Terms Column
                VStack(spacing: 15) {
                    ForEach(payload.pairs) { pair in
                        Button(action: { state.selectedTermId = pair.id }) {
                            Text(pair.term)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(backgroundColorFor(id: pair.id, isTerm: true))
                                .cornerRadius(12)
                        }
                    }
                }
                
                // Definitions Column
                VStack(spacing: 15) {
                    // Use a consistent shuffled order
                    ForEach(shuffledDefinitions) { pair in
                        Button(action: { handleDefinitionSelection(definitionId: pair.id) }) {
                            Text(pair.definition)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(backgroundColorFor(id: pair.id, isTerm: false))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .foregroundColor(.white)
    }

    private func handleDefinitionSelection(definitionId: UUID) {
        guard let selectedTermId = state.selectedTermId else { return }
        
        let correctTerm = payload.pairs.first { $0.id == selectedTermId }
        
        // Check if the selected definition belongs to the selected term.
        if correctTerm?.id == definitionId {
            state.matchedPairs[selectedTermId] = definitionId
            state.selectedTermId = nil
        }
    }
    
    private func backgroundColorFor(id: UUID, isTerm: Bool) -> Color {
        if isTerm {
            if state.selectedTermId == id { return .blue.opacity(0.6) } // Highlight selected term
            if state.matchedPairs[id] != nil { return .green.opacity(0.4) } // Matched
        } else {
            if state.matchedPairs.values.contains(id) { return .green.opacity(0.4) } // Matched
        }
        return .gray.opacity(0.2) // Default
    }
}

// A simple deterministic RNG for stable shuffling
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// Add a shuffling method that uses a specific RNG
extension Array {
    func shuffled(using generator: inout SeededRandomNumberGenerator) -> [Element] {
        var copy = self
        for i in stride(from: copy.count - 1, through: 1, by: -1) {
            let j = Int(generator.next() % UInt64(i + 1))
            if i != j {
                copy.swapAt(i, j)
            }
        }
        return copy
    }
} 