//
//  InterestsStepView.swift
//  Learny
//

import SwiftUI

struct InterestsStepView: View {
    let topic: String
    @Binding var selectedInterests: [InterestArea]
    @Binding var customDetails: String
    let onContinue: () -> Void
    
    @State private var animationProgress: Double = 0
    @State private var isLoadingInterests: Bool = false
    @State private var aiGeneratedInterests: [InterestArea] = []
    @State private var loadingProgress: Double = 0.0
    @State private var progressTimer: Timer?
    @State private var showInfoPopup: Bool = false
    @State private var loadingParticles: [LoadingParticle] = []
    @State private var loadingPulseAnimation = false
    @State private var loadingAnimationTrigger = false
    
    private var hasSelections: Bool {
        selectedInterests.contains(where: \.isSelected) || !customDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            // Show loading screen with full black background when loading
            if isLoadingInterests {
                Color.black
                    .ignoresSafeArea()
                
                loadingSection
            } else {
                // Main content when not loading
                VStack(spacing: 0) {
                    // Scrollable content area - starts directly with custom input
                    ScrollView {
                        VStack(spacing: 20) { // Increased spacing
                            // Minimal custom input section at the top
                            customDetailsSection
                                .padding(.top, 12) // Adjusted top padding
                            
                            // Divider section
                            dividerSection
                            
                            // Interest grid - gets maximum space
                            interestGrid
                            
                            // Add generous padding at bottom for floating continue button
                            Spacer(minLength: 140)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Floating continue button - always at bottom
                    VStack(spacing: 0) {
                        continueButton
                            .padding(.horizontal, 20)
                            .padding(.bottom, 34) // Safe area padding
                            .background(
                                // Ultra-light blur background only for readability
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            )
                    }
                }
            }
        }
        .overlay(
            // Info popup overlay
            Group {
                if showInfoPopup {
                    infoPopupOverlay
                }
            }
        )
        .onAppear {
            if selectedInterests.isEmpty {
                loadInterestAreas()
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
        .onDisappear {
            // Clean up timer
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("What interests you most?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaleEffect(animationProgress)
                .opacity(animationProgress)
            
            VStack(spacing: 6) {
                Text("Choose areas within")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                // Compact topic badge to save space for interest cards
                Text(topic)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                Text("that you're most excited to explore")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(animationProgress)
            

        }
    }
    
    private var loadingSection: some View {
        ZStack {
            // App's signature gradient background - full screen coverage
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.08, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Enhanced floating particles
            ForEach(Array(loadingParticles.enumerated()), id: \.offset) { index, particle in
                Group {
                    if index % 4 == 0 {
                        // Star particles
                        Image(systemName: "sparkle")
                            .font(.system(size: particle.size))
                            .foregroundColor(particle.color)
                            .opacity(particle.opacity)
                            .scaleEffect(particle.scale)
                            .position(particle.position)
                            .animation(
                                .easeInOut(duration: particle.duration)
                                .repeatForever(autoreverses: true)
                                .delay(particle.delay),
                                value: loadingAnimationTrigger
                            )
                    } else {
                        // Geometric particles
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        particle.color,
                                        particle.color.opacity(0.3)
                                    ]),
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: particle.size/2
                                )
                            )
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                            .opacity(particle.opacity)
                            .scaleEffect(particle.scale)
                            .animation(
                                .easeInOut(duration: particle.duration)
                                .repeatForever(autoreverses: true)
                                .delay(particle.delay),
                                value: loadingAnimationTrigger
                            )
                    }
                }
            }
            
            VStack(spacing: 32) {
                // Enhanced title section with sparkles
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow.opacity(0.9), .cyan.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .scaleEffect(loadingPulseAnimation ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: loadingPulseAnimation)
                        
                        Text("Generating personalized interests...")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .cyan, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .shadow(color: .cyan.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                    
                    // Topic badge
                    Text(topic)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .blue.opacity(0.4),
                                            .cyan.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.cyan.opacity(0.6), .blue.opacity(0.4)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                
                // Enhanced progress circle with glow effects
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                                        LinearGradient(
                            gradient: Gradient(colors: [
                                .cyan.opacity(0.6 - Double(index) * 0.15),
                                .blue.opacity(0.5 - Double(index) * 0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                                lineWidth: 3 - CGFloat(index)
                            )
                            .frame(width: 120 + CGFloat(index * 15), height: 120 + CGFloat(index * 15))
                            .scaleEffect(loadingPulseAnimation ? 1.05 + Double(index) * 0.02 : 1.0)
                            .animation(
                                .easeInOut(duration: 2.0 + Double(index) * 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: loadingPulseAnimation
                            )
                    }
                    
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 6)
                        .frame(width: 120, height: 120)
                    
                    // Progress circle with enhanced styling
                    Circle()
                        .trim(from: 0, to: loadingProgress)
                        .stroke(
                                                    LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.0, green: 0.8, blue: 1.0), location: 0),
                                .init(color: Color(red: 0.2, green: 0.6, blue: 1.0), location: 0.3),
                                .init(color: Color(red: 0.3, green: 0.5, blue: 1.0), location: 0.6),
                                .init(color: Color(red: 0.4, green: 0.4, blue: 1.0), location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.8), radius: 10, x: 0, y: 0)
                        .shadow(color: Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.6), radius: 6, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                    
                    // Percentage text with glow
                    Text("\(Int(loadingProgress * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, Color(red: 0.0, green: 0.8, blue: 1.0)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.8), radius: 6, x: 0, y: 2)
                        .contentTransition(.numericText())
                }
                
                // Enhanced subtitle
                VStack(spacing: 8) {
                    Text("We're analyzing **\(topic)** to find the most relevant areas for you")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Enhanced progress bar
                VStack(spacing: 12) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            // Progress fill with glow
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                                                    LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(red: 0.0, green: 0.8, blue: 1.0), location: 0),
                                        .init(color: Color(red: 0.2, green: 0.6, blue: 1.0), location: 0.5),
                                        .init(color: Color(red: 0.4, green: 0.4, blue: 1.0), location: 1.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                )
                                .frame(width: geometry.size.width * loadingProgress, height: 8)
                                .shadow(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.8), radius: 6, x: 0, y: 0)
                                .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                            
                            // Moving shimmer effect
                            if loadingProgress > 0 {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                .clear,
                                                .white.opacity(0.3),
                                                .clear
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 30, height: 8)
                                    .offset(x: (geometry.size.width * loadingProgress) - 15)
                                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false), value: loadingProgress)
                            }
                        }
                    }
                    .frame(height: 8)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                                                    .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.0, green: 0.8, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 1.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        
                        Text("Loading interests...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Enhanced skeleton cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        EnhancedLoadingInterestCard(index: index)
                            .opacity(loadingProgress > Double(index) * 0.15 ? 1.0 : 0.3)
                            .scaleEffect(loadingProgress > Double(index) * 0.15 ? 1.0 : 0.95)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .delay(Double(index) * 0.1),
                                value: loadingProgress
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            setupLoadingParticles()
            startLoadingAnimations()
        }
    }
    
    private var interestGrid: some View {
        VStack(spacing: 16) {
            // Show interest count and selection guidance
            if !selectedInterests.isEmpty {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.caption)
                            .foregroundColor(.cyan.opacity(0.8))
                        
                        Text("\(selectedInterests.count) AI-generated options")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if selectedInterests.contains(where: \.isSelected) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.8))
                            
                            Text("\(selectedInterests.filter(\.isSelected).count) selected")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green.opacity(0.8))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Show all interests in scrollable grid - displays 2 rows initially
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), 
                spacing: 16
            ) {
                ForEach(Array(selectedInterests.enumerated()), id: \.element.id) { index, interest in
                    InterestCard(
                        interest: binding(for: interest),
                        animationDelay: 0
                    )
                    .accessibilityLabel("Interest area: \(interest.title)")
                    .accessibilityHint("Double tap to select this interest area")
                }
            }
            
            // Add helpful selection tips
            if !selectedInterests.isEmpty && selectedInterests.filter(\.isSelected).count == 0 {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.7))
                        
                        Text("Tap cards above to select your interests")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                    }
                    
                    Text("💡 Select interest areas or write custom details above")
                        .font(.caption2)
                        .foregroundColor(.cyan.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.cyan.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var customDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            minimalTopicHeader
            minimalInputField
        }
    }
    
    private var minimalTopicHeader: some View {
        HStack {
            Text("Learning about")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Text(topic)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.cyan)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.cyan.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    private var minimalInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundColor(.cyan)
                
                Text("Tell us what you want to learn specifically")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showInfoPopup = true
                }) {
                    Image(systemName: "lightbulb.fill")
                        .font(.subheadline)
                        .foregroundColor(.yellow.opacity(0.8))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.yellow.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            
            TextField(getShortPlaceholder(), text: $customDetails, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .frame(minHeight: 120, maxHeight: 180) // Dynamic height with enough space
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(customDetails.isEmpty ? 0.08 : 0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    customDetails.isEmpty ? 
                                    Color.white.opacity(0.3) : 
                                    Color.cyan.opacity(0.6),
                                    lineWidth: customDetails.isEmpty ? 1 : 2
                                )
                        )
                )
                .foregroundColor(.white)
                .font(.callout) // Slightly smaller font to ensure it fits
                .lineSpacing(2) // Add some line spacing for readability
                .animation(.easeInOut(duration: 0.2), value: customDetails.isEmpty)
            
            // Helper text section below the input
            if customDetails.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb")
                            .font(.caption)
                            .foregroundColor(.yellow.opacity(0.7))
                        
                        Text("Tap 💡 for examples and tips")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text("More detail = better personalized lessons")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var customDetailsInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            customTextField
            customDetailsStatus
        }
    }
    
    private var customTextField: some View {
        TextField(getTopicSpecificPlaceholder(), text: $customDetails, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .padding(16)
            .background(customTextFieldBackground)
            .foregroundColor(.white)
            .font(.body)
            .lineLimit(4...8)
            .animation(.easeInOut(duration: 0.2), value: customDetails.isEmpty)
    }
    
    private var customTextFieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(customDetails.isEmpty ? 0.08 : 0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: customDetails.isEmpty ? 
                                [Color.white.opacity(0.3), Color.white.opacity(0.3)] :
                                [.cyan.opacity(0.8), .blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: customDetails.isEmpty ? 1 : 2
                    )
            )
    }
    
    private var customDetailsStatus: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: getInputStatusIcon())
                    .font(.caption)
                    .foregroundColor(getInputStatusColor())
                
                Text(getInputStatusText())
                    .font(.caption)
                    .foregroundColor(getInputStatusColor())
            }
            
            Spacer()
            
            if !customDetails.isEmpty {
                clearButton
            }
        }
    }
    
    private var clearButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                customDetails = ""
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                Text("Clear")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.red.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.red.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(.red.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    @ViewBuilder
    private var continueButton: some View {
        VStack(spacing: 12) {

            
            Button(action: onContinue) {
                HStack(spacing: 12) {
                    if isLoadingInterests {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        
                        Text("Loading interests...")
                            .font(.headline)
                            .fontWeight(.semibold)
                    } else {
                        if hasSelections {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Text(hasSelections ? "Continue to Next Step" : "Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if isLoadingInterests {
                            LinearGradient(
                                colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else if hasSelections {
                            LinearGradient(
                                colors: [.blue, .purple, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [.gray.opacity(0.6), .gray.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(16)
                .shadow(
                    color: hasSelections && !isLoadingInterests ? .purple.opacity(0.4) : .clear, 
                    radius: hasSelections ? 12 : 0, 
                    x: 0, 
                    y: hasSelections ? 6 : 0
                )
                .overlay(
                    // Enhanced shimmer effect when loading
                    isLoadingInterests ?
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: animationProgress)
                    : nil
                )
            }
            .disabled(!hasSelections || isLoadingInterests)
            .opacity((hasSelections && !isLoadingInterests) ? 1.0 : 0.7)
            .scaleEffect((hasSelections && !isLoadingInterests) ? 1.0 : 0.98)
            .animation(.easeInOut(duration: 0.2), value: hasSelections)
            .animation(.easeInOut(duration: 0.2), value: isLoadingInterests)
        }
    }
    
    private var dividerSection: some View {
        VStack(spacing: 16) {
            // Elegant divider with gradient
            HStack(spacing: 16) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.4), .white.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                
                Text("OR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars.inverse")
                        .font(.subheadline)
                        .foregroundColor(.purple.opacity(0.8))
                    
                    Text("Choose from AI-suggested interest areas")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text("Tap multiple areas that interest you most")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
        }
    }
    

    
    private func binding(for interest: InterestArea) -> Binding<InterestArea> {
        guard let index = selectedInterests.firstIndex(where: { $0.id == interest.id }) else {
            return .constant(interest)
        }
        return $selectedInterests[index]
    }
    
    // MARK: - Info Popup
    
    private var infoPopupOverlay: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showInfoPopup = false
                    }
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text("Learning Tips")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showInfoPopup = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Be specific to get personalized lessons:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        tipRow(icon: "📚", title: "Include specific topics", description: getTopicSpecificTip())
                        tipRow(icon: "⏱️", title: "Mention time periods", description: "e.g., 'Renaissance era' or 'modern developments'")
                        tipRow(icon: "👥", title: "Name key people", description: "e.g., 'Einstein's theories' or 'Shakespeare's impact'")
                        tipRow(icon: "🎯", title: "Focus areas", description: "What specific aspects interest you most?")
                    }
                    
                    Text("Examples for \(topic):")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.cyan)
                        .padding(.top, 8)
                    
                    Text(getTopicSpecificPlaceholder())
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cyan.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.6), .blue.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .padding(.horizontal, 20)
            .scaleEffect(showInfoPopup ? 1.0 : 0.8)
            .opacity(showInfoPopup ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showInfoPopup)
        }
    }
    
    private func tipRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
    
    private func getTopicSpecificTip() -> String {
        let topicLower = topic.lowercased()
        
        if topicLower.contains("art") || topicLower.contains("design") {
            return "artistic techniques, design principles, famous artists, color theory, composition"
        } else if topicLower.contains("finance") || topicLower.contains("financial") {
            return "financial instruments, market analysis, investment strategies, risk assessment"
        } else if topicLower.contains("history") || topicLower.contains("world") {
            return "wars, empires, revolutions, cultural movements"
        } else if topicLower.contains("programming") || topicLower.contains("coding") {
            return "languages, frameworks, design patterns, algorithms"
        } else if topicLower.contains("basketball") || topicLower.contains("nba") {
            return "players, strategies, business aspects, legendary games"
        } else if topicLower.contains("science") || topicLower.contains("physics") {
            return "theories, experiments, real-world applications, discoveries"
        } else {
            return "core concepts, key developments, practical applications"
        }
    }
    
    // MARK: - Enhanced Text Input Helpers
    
    private func getShortPlaceholder() -> String {
        return "Describe what you want to learn specifically..."
    }
    
    private func getTopicSpecificPlaceholder() -> String {
        let topicLower = topic.lowercased()
        
        if topicLower.contains("art") || topicLower.contains("design") {
            return "Example: I want to learn about Renaissance painting techniques, color theory fundamentals, digital illustration methods, composition principles, and how famous artists like Van Gogh created texture..."
        } else if topicLower.contains("finance") || topicLower.contains("financial") || topicLower.contains("money") || topicLower.contains("invest") {
            return "Example: I want to learn about portfolio diversification strategies, risk assessment techniques, financial statement analysis, cryptocurrency basics, and personal budgeting methods..."
        } else if topicLower.contains("history") || topicLower.contains("world") {
            return "Example: I want to learn about the causes of World War I, trench warfare tactics, how it changed European politics, and the role of propaganda..."
        } else if topicLower.contains("science") || topicLower.contains("physics") {
            return "Example: I want to understand Newton's laws of motion, how they apply to everyday situations, the math behind them, and their historical discovery..."
        } else if topicLower.contains("basketball") || topicLower.contains("nba") || topicLower.contains("lebron") {
            return "Example: I want to learn about LeBron's leadership evolution, his business empire, clutch performance statistics, and impact on social justice..."
        } else if topicLower.contains("football") || topicLower.contains("nfl") {
            return "Example: I want to understand offensive strategies, the evolution of the quarterback position, salary cap management, and playoff dynamics..."
        } else if topicLower.contains("math") || topicLower.contains("algebra") {
            return "Example: I want to master quadratic equations, understand their real-world applications, graphing techniques, and problem-solving strategies..."
        } else if topicLower.contains("programming") || topicLower.contains("coding") {
            return "Example: I want to learn object-oriented programming principles, design patterns, debugging techniques, and best practices for clean code..."
        } else if topicLower.contains("art") || topicLower.contains("painting") {
            return "Example: I want to explore Renaissance techniques, color theory, famous masterpieces, and the historical context of artistic movements..."
        } else if topicLower.contains("music") {
            return "Example: I want to understand music theory fundamentals, chord progressions, famous composers, and how to analyze different musical styles..."
        } else if topicLower.contains("literature") || topicLower.contains("writing") {
            return "Example: I want to analyze classic novels, understand literary devices, explore different writing styles, and learn about influential authors..."
        } else if topicLower.contains("business") || topicLower.contains("entrepreneur") {
            return "Example: I want to learn about startup strategies, market analysis, leadership principles, and successful business case studies..."
        } else {
            return "Example: I want to learn about specific aspects, key concepts, important people, historical context, and practical applications of \(topic)..."
        }
    }
    
    private func getInputStatusIcon() -> String {
        let wordCount = customDetails.split(separator: " ").count
        let charCount = customDetails.count
        
        if customDetails.isEmpty {
            return "pencil.circle"
        } else if wordCount < 5 || charCount < 20 {
            return "exclamationmark.triangle.fill"
        } else if wordCount >= 15 && charCount >= 80 {
            return "checkmark.circle.fill"
        } else {
            return "info.circle.fill"
        }
    }
    
    private func getInputStatusColor() -> Color {
        let wordCount = customDetails.split(separator: " ").count
        let charCount = customDetails.count
        
        if customDetails.isEmpty {
            return .white.opacity(0.5)
        } else if wordCount < 5 || charCount < 20 {
            return .orange.opacity(0.8)
        } else if wordCount >= 15 && charCount >= 80 {
            return .green.opacity(0.8)
        } else {
            return .cyan.opacity(0.8)
        }
    }
    
    private func getInputStatusText() -> String {
        let wordCount = customDetails.split(separator: " ").count
        let charCount = customDetails.count
        
        if customDetails.isEmpty {
            return "Start typing your specific learning goals"
        } else if wordCount < 5 || charCount < 20 {
            return "\(wordCount) words • Add more detail for better lessons"
        } else if wordCount >= 15 && charCount >= 80 {
            return "\(wordCount) words • Great detail! This will create excellent lessons"
        } else {
            return "\(wordCount) words • Good start, more detail = better lessons"
        }
    }
    
    private func loadInterestAreas() {
        print("📱 [UI DEBUG] Starting to load interests for topic: '\(topic)'")
        isLoadingInterests = true
        loadingProgress = 0.0
        
        // Start progress animation
        startProgressAnimation()
        
        Task {
            print("📱 [UI DEBUG] Calling AI service...")
            // Always try to get AI-generated interests first
            if let aiInterests = await OpenAIService.shared.generateTopicSpecificInterests(for: topic) {
                print("📱 [UI DEBUG] AI generated \(aiInterests.count) interests successfully")
                await MainActor.run {
                    // Complete progress animation
                    completeProgressAnimation {
                        selectedInterests = aiInterests
                        isLoadingInterests = false
                        print("📱 [UI DEBUG] Updated UI with AI interests")
                    }
                }
            } else {
                print("📱 [UI DEBUG] AI generation failed, using smart fallback")
                // Only use smart fallback if AI completely fails
                await MainActor.run {
                    completeProgressAnimation {
                        selectedInterests = getSmartInterestAreas(for: topic)
                        isLoadingInterests = false
                        print("📱 [UI DEBUG] Updated UI with smart fallback interests")
                    }
                }
            }
        }
    }
    
    private func startProgressAnimation() {
        progressTimer?.invalidate()
        loadingProgress = 0.0
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                if self.loadingProgress < 0.9 {
                    // Realistic progress with varying speeds
                    let increment = Double.random(in: 0.02...0.08)
                    self.loadingProgress = min(self.loadingProgress + increment, 0.9)
                } else {
                    // Slow down near the end
                    let increment = Double.random(in: 0.005...0.02)
                    self.loadingProgress = min(self.loadingProgress + increment, 0.95)
                }
            }
        }
    }
    
    private func completeProgressAnimation(completion: @escaping () -> Void) {
        progressTimer?.invalidate()
        progressTimer = nil
        
        // Animate to 100% then complete
        withAnimation(.easeInOut(duration: 0.5)) {
            loadingProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    private func getSmartInterestAreas(for topic: String) -> [InterestArea] {
        // Enhanced smart fallback that's more adaptive to any topic
        let topicLower = topic.lowercased()
        
        if topicLower.contains("finance") || topicLower.contains("money") || topicLower.contains("invest") {
            return [
                InterestArea(title: "Budgeting & Saving", icon: "dollarsign.circle.fill", color: .green),
                InterestArea(title: "Investment Strategies", icon: "chart.line.uptrend.xyaxis.circle.fill", color: .blue),
                InterestArea(title: "Retirement Planning", icon: "clock.circle.fill", color: .orange),
                InterestArea(title: "Real Estate", icon: "house.circle.fill", color: .purple),
                InterestArea(title: "Tax Optimization", icon: "doc.text.fill", color: .red),
                InterestArea(title: "Credit Management", icon: "creditcard.circle.fill", color: .yellow),
                InterestArea(title: "Insurance Planning", icon: "shield.fill", color: .cyan),
                InterestArea(title: "Wealth Building", icon: "briefcase.circle.fill", color: .mint)
            ]
        } else if topicLower.contains("physics") {
            return [
                InterestArea(title: "Mechanics & Motion", icon: "car.fill", color: .blue),
                InterestArea(title: "Energy & Forces", icon: "bolt.fill", color: .yellow),
                InterestArea(title: "Waves & Vibrations", icon: "waveform", color: .green),
                InterestArea(title: "Electricity & Magnetism", icon: "powerplug.fill", color: .purple),
                InterestArea(title: "Light & Optics", icon: "lightbulb.fill", color: .orange),
                InterestArea(title: "Thermodynamics", icon: "thermometer", color: .red),
                InterestArea(title: "Quantum Physics", icon: "atom", color: .cyan),
                InterestArea(title: "Applied Physics", icon: "gear", color: .mint)
            ]
        } else if topicLower.contains("program") || topicLower.contains("code") || topicLower.contains("software") {
            return [
                InterestArea(title: "Web Development", icon: "globe", color: .blue),
                InterestArea(title: "Mobile Apps", icon: "iphone", color: .green),
                InterestArea(title: "Data Science", icon: "chart.bar.fill", color: .purple),
                InterestArea(title: "AI & Machine Learning", icon: "brain.head.profile", color: .orange),
                InterestArea(title: "Game Development", icon: "gamecontroller.fill", color: .red),
                InterestArea(title: "Cybersecurity", icon: "lock.shield.fill", color: .cyan),
                InterestArea(title: "Cloud Computing", icon: "cloud.fill", color: .mint),
                InterestArea(title: "DevOps", icon: "gear", color: .yellow)
            ]
        } else if topicLower.contains("market") || topicLower.contains("business") {
            return [
                InterestArea(title: "Digital Marketing", icon: "megaphone.fill", color: .blue),
                InterestArea(title: "Content Creation", icon: "pencil.and.outline", color: .green),
                InterestArea(title: "Social Media", icon: "person.3.fill", color: .purple),
                InterestArea(title: "SEO & Analytics", icon: "magnifyingglass", color: .orange),
                InterestArea(title: "Email Marketing", icon: "envelope.fill", color: .red),
                InterestArea(title: "Brand Strategy", icon: "star.fill", color: .yellow),
                InterestArea(title: "E-commerce", icon: "cart.fill", color: .cyan),
                InterestArea(title: "Customer Psychology", icon: "brain.head.profile", color: .mint)
            ]
        } else if topicLower.contains("history") {
            return [
                InterestArea(title: "Ancient Civilizations", icon: "building.columns.fill", color: .brown),
                InterestArea(title: "Wars & Conflicts", icon: "shield.fill", color: .red),
                InterestArea(title: "Cultural Movements", icon: "person.3.fill", color: .purple),
                InterestArea(title: "Political Changes", icon: "flag.fill", color: .blue),
                InterestArea(title: "Scientific Revolution", icon: "flask.fill", color: .green),
                InterestArea(title: "Economic Systems", icon: "dollarsign.circle.fill", color: .yellow),
                InterestArea(title: "Social Progress", icon: "heart.fill", color: .pink),
                InterestArea(title: "Modern Era", icon: "globe", color: .cyan)
            ]
        } else if topicLower.contains("math") || topicLower.contains("calculus") || topicLower.contains("algebra") {
            return [
                InterestArea(title: "Basic Operations", icon: "plus.minus", color: .blue),
                InterestArea(title: "Equations & Functions", icon: "function", color: .green),
                InterestArea(title: "Geometry & Shapes", icon: "triangle.fill", color: .purple),
                InterestArea(title: "Statistics & Data", icon: "chart.bar.fill", color: .orange),
                InterestArea(title: "Problem Solving", icon: "puzzlepiece.fill", color: .red),
                InterestArea(title: "Real-World Math", icon: "calculator.fill", color: .yellow),
                InterestArea(title: "Advanced Concepts", icon: "infinity", color: .cyan),
                InterestArea(title: "Mathematical Proofs", icon: "checkmark.seal.fill", color: .mint)
            ]
        } else if topicLower.contains("soccer") || topicLower.contains("football") {
            return [
                InterestArea(title: "Ball Control & Dribbling", icon: "figure.soccer", color: .green),
                InterestArea(title: "Tactical Formations", icon: "rectangle.3.group", color: .blue),
                InterestArea(title: "Shooting Techniques", icon: "target", color: .red),
                InterestArea(title: "Defensive Strategies", icon: "shield.fill", color: .purple),
                InterestArea(title: "Famous Players", icon: "star.fill", color: .yellow),
                InterestArea(title: "World Cup History", icon: "globe", color: .orange),
                InterestArea(title: "Youth Development", icon: "figure.run", color: .cyan),
                InterestArea(title: "Fitness & Training", icon: "heart.fill", color: .pink)
            ]
        } else if topicLower.contains("nba") || topicLower.contains("basketball") {
            return [
                InterestArea(title: "Player Skills & Techniques", icon: "figure.basketball", color: .orange),
                InterestArea(title: "Team Strategies & Tactics", icon: "rectangle.3.group", color: .blue),
                InterestArea(title: "NBA History & Legends", icon: "star.fill", color: .yellow),
                InterestArea(title: "Championship Analysis", icon: "trophy.fill", color: .purple),
                InterestArea(title: "Player Development", icon: "figure.run", color: .green),
                InterestArea(title: "Game Rules & Officiating", icon: "checkmark.seal.fill", color: .red),
                InterestArea(title: "Draft & Trades", icon: "arrow.up.arrow.down", color: .cyan),
                InterestArea(title: "Advanced Statistics", icon: "chart.bar.fill", color: .mint)
            ]
        } else {
            // Smart generic fallback that adapts to any topic
            let cleanTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            return [
                InterestArea(title: "\(cleanTopic) Fundamentals", icon: "book.fill", color: .blue),
                InterestArea(title: "Practical \(cleanTopic)", icon: "wrench.and.screwdriver.fill", color: .green),
                InterestArea(title: "Advanced \(cleanTopic)", icon: "graduationcap.fill", color: .purple),
                InterestArea(title: "\(cleanTopic) Case Studies", icon: "doc.text.magnifyingglass", color: .orange),
                InterestArea(title: "Best Practices", icon: "checkmark.seal.fill", color: .red),
                InterestArea(title: "Tools & Methods", icon: "hammer.fill", color: .yellow),
                InterestArea(title: "Current Trends", icon: "chart.line.uptrend.xyaxis", color: .cyan),
                InterestArea(title: "Expert Insights", icon: "lightbulb.fill", color: .mint)
            ]
        }
    }
    
    // MARK: - Loading Animation Methods
    
    private func setupLoadingParticles() {
        loadingParticles = (0..<20).map { i in
            let particleColors: [Color] = [
                Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.6),
                Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5),
                Color(red: 0.4, green: 0.4, blue: 1.0).opacity(0.55),
                .white.opacity(0.3),
                Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.4)
            ]
            
            return LoadingParticle(
                id: i,
                position: CGPoint(
                    x: CGFloat.random(in: 30...350),
                    y: CGFloat.random(in: 100...700)
                ),
                color: particleColors.randomElement() ?? .cyan.opacity(0.3),
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.3...0.6),
                scale: Double.random(in: 0.8...1.2),
                duration: Double.random(in: 3.0...6.0),
                delay: Double.random(in: 0...3.0)
            )
        }
    }
    
    private func startLoadingAnimations() {
        loadingPulseAnimation = true
        loadingAnimationTrigger = true
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            for i in loadingParticles.indices {
                withAnimation(.linear(duration: loadingParticles[i].duration)) {
                    loadingParticles[i].position.x += CGFloat.random(in: -1...1)
                    loadingParticles[i].position.y += CGFloat.random(in: -1...1)
                    loadingParticles[i].scale = Double.random(in: 0.8...1.2)
                }
            }
        }
    }
}

