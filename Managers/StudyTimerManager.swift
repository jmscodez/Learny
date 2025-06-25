import Foundation
import Combine
import UserNotifications

enum StudySessionType: Codable {
    case focused // Pomodoro-style focused session
    case review // Quick review session
    case practice // Practice exercises
    case exploration // Free exploration
}

enum TimerState: Codable {
    case idle
    case running
    case paused
    case breakTime
    case completed
}

struct StudySession: Identifiable, Codable {
    var id = UUID()
    var courseId: UUID?
    var lessonId: UUID?
    var type: StudySessionType
    var startTime: Date
    var endTime: Date?
    var targetDuration: TimeInterval // in seconds
    var actualDuration: TimeInterval = 0
    var wasCompleted: Bool = false
    var breaksTaken: Int = 0
    var focusScore: Double = 0.0 // 0.0 to 1.0
    var notes: String = ""
    var achievements: [String] = []
}

@MainActor
class StudyTimerManager: ObservableObject {
    @Published var currentSession: StudySession?
    @Published var timerState: TimerState = .idle
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalSessionTime: TimeInterval = 0
    @Published var sessionsToday: [StudySession] = []
    @Published var weeklyStats: [StudySession] = []
    @Published var currentStreak: Int = 0
    
    // Timer configuration
    @Published var focusSessionDuration: TimeInterval = 25 * 60 // 25 minutes
    @Published var shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    @Published var longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    @Published var sessionsUntilLongBreak: Int = 4
    
