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

    var body: some View {
        VStack(spacing: 16) {
            Text("You scored \(score)/\(total)")
                .font(.title)
            if score >= total - 1 {
                Text("✅ Passed!").foregroundColor(.green)
            } else {
                Text("❌ Try Again").foregroundColor(.red)
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding()
    }
}