struct InterestCard: View {
    @Binding var interest: InterestArea
    let animationDelay: Double
    
    // Helper function to get a valid SF Symbol icon with fallbacks
    private func getValidIcon() -> String {
        // First, try the suggested icon
        if isValidSFSymbol(interest.icon) {
            return interest.icon
        }
        
        // If invalid, try to map to a valid icon based on title keywords
        return getIconForTitle(interest.title)
    }
    
    // Separate function to break up the complex expression
    private func getIconForTitle(_ title: String) -> String {
        let lowercaseTitle = title.lowercased()
        
        // Check for ancient/historical topics
        if lowercaseTitle.contains("ancient") || lowercaseTitle.contains("mesopotamian") || lowercaseTitle.contains("civilization") {
            return "building.columns.fill"
        }
        
        // Check for war/military topics
        if lowercaseTitle.contains("war") || lowercaseTitle.contains("military") || lowercaseTitle.contains("conquest") || lowercaseTitle.contains("mongol") {
            return "shield.fill"
        }
        
        // Check for art/culture topics
        if lowercaseTitle.contains("renaissance") || lowercaseTitle.contains("humanist") || lowercaseTitle.contains("art") {
            return "paintbrush.fill"
        }
        
        // Check for colonial/empire topics
        if lowercaseTitle.contains("colonial") || lowercaseTitle.contains("africa") || lowercaseTitle.contains("empire") {
            return "globe.americas.fill"
        }
        
        // Check for political topics
        if lowercaseTitle.contains("revolution") || lowercaseTitle.contains("change") || lowercaseTitle.contains("political") {
            return "arrow.triangle.2.circlepath"
        }
        
        // Check for social topics
        if lowercaseTitle.contains("culture") || lowercaseTitle.contains("social") || lowercaseTitle.contains("movement") {
            return "person.3.fill"
        }
        
        // Check for economic topics
        if lowercaseTitle.contains("economic") || lowercaseTitle.contains("trade") || lowercaseTitle.contains("money") {
            return "dollarsign.circle.fill"
        }
        
        // Check for science topics
        if lowercaseTitle.contains("science") || lowercaseTitle.contains("technology") || lowercaseTitle.contains("innovation") {
            return "flask.fill"
        }
        
        // Check for religious topics
        if lowercaseTitle.contains("religion") || lowercaseTitle.contains("belief") || lowercaseTitle.contains("spiritual") {
            return "star.and.crescent.fill"
        }
        
        // Check for exploration topics
        if lowercaseTitle.contains("exploration") || lowercaseTitle.contains("discovery") || lowercaseTitle.contains("travel") {
            return "location.fill"
        }
        
        // Check for literature topics
        if lowercaseTitle.contains("literature") || lowercaseTitle.contains("writing") || lowercaseTitle.contains("book") {
            return "book.fill"
        }
        
        // Check for music topics
        if lowercaseTitle.contains("music") || lowercaseTitle.contains("sound") || lowercaseTitle.contains("audio") {
            return "music.note"
        }
        
        // Check for philosophy topics
        if lowercaseTitle.contains("philosophy") || lowercaseTitle.contains("thinking") || lowercaseTitle.contains("wisdom") {
            return "brain.head.profile"
        }
        
        // Check for food topics
        if lowercaseTitle.contains("food") || lowercaseTitle.contains("cuisine") || lowercaseTitle.contains("cooking") {
            return "fork.knife"
        }
        
        // Check for architecture topics
        if lowercaseTitle.contains("architecture") || lowercaseTitle.contains("building") || lowercaseTitle.contains("construction") {
            return "building.2.fill"
        }
        
        // Check for medical topics
        if lowercaseTitle.contains("medicine") || lowercaseTitle.contains("health") || lowercaseTitle.contains("healing") {
            return "cross.fill"
        }
        
        // Check for education topics
        if lowercaseTitle.contains("education") || lowercaseTitle.contains("learning") || lowercaseTitle.contains("school") {
            return "graduationcap.fill"
        }
        
        // Check for legal topics
        if lowercaseTitle.contains("law") || lowercaseTitle.contains("legal") || lowercaseTitle.contains("justice") {
            return "scale.3d"
        }
        
        // Check for nature topics
        if lowercaseTitle.contains("nature") || lowercaseTitle.contains("environment") || lowercaseTitle.contains("earth") {
            return "leaf.fill"
        }
        
        // Check for space topics
        if lowercaseTitle.contains("space") || lowercaseTitle.contains("astronomy") || lowercaseTitle.contains("cosmic") {
            return "moon.stars.fill"
        }
        
        // Final fallback - generic icons that always exist
        let fallbacks = ["circle.fill", "star.fill", "heart.fill", "book.fill", "lightbulb.fill", "flag.fill"]
        return fallbacks[abs(title.hash) % fallbacks.count]
    }
    
