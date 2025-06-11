//
//  QuizView.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import SwiftUI

struct QuizView: View {
    let questions: [QuizQuestion]
    @State private var answers: [Int?] = []

    var body: some View {
        VStack(spacing: 24) {
            ForEach(questions.indices, id: \.self) { idx in
                let q = questions[idx]
                VStack(alignment: .leading) {
                    Text(q.prompt).bold()
                    ForEach(q.options.indices, id: \.self) { opt in
                        Button {
                            answers[idx] = opt
                        } label: {
                            HStack {
                                Text(q.options[opt])
                                Spacer()
                                if answers[idx] == opt {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .onAppear {
                    if answers.isEmpty {
                        answers = Array(repeating: nil, count: questions.count)
                    }
                }
            }
            NavigationLink("Submit",
                           destination: QuizResultsView(
                               score: score,
                               total: questions.count)
            )
            .disabled(answers.contains(where: { $0 == nil }))
        }
        .padding()
    }

    private var score: Int {
        zip(questions, answers).reduce(0) { acc, pair in
            acc + ((pair.0.correctIndex == pair.1) ? 1 : 0)
        }
    }
}
