//
//  QuizResultsView.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import SwiftUI

struct QuizResultsView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    let onContinue: () -> Void
    
    private var scorePercentage: Double {
        Double(correctAnswers) / Double(totalQuestions)
    }
    
    private var feedbackText: String {
        if scorePercentage == 1.0 {
            return "Perfect Score!"
        } else if scorePercentage >= 0.7 {
            return "Great Job!"
        } else {
            return "Good Effort!"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(feedbackText)
                .font(.largeTitle).bold()
            
            VStack {
                Text("You scored")
                    .font(.title2)
                Text("\(correctAnswers) / \(totalQuestions)")
                    .font(.system(size: 60, weight: .bold))
            }
            
            // Could add a more detailed breakdown here later
            
            Button(action: onContinue) {
                Text("Continue Learning")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(16)
            }
        }
        .padding()
    }
}

struct QuizResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            QuizResultsView(correctAnswers: 2, totalQuestions: 3, onContinue: {})
                .foregroundColor(.white)
        }
    }
}
