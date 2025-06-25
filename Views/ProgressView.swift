import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var streakManager: StreakManager
    @EnvironmentObject private var trophyManager: TrophyManager
    @EnvironmentObject private var stats: LearningStatsManager

    @State private var selectedTab: Tab = .overview
    @State private var animationProgress: Double = 0
    @State private var showingWeeklyGoals = false

    enum Tab {
        case overview, analytics, achievements
    }

    var body: some View {
        ZStack {
            // Dynamic background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.02, green: 0.05, blue: 0.2), location: 0),
                    .init(color: Color(red: 0.05, green: 0.1, blue: 0.3), location: 0.4),
                    .init(color: Color(red: 0.08, green: 0.15, blue: 0.4), location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    headerSection
                    
                    // Tab picker
                    tabPickerSection
                    
                    // Content based on selected tab
                    contentSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Learning Journey")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track your progress and celebrate achievements")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Current streak badge
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("\(streakManager.currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                        )
                )
            }
        }
        .opacity(animationProgress)
        .offset(y: animationProgress == 1.0 ? 0 : -20)
    }
    
    private var tabPickerSection: some View {
        HStack(spacing: 0) {
            ForEach([Tab.overview, Tab.analytics, Tab.achievements], id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: iconForTab(tab))
                            .font(.title3)
                        
                        Text(titleForTab(tab))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedTab == tab ? Color.white.opacity(0.15) : Color.clear)
                    )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.2))
        )
        .opacity(animationProgress)
    }
    
    @ViewBuilder
    private var contentSection: some View {
        switch selectedTab {
        case .overview:
            overviewContent
        case .analytics:
            analyticsContent
        case .achievements:
            achievementsContent
        }
    }
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Learning stats cards
            learningStatsGrid
            
            // Weekly progress chart
            weeklyProgressSection
            
            // Recent activity
            recentActivitySection
            
            // Quick actions
            quickActionsSection
        }
    }
    
    private var learningStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            LearningStatCard(
                icon: "book.closed.fill",
                title: "Courses Completed",
                value: "\(completedCoursesCount)",
                subtitle: "Total courses",
                color: .blue,
                animationDelay: 0.1
            )
            
            LearningStatCard(
                icon: "graduationcap.fill",
                title: "Lessons Mastered",
                value: "\(completedLessonsCount)",
                subtitle: "Total lessons",
                color: .green,
                animationDelay: 0.2
            )
            
            LearningStatCard(
                icon: "clock.fill",
                title: "Study Time",
                value: formatStudyTime(totalStudyTime),
                subtitle: "This week",
                color: .purple,
                animationDelay: 0.3
            )
            
            LearningStatCard(
                icon: "target",
                title: "Accuracy",
                value: "\(Int(averageAccuracy * 100))%",
                subtitle: "Quiz average",
                color: .orange,
                animationDelay: 0.4
            )
        }
    }
    
    private var weeklyProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("This Week's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingWeeklyGoals.toggle()
                }) {
                    Text("Set Goals")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
            }
            
            WeeklyProgressChart(
                dailyProgress: getDailyProgress(),
                currentStreak: streakManager.currentStreak
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Last 7 days")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                ForEach(getRecentActivities(), id: \.id) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "bell.fill",
                    title: "Set Reminder",
                    color: .blue,
                    action: { /* Handle reminder */ }
                )
                
                QuickActionButton(
                    icon: "chart.bar.fill",
                    title: "View Analytics",
                    color: .green,
                    action: { selectedTab = .analytics }
                )
                
                QuickActionButton(
                    icon: "trophy.fill",
                    title: "Achievements",
                    color: .orange,
                    action: { selectedTab = .achievements }
                )
            }
        }
    }
    
    private var analyticsContent: some View {
        VStack(spacing: 20) {
            // Learning velocity chart
            learningVelocitySection
            
            // Subject mastery radar
            subjectMasterySection
            
            // Study pattern insights
            studyPatternsSection
        }
    }
    
    private var learningVelocitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Learning Velocity")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Lessons per week")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            LearningVelocityChart(data: getLearningVelocityData())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    private var subjectMasterySection: some View {
        VStack(spacing: 16) {
            Text("Subject Mastery")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SubjectMasteryRadar(subjects: getSubjectMastery())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    private var studyPatternsSection: some View {
        VStack(spacing: 16) {
            Text("Study Patterns")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            StudyPatternsHeatMap(patterns: getStudyPatterns())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    private var achievementsContent: some View {
        VStack(spacing: 20) {
            // Achievement progress
            achievementProgressSection
            
            // Unlocked trophies
            unlockedTrophiesSection
            
            // Milestone timeline
            milestoneTimelineSection
        }
    }
    
    private var achievementProgressSection: some View {
        VStack(spacing: 16) {
            Text("Achievement Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(getAchievementProgress(), id: \.id) { achievement in
                    AchievementProgressCard(achievement: achievement)
                }
            }
        }
    }
    
    private var unlockedTrophiesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Unlocked Trophies")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(trophyManager.unlockedTrophies.count) of \(getTotalTrophies())")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(getTrophies(), id: \.id) { trophy in
                    TrophyCard(trophy: trophy)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    private var milestoneTimelineSection: some View {
        VStack(spacing: 16) {
            Text("Learning Milestones")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            MilestoneTimeline(milestones: getLearningMilestones())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
    }
    
    // MARK: - Helper Functions
    
    private func iconForTab(_ tab: Tab) -> String {
        switch tab {
        case .overview: return "house.fill"
        case .analytics: return "chart.bar.fill"
        case .achievements: return "trophy.fill"
        }
    }
    
    private func titleForTab(_ tab: Tab) -> String {
        switch tab {
        case .overview: return "Overview"
        case .analytics: return "Analytics"
        case .achievements: return "Achievements"
        }
    }
    
    private var completedCoursesCount: Int {
        stats.courses.filter { $0.lessons.allSatisfy { $0.isCompleted } }.count
    }
    
    private var completedLessonsCount: Int {
        stats.courses.reduce(0) { $0 + $1.lessons.filter { $0.isCompleted }.count }
    }
    
    private var totalStudyTime: Int {
        // Calculate total study time in minutes for this week
        420 // Placeholder
    }
    
    private var averageAccuracy: Double {
        // Calculate average quiz accuracy
        0.85 // Placeholder
    }
    
    private func formatStudyTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private func getDailyProgress() -> [DailyProgress] {
        // Return last 7 days of progress
        (0..<7).map { dayOffset in
            DailyProgress(
                date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date(),
                lessonsCompleted: Int.random(in: 0...3),
                studyTime: Int.random(in: 0...60)
            )
        }.reversed()
    }
    
    private func getRecentActivities() -> [RecentActivity] {
        [
            RecentActivity(
                id: UUID(),
                type: .lessonCompleted,
                title: "Completed: Introduction to Physics",
                subtitle: "Science Course",
                timestamp: Date().addingTimeInterval(-3600),
                icon: "checkmark.circle.fill",
                color: .green
            ),
            RecentActivity(
                id: UUID(),
                type: .quizPassed,
                title: "Quiz Passed: World War 2 Basics",
                subtitle: "Score: 85%",
                timestamp: Date().addingTimeInterval(-7200),
                icon: "star.fill",
                color: .yellow
            ),
            RecentActivity(
                id: UUID(),
                type: .streakExtended,
                title: "Streak Extended!",
                subtitle: "5 days in a row",
                timestamp: Date().addingTimeInterval(-10800),
                icon: "flame.fill",
                color: .orange
            )
        ]
    }
    
    private func getLearningVelocityData() -> [VelocityData] {
        (0..<8).map { weekOffset in
            VelocityData(
                week: Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()) ?? Date(),
                lessonsCompleted: Int.random(in: 2...8)
            )
        }.reversed()
    }
    
    private func getSubjectMastery() -> [SubjectMastery] {
        [
            SubjectMastery(subject: "Science", mastery: 0.85, color: .blue),
            SubjectMastery(subject: "History", mastery: 0.72, color: .green),
            SubjectMastery(subject: "Math", mastery: 0.63, color: .purple),
            SubjectMastery(subject: "Language", mastery: 0.78, color: .orange),
            SubjectMastery(subject: "Programming", mastery: 0.91, color: .cyan)
        ]
    }
    
    private func getStudyPatterns() -> [[StudyPattern]] {
        // 7 days x 24 hours grid
        (0..<7).map { day in
            (0..<24).map { hour in
                StudyPattern(
                    day: day,
                    hour: hour,
                    intensity: Double.random(in: 0...1)
                )
            }
        }
    }
    
    private func getAchievementProgress() -> [AchievementProgress] {
        [
            AchievementProgress(
                id: UUID(),
                title: "Course Master",
                description: "Complete 10 courses",
                currentProgress: 3,
                targetProgress: 10,
                isUnlocked: false,
                icon: "graduationcap.fill",
                color: .blue
            ),
            AchievementProgress(
                id: UUID(),
                title: "Speed Learner",
                description: "Complete 5 lessons in one day",
                currentProgress: 5,
                targetProgress: 5,
                isUnlocked: true,
                icon: "bolt.fill",
                color: .yellow
            )
        ]
    }
    
    private func getTrophies() -> [Trophy] {
        [
            Trophy(
                id: UUID(),
                title: "First Steps",
                description: "Complete your first course",
                isUnlocked: trophyManager.unlockedTrophies.contains("First Course Complete"),
                icon: "star.fill",
                color: .yellow
            ),
            Trophy(
                id: UUID(),
                title: "Consistency King",
                description: "Maintain a 7-day streak",
                isUnlocked: trophyManager.unlockedTrophies.contains("7-Day Streak"),
                icon: "flame.fill",
                color: .orange
            )
        ]
    }
    
    private func getTotalTrophies() -> Int {
        12 // Total available trophies
    }
    
    private func getLearningMilestones() -> [LearningMilestone] {
        [
            LearningMilestone(
                id: UUID(),
                title: "First Course Completed",
                description: "Completed Introduction to Science",
                date: Date().addingTimeInterval(-86400 * 5),
                type: .courseCompleted,
                isCompleted: true
            ),
            LearningMilestone(
                id: UUID(),
                title: "Quiz Master",
                description: "Scored 100% on World War 2 Quiz",
                date: Date().addingTimeInterval(-86400 * 3),
                type: .perfectQuiz,
                isCompleted: true
            ),
            LearningMilestone(
                id: UUID(),
                title: "Streak Champion",
                description: "Reach 10-day learning streak",
                date: nil,
                type: .streakGoal,
                isCompleted: false
            )
        ]
    }
}

// MARK: - Supporting Views and Models

struct LearningStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let animationDelay: Double
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(animationProgress)
        .opacity(animationProgress)
        .onAppear {
            withAnimation(.spring().delay(animationDelay)) {
                animationProgress = 1.0
            }
        }
    }
}

