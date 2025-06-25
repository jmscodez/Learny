import SwiftUI

struct StudyTimerView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    @Environment(\.dismiss) private var dismiss
    
    let course: Course
    @State private var selectedDuration: TimeInterval = 25 * 60 // 25 minutes default
    @State private var showCustomTimer = false
    @State private var customMinutes: Double = 25
    
    private let presetDurations: [TimeInterval] = [
        10 * 60,  // 10 minutes
        15 * 60,  // 15 minutes
        25 * 60,  // 25 minutes (Pomodoro)
        45 * 60,  // 45 minutes
        60 * 60   // 1 hour
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.08, blue: 0.16),
                        Color(red: 0.03, green: 0.05, blue: 0.12),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        StudyTimerHeader(course: course)
                        
                        // Current session or setup
                        if timerManager.currentSession != nil {
                            ActiveSessionView()
                                .environmentObject(timerManager)
                        } else {
                            SessionSetupView(
                                selectedDuration: $selectedDuration,
                                showCustomTimer: $showCustomTimer,
                                customMinutes: $customMinutes,
                                presetDurations: presetDurations,
                                course: course
                            )
                            .environmentObject(timerManager)
                        }
                        
                        // Today's stats
                        TodayStatsView()
                            .environmentObject(timerManager)
                        
                        // Focus tips
                        FocusTipsView()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Study Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Header
private struct StudyTimerHeader: View {
    let course: Course
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.blue)
            
            Text("Focus Session")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Study \(course.title)")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Active Session View
private struct ActiveSessionView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer display
            TimerDisplayView()
                .environmentObject(timerManager)
            
            // Focus level indicator
            FocusLevelView()
                .environmentObject(timerManager)
            
            // Timer controls
            TimerControlsView()
                .environmentObject(timerManager)
            
            // Motivational message
            MotivationalMessageView()
                .environmentObject(timerManager)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Timer Display
private struct TimerDisplayView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Main timer circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        timerState == .breakTime ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                
                // Time text
                VStack(spacing: 4) {
                    Text(timerManager.formattedTime(timerManager.timeRemaining))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text(stateText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            // Session type indicator
            if let session = timerManager.currentSession {
                HStack(spacing: 8) {
                    Image(systemName: sessionIcon(for: session.type))
                        .font(.system(size: 16, weight: .medium))
                    Text(sessionTypeText(for: session.type))
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.cyan)
            }
        }
    }
    
    private var progressValue: Double {
        guard timerManager.totalSessionTime > 0 else { return 0 }
        return 1.0 - (timerManager.timeRemaining / timerManager.totalSessionTime)
    }
    
    private var timerState: TimerState {
        timerManager.timerState
    }
    
    private var stateText: String {
        switch timerState {
        case .idle: return "Ready"
        case .running: return "Focus Time"
        case .paused: return "Paused"
        case .breakTime: return "Break Time"
        case .completed: return "Completed"
        }
    }
    
    private func sessionIcon(for type: StudySessionType) -> String {
        switch type {
        case .focused: return "target"
        case .review: return "book.fill"
        case .practice: return "pencil"
        case .exploration: return "magnifyingglass"
        }
    }
    
    private func sessionTypeText(for type: StudySessionType) -> String {
        switch type {
        case .focused: return "Focus Session"
        case .review: return "Review Session"
        case .practice: return "Practice Session"
        case .exploration: return "Exploration"
        }
    }
}

// MARK: - Focus Level View
private struct FocusLevelView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Focus Level")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(timerManager.focusLevel * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(focusColor)
            }
            
            // Focus level bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [focusColor.opacity(0.6), focusColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * timerManager.focusLevel, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: timerManager.focusLevel)
                }
            }
            .frame(height: 8)
            
            // Distraction count
            if timerManager.distractionCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(timerManager.distractionCount) distractions")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Spacer()
                }
            }
        }
    }
    
    private var focusColor: Color {
        if timerManager.focusLevel > 0.8 {
            return .green
        } else if timerManager.focusLevel > 0.5 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Timer Controls
private struct TimerControlsView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Pause/Resume button
            if timerManager.timerState == .running {
                Button(action: { timerManager.pauseSession() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Pause")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(16)
                }
            } else if timerManager.timerState == .paused {
                Button(action: { timerManager.resumeSession() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Resume")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
            }
            
            // End session button
            Button(action: { timerManager.endSession(completed: false) }) {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("End")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - Session Setup View
private struct SessionSetupView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    @Binding var selectedDuration: TimeInterval
    @Binding var showCustomTimer: Bool
    @Binding var customMinutes: Double
    let presetDurations: [TimeInterval]
    let course: Course
    
    var body: some View {
        VStack(spacing: 24) {
            // Duration selection
            VStack(spacing: 16) {
                Text("Choose Session Duration")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(presetDurations, id: \.self) { duration in
                        DurationCard(
                            duration: duration,
                            isSelected: selectedDuration == duration,
                            onTap: { selectedDuration = duration }
                        )
                    }
                    
                    // Custom duration card
                    Button(action: { showCustomTimer = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.purple)
                            Text("Custom")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.purple.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            
            // Session type selection
            VStack(spacing: 16) {
                Text("Session Type")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    SessionTypeCard(
                        title: "Focus",
                        description: "Deep learning session",
                        icon: "target",
                        color: .blue,
                        action: { startFocusSession() }
                    )
                    
                    SessionTypeCard(
                        title: "Review",
                        description: "Quick review session",
                        icon: "book.fill",
                        color: .green,
                        action: { startReviewSession() }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showCustomTimer) {
            CustomTimerSheet(customMinutes: $customMinutes, selectedDuration: $selectedDuration)
        }
    }
    
    private func startFocusSession() {
        timerManager.startFocusSession(
            courseId: course.id,
            duration: selectedDuration
        )
    }
    
    private func startReviewSession() {
        timerManager.startReviewSession(duration: selectedDuration)
        timerManager.currentSession?.courseId = course.id
    }
}

// MARK: - Support Views
private struct DurationCard: View {
    let duration: TimeInterval
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(formatDuration(duration))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSelected ? .blue : .white)
                
                Text("minutes")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.blue : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes)"
    }
}

private struct SessionTypeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

private struct MotivationalMessageView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    
    var body: some View {
        Text(timerManager.motivationalMessage)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.cyan)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cyan.opacity(0.1))
            )
    }
}

private struct TodayStatsView: View {
    @EnvironmentObject private var timerManager: StudyTimerManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Today's Progress")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Time Studied",
                    value: timerManager.formattedTime(timerManager.todayTotalTime),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Sessions",
                    value: "\(timerManager.sessionsCompletedToday)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(timerManager.currentStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

private struct FocusTipsView: View {
    private let tips = [
        "Find a quiet space free from distractions",
        "Put your phone in silent mode",
        "Take deep breaths before starting",
        "Stay hydrated during study sessions",
        "Use breaks to stretch and move around"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Focus Tips")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tips, id: \.self) { tip in
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(tip)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct CustomTimerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var customMinutes: Double
    @Binding var selectedDuration: TimeInterval
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Custom Duration")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Text("\(Int(customMinutes)) minutes")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Slider(value: $customMinutes, in: 5...120, step: 5)
                        .accentColor(.blue)
                }
                .padding(.vertical, 24)
                
                Button("Set Duration") {
                    selectedDuration = customMinutes * 60
                    dismiss()
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(16)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.black)
            .navigationTitle("Custom Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
} 