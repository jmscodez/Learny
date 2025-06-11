//
//  BadgeView.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import SwiftUI

struct BadgeView: View {
    let name: String
    let unlocked: Bool

    var body: some View {
        VStack {
            Image(systemName: unlocked ? "star.fill" : "star")
                .font(.largeTitle)
            Text(name)
                .font(.caption)
        }
        .padding()
    }
}
