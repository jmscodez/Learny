//
//  WelcomeStepView.swift
//  Learny
//

import SwiftUI

struct WelcomeStepView: View {
    let topic: String
    let onContinue: () -> Void
    
    @State private var animationOffset: CGFloat = 50
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer(minLength: 40)
                
                // Hero Section
                VStack(spacing: 24) {
                    // Animated AI Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(animationOpacity)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animationOpacity)
                    }
                    .shadow(color: .purple.opacity(0.3), radius: 20, y: 10)
                    
                    // Welcome Text
                    VStack(spacing: 16) {
                        Text("Welcome to AI Course Builder")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .offset(y: animationOffset)
                            .opacity(animationOpacity)
                        
                        Text("Let's create the perfect course on **\(topic)** just for you")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .offset(y: animationOffset)
                            .opacity(animationOpacity)
                    }
                }
                
                // Features Preview
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "person.crop.circle.badge.plus",
                        title: "Personalized Learning",
                        description: "Tailored to your experience and goals",
                        color: .blue,
                        delay: 0.2
                    )
                    
                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "AI-Powered Content",
                        description: "Intelligent lesson recommendations",
                        color: .purple,
                        delay: 0.4
                    )
                    
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Adaptive Pacing",
                        description: "Learn at your optimal speed",
                        color: .green,
                        delay: 0.6
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
                
                // Call to Action
                VStack(spacing: 16) {
                    Text("Ready to build your personalized learning journey?")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .offset(y: animationOffset)
                        .opacity(animationOpacity)
                    
                    Button(action: onContinue) {
                        HStack(spacing: 12) {
                            Text("Let's Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .purple.opacity(0.4), radius: 15, y: 8)
                    }
                    .scaleEffect(animationOpacity)
                    .offset(y: animationOffset)
                }
                .padding(.horizontal, 40)
                
                Spacer(minLength: 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationOffset = 0
                animationOpacity = 1
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .offset(x: animationOffset)
        .opacity(animationOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                animationOffset = 0
                animationOpacity = 1
            }
        }
    }
}

#Preview {
    WelcomeStepView(topic: "Personal Finance") {
        print("Continue tapped")
    }
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.05, blue: 0.2),
                Color(red: 0.05, green: 0.1, blue: 0.3),
                Color(red: 0.08, green: 0.15, blue: 0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 