    // Helper function to check if an SF Symbol exists
    private func isValidSFSymbol(_ name: String) -> Bool {
        return UIImage(systemName: name) != nil
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                interest.isSelected.toggle()
            }
        }) {
            VStack(spacing: 16) {
                // Icon with fallback system
                ZStack {
                    Circle()
                        .fill(
                            interest.isSelected ?
                            interest.color :
                            interest.color.opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: getValidIcon())
                        .font(.title2)
                        .foregroundColor(
                            interest.isSelected ? .white : interest.color
                        )
                }
                
                // Title - Multi-line support
                Text(interest.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Selection indicator
                Image(systemName: interest.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(interest.isSelected ? interest.color : .white.opacity(0.3))
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        interest.isSelected ?
                        interest.color.opacity(0.1) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                interest.isSelected ?
                                interest.color.opacity(0.5) :
                                Color.white.opacity(0.2),
                                lineWidth: interest.isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(interest.isSelected ? 1.02 : 1.0)
            .shadow(
                color: interest.isSelected ? interest.color.opacity(0.2) : .clear,
                radius: interest.isSelected ? 4 : 0,
                y: interest.isSelected ? 2 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: interest.isSelected)
    }
}

#Preview {
    InterestsStepView(
        topic: "Personal Finance",
        selectedInterests: .constant([]),
        customDetails: .constant("")
    ) {
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

struct LoadingInterestCard: View {
    @State private var opacity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon placeholder
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 50, height: 50)
            
            // Title placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
                .frame(height: 16)
            
            // Selection indicator placeholder
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 16, height: 16)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                opacity = 0.7
            }
        }
    }
}

