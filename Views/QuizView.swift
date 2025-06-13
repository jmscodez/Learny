//
//  QuizView.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//
 
import SwiftUI

// Update QuizView to take bindings and a closure
struct QuizView: View {
    let questions: [QuizQuestion]
    @Binding var userAnswers: [Int?]
    var onSubmit: () -> Void
    
    private var allQuestionsAnswered: Bool {
        !userAnswers.contains(nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quiz Time!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ForEach(questions.indices, id: \.self) { index in
                let question = questions[index]
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.prompt)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(question.options.indices, id: \.self) { optionIndex in
                        let option = question.options[optionIndex]
                        Button(action: {
                            userAnswers[index] = optionIndex
                        }) {
                            HStack {
                                Image(systemName: userAnswers[index] == optionIndex ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.blue)
                                Text(option)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(userAnswers[index] == optionIndex ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
            }

            Button(action: onSubmit) {
                Text("Submit")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(allQuestionsAnswered ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!allQuestionsAnswered)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}