struct WeeklyProgressChart: View {
    let dailyProgress: [DailyProgress]
    let currentStreak: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(dailyProgress, id: \.date) { progress in
                    VStack(spacing: 8) {
                        Text(dayOfWeek(from: progress.date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                .frame(width: 36, height: 36)
                            
                            if progress.lessonsCompleted > 0 {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 28, height: 28)
                                
                                Text("\(progress.lessonsCompleted)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(dayOfMonth(from: progress.date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct ActivityRow: View {
    let activity: RecentActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.title3)
                .foregroundColor(activity.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(timeAgo(from: activity.timestamp))
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        if hours < 1 {
            return "Just now"
        } else if hours < 24 {
            return "\(hours)h ago"
        } else {
            return "\(hours / 24)d ago"
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// Placeholder views for analytics content
struct LearningVelocityChart: View {
    let data: [VelocityData]
    
    var body: some View {
        Text("Learning Velocity Chart")
            .foregroundColor(.white.opacity(0.7))
            .frame(height: 120)
    }
}

struct SubjectMasteryRadar: View {
    let subjects: [SubjectMastery]
    
    var body: some View {
        Text("Subject Mastery Radar")
            .foregroundColor(.white.opacity(0.7))
            .frame(height: 200)
    }
}

struct StudyPatternsHeatMap: View {
    let patterns: [[StudyPattern]]
    
    var body: some View {
        Text("Study Patterns Heat Map")
            .foregroundColor(.white.opacity(0.7))
            .frame(height: 120)
    }
}

struct AchievementProgressCard: View {
    let achievement: AchievementProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.color)
                
                Spacer()
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            
            Text(achievement.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
            
            // Custom progress bar since ProgressView doesn't support value/total parameters
            HStack {
                Rectangle()
                    .fill(achievement.color)
                    .frame(width: CGFloat(achievement.currentProgress) / CGFloat(achievement.targetProgress) * 200, height: 4)
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
            }
            .frame(height: 4)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            
            Text("\(achievement.currentProgress)/\(achievement.targetProgress)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(achievement.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TrophyCard: View {
    let trophy: Trophy
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: trophy.icon)
                .font(.largeTitle)
                .foregroundColor(trophy.isUnlocked ? trophy.color : .gray)
            
            Text(trophy.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(trophy.isUnlocked ? .white : .gray)
            
            Text(trophy.description)
                .font(.caption)
                .foregroundColor(trophy.isUnlocked ? .white.opacity(0.7) : .gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(trophy.isUnlocked ? Color.white.opacity(0.05) : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(trophy.isUnlocked ? trophy.color.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(trophy.isUnlocked ? 1.0 : 0.5)
    }
}

struct MilestoneTimeline: View {
    let milestones: [LearningMilestone]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(milestones) { milestone in
                HStack(spacing: 16) {
                    // Timeline indicator
                    VStack {
                        Circle()
                            .fill(milestone.isCompleted ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        
                        if milestone != milestones.last {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 2, height: 40)
                        }
                    }
                    
                    // Milestone content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(milestone.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(milestone.isCompleted ? .white : .gray)
                        
                        Text(milestone.description)
                            .font(.subheadline)
                            .foregroundColor(milestone.isCompleted ? .white.opacity(0.8) : .gray.opacity(0.8))
                        
                        if let date = milestone.date {
                            Text(formatDate(date))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Data Models

struct DailyProgress {
    let date: Date
    let lessonsCompleted: Int
    let studyTime: Int
}

struct RecentActivity: Identifiable {
    let id: UUID
    let type: ActivityType
    let title: String
    let subtitle: String
    let timestamp: Date
    let icon: String
    let color: Color
    
    enum ActivityType {
        case lessonCompleted, quizPassed, streakExtended, courseCompleted
    }
}

struct VelocityData {
    let week: Date
    let lessonsCompleted: Int
}

struct SubjectMastery {
    let subject: String
    let mastery: Double
    let color: Color
}

struct StudyPattern {
    let day: Int
    let hour: Int
    let intensity: Double
}

struct AchievementProgress: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let currentProgress: Int
    let targetProgress: Int
    let isUnlocked: Bool
    let icon: String
    let color: Color
}

struct Trophy: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let isUnlocked: Bool
    let icon: String
    let color: Color
}

struct LearningMilestone: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let date: Date?
    let type: MilestoneType
    let isCompleted: Bool
    
    enum MilestoneType {
        case courseCompleted, perfectQuiz, streakGoal, lessonMastery
    }
    
    static func == (lhs: LearningMilestone, rhs: LearningMilestone) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    ProgressView()
        .environmentObject(StreakManager())
        .environmentObject(TrophyManager())
        .environmentObject(LearningStatsManager())
}