// MARK: - Loading Particle Model

struct LoadingParticle {
    let id: Int
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
    var scale: Double
    var duration: Double
    var delay: Double
}

struct EnhancedLoadingInterestCard: View {
    let index: Int
    @State private var shimmerPhase: CGFloat = 0
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Enhanced icon placeholder with blue glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .blue.opacity(0.2),
                                .cyan.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: ["brain.head.profile", "atom", "function", "graduationcap", "book", "lightbulb"].randomElement() ?? "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.6), .cyan.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: pulseAnimation
                    )
            }
            
            // Enhanced title placeholder with shimmer
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.1),
                                .blue.opacity(0.08)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 16)
                
                // Shimmer overlay
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.3),
                                .cyan.opacity(0.2),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 16)
                    .offset(x: shimmerPhase)
                    .clipped()
            }
            
            // Enhanced selection indicator with glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .blue.opacity(0.3),
                            .cyan.opacity(0.2),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0.5), .blue.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.4),
                    value: pulseAnimation
                )
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color.blue.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .cyan.opacity(0.3),
                                    .blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .blue.opacity(0.15), radius: 6, x: 0, y: 3)
        .onAppear {
            pulseAnimation = true
            startShimmerAnimation()
        }
    }
    
    private func startShimmerAnimation() {
        let screenWidth = UIScreen.main.bounds.width
        shimmerPhase = -screenWidth
        
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            shimmerPhase = screenWidth
        }
    }
} 
