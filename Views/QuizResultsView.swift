//
//  QuizResultsView.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import SwiftUI

struct QuizResultsView: View {
    let score: Int
    let total: Int
    var onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You scored")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("\(score) / \(total)")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(passsed ? .green : .red)
                
                Text(passsed ? "Excellent work! You've passed the quiz." : "Good try! Review the material and try again.")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    onDismiss()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Continue")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    private var passsed: Bool {
        total > 0 && Double(score) / Double(total) >= 0.8
    }
}

struct QuizResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuizResultsView(score: 4, total: 5, onDismiss: {})
        }
    }
}