    // Focus tracking
    @Published var focusLevel: Double = 1.0
    @Published var distractionCount: Int = 0
    @Published var motivationalMessage: String = "Ready to learn?"
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var pausedTime: TimeInterval = 0
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        loadTodaySessions()
        loadWeeklyStats()
        requestNotificationPermission()
    }
    
    // MARK: - Timer Control
    
    func startFocusSession(courseId: UUID? = nil, lessonId: UUID? = nil, duration: TimeInterval? = nil) {
        let sessionDuration = duration ?? focusSessionDuration
        
        currentSession = StudySession(
            courseId: courseId,
            lessonId: lessonId,
            type: .focused,
            startTime: Date(),
            targetDuration: sessionDuration
        )
        
        timeRemaining = sessionDuration
        totalSessionTime = sessionDuration
        timerState = .running
        sessionStartTime = Date()
        focusLevel = 1.0
        distractionCount = 0
        
        startTimer()
        scheduleSessionNotification()
        updateMotivationalMessage()
    }
    
    func startReviewSession(duration: TimeInterval = 10 * 60) {
        startFocusSession(duration: duration)
        currentSession?.type = .review
        updateMotivationalMessage()
    }
    
    func pauseSession() {
        guard timerState == .running else { return }
        
        timer?.invalidate()
        timerState = .paused
        pausedTime = Date().timeIntervalSince(sessionStartTime ?? Date())
        recordDistraction()
        
        updateMotivationalMessage()
    }
    
    func resumeSession() {
        guard timerState == .paused else { return }
        
        timerState = .running
        sessionStartTime = Date().addingTimeInterval(-pausedTime)
        startTimer()
        
        updateMotivationalMessage()
    }
    
    func endSession(completed: Bool = false) {
        timer?.invalidate()
        
        guard let session = currentSession else { return }
        
        let endTime = Date()
        var updatedSession = session
        updatedSession.endTime = endTime
        updatedSession.actualDuration = endTime.timeIntervalSince(session.startTime)
        updatedSession.wasCompleted = completed
        updatedSession.focusScore = calculateFocusScore()
        
        if completed {
            updatedSession.achievements = generateAchievements(for: updatedSession)
        }
        
        saveSession(updatedSession)
        
        timerState = completed ? .completed : .idle
        currentSession = nil
        timeRemaining = 0
        
        if completed {
            scheduleBreakNotification()
            updateStreak()
        }
        
        updateMotivationalMessage()
    }
    
    func startBreak(isLong: Bool = false) {
        let breakDuration = isLong ? longBreakDuration : shortBreakDuration
        timeRemaining = breakDuration
        timerState = .breakTime
        
        startTimer()
        scheduleBreakEndNotification(duration: breakDuration)
        updateMotivationalMessage()
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            timer?.invalidate()
            handleTimerCompletion()
            return
        }
        
        timeRemaining -= 1
        
        // Update focus level based on session progress
        if timerState == .running {
            updateFocusLevel()
        }
    }
    
    private func handleTimerCompletion() {
        switch timerState {
        case .running:
            endSession(completed: true)
        case .breakTime:
            timerState = .idle
            updateMotivationalMessage()
        default:
            break
        }
    }
    
    private func updateFocusLevel() {
        // Simulate focus level changes (in real app, this could be based on device sensors or user interaction)
        let progressRatio = 1 - (timeRemaining / totalSessionTime)
        
        // Focus typically drops in the middle of sessions
        if progressRatio < 0.3 {
            focusLevel = 1.0 - (progressRatio * 0.2)
        } else if progressRatio < 0.7 {
            focusLevel = 0.8 - ((progressRatio - 0.3) * 0.3)
        } else {
            focusLevel = 0.65 + ((progressRatio - 0.7) * 0.35)
        }
        
        // Add some randomness
        focusLevel += Double.random(in: -0.05...0.05)
        focusLevel = max(0.0, min(1.0, focusLevel))
    }
    
    private func recordDistraction() {
        distractionCount += 1
        focusLevel = max(0.0, focusLevel - 0.1)
    }
    
    private func calculateFocusScore() -> Double {
        let baseScore = focusLevel
        let distractionPenalty = Double(distractionCount) * 0.05
        let completionBonus = currentSession?.wasCompleted == true ? 0.1 : 0.0
        
        return max(0.0, min(1.0, baseScore - distractionPenalty + completionBonus))
    }
    
    private func generateAchievements(for session: StudySession) -> [String] {
        var achievements: [String] = []
        
        if session.focusScore > 0.9 {
            achievements.append("🎯 Perfect Focus")
        }
        
        if session.actualDuration >= session.targetDuration {
            achievements.append("⏰ Full Session")
        }
        
        if distractionCount == 0 {
            achievements.append("🧘 Zero Distractions")
        }
        
        if session.actualDuration > 30 * 60 {
            achievements.append("🔥 Deep Focus")
        }
        
        return achievements
    }
    
    private func saveSession(_ session: StudySession) {
        sessionsToday.append(session)
        weeklyStats.append(session)
        
        // Keep only last 7 days of weekly stats
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        weeklyStats = weeklyStats.filter { $0.startTime >= weekAgo }
        
        // Persist to UserDefaults or Core Data
        saveToPersistence()
    }
    
    private func loadTodaySessions() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // In real app, load from persistence
        sessionsToday = []
    }
    
    private func loadWeeklyStats() {
        // In real app, load from persistence
        weeklyStats = []
    }
    
    private func saveToPersistence() {
        // In real app, save to Core Data or UserDefaults
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastSession = weeklyStats.last(where: { $0.wasCompleted }),
           calendar.isDate(lastSession.startTime, inSameDayAs: today) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
    }
    
    private func updateMotivationalMessage() {
        switch timerState {
        case .idle:
            motivationalMessage = "Ready to start your learning session?"
        case .running:
            let messages = [
                "You're doing great! Stay focused! 🎯",
                "Keep going! Every minute counts! 💪",
                "Focus mode activated! You've got this! 🚀",
                "Deep learning in progress... 🧠",
                "Building knowledge, one moment at a time! 📚"
            ]
            motivationalMessage = messages.randomElement() ?? "Stay focused!"
        case .paused:
            motivationalMessage = "Take a moment, then get back to it! 🤔"
        case .breakTime:
            motivationalMessage = "Enjoy your break! Your brain is processing... 🌱"
        case .completed:
            motivationalMessage = "Excellent work! Session completed! 🎉"
        }
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func scheduleSessionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Great job! Time for a well-deserved break."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: totalSessionTime, repeats: false)
        let request = UNNotificationRequest(identifier: "session_complete", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    private func scheduleBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Break Time!"
        content.body = "Take a few minutes to rest and recharge."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "break_time", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    private func scheduleBreakEndNotification(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Break's Over!"
        content.body = "Ready to get back to learning?"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "break_end", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - Statistics
    
    var todayTotalTime: TimeInterval {
        sessionsToday.reduce(0) { $0 + $1.actualDuration }
    }
    
    var weeklyTotalTime: TimeInterval {
        weeklyStats.reduce(0) { $0 + $1.actualDuration }
    }
    
    var averageFocusScore: Double {
        let completedSessions = weeklyStats.filter { $0.wasCompleted }
        guard !completedSessions.isEmpty else { return 0.0 }
        
        return completedSessions.reduce(0) { $0 + $1.focusScore } / Double(completedSessions.count)
    }
    
    var sessionsCompletedToday: Int {
        sessionsToday.filter { $0.wasCompleted }.count
    }
    
    var weeklySessionsCompleted: Int {
        weeklyStats.filter { $0.wasCompleted }.count
    }
    
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 