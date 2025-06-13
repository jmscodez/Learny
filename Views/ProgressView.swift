import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var streakManager: StreakManager
    @EnvironmentObject private var trophyManager: TrophyManager
    @EnvironmentObject private var stats: LearningStatsManager

    @State private var selectedTab: Tab = .trophies

    enum Tab {
        case trophies, stats
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 30) {
                Text("Your Learning Streak")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                        .padding(.top, 20)

                HStack(spacing: 16) {
                        StreakBox(label: "Current", value: streakManager.currentStreak, icon: "flame.fill", color: .orange)
                        StreakBox(label: "Longest", value: streakManager.longestStreak, icon: "crown.fill", color: .green)
                    }

                    WeeklyCalendarView()

                    PickerView(selectedTab: $selectedTab)

                    if selectedTab == .trophies {
                        TrophiesView()
                    } else {
                        StatsView()
                }

                    ReminderButton()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Subviews
private struct PickerView: View {
    @Binding var selectedTab: ProgressView.Tab
    
    var body: some View {
        HStack {
            Button("Trophies") { selectedTab = .trophies }
                .buttonStyle(PickerButtonStyle(isSelected: selectedTab == .trophies))
            
            Button("Stats") { selectedTab = .stats }
                .buttonStyle(PickerButtonStyle(isSelected: selectedTab == .stats))
        }
    }
}

private struct TrophiesView: View {
    @EnvironmentObject var trophyManager: TrophyManager
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            TrophyBox(
                name: "First Steps",
                description: "Complete 1 course",
                unlocked: trophyManager.unlockedTrophies.contains("First Course Complete")
            )
            TrophyBox(
                name: "Getting Consistent",
                description: "Maintain a 3-day learning streak",
                unlocked: trophyManager.unlockedTrophies.contains("3-Day Streak")
            )
        }
    }
}

private struct StatsView: View {
    @EnvironmentObject var stats: LearningStatsManager
    @EnvironmentObject var trophyManager: TrophyManager
    
    var body: some View {
                    VStack(spacing: 16) {
            StatRow(
                icon: "checkmark.circle.fill",
                label: "Courses Completed",
                value: "\(stats.courses.filter { $0.lessons.allSatisfy(\.isComplete) }.count)",
                color: .green
            )
            StatRow(
                icon: "book.closed.fill",
                label: "Lessons Completed",
                value: "\(stats.courses.reduce(0) { $0 + $1.lessons.filter(\.isComplete).count })",
                color: .cyan
            )
            StatRow(
                icon: "star.fill",
                label: "Total XP",
                value: "\(stats.courses.reduce(0) { $0 + $1.lessons.filter(\.isComplete).count * 10 })",
                color: .yellow
            )
            StatRow(
                icon: "trophy.fill",
                label: "Trophies Unlocked",
                value: "\(trophyManager.unlockedTrophies.count)",
                color: .orange
            )
    }
}
}

private struct StreakBox: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.headline)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .bold))
                Text("\(value)")
                    .font(.system(size: 40, weight: .bold))
            }
            
            Text("days")
                .font(.caption)
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.gray.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color, lineWidth: 2)
        )
        .cornerRadius(16)
    }
}

private struct WeeklyCalendarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline).bold()
                .foregroundColor(.white)
            
            HStack {
                ForEach(getWeekDays(), id: \.self) { date in
                    VStack {
                        Text(dayOfWeek(from: date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 36, height: 36)
                            
                            Text(dayOfMonth(from: date))
                                .font(.subheadline).bold()
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
    }
    
    private func getWeekDays() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        
        let range = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let sunday = calendar.date(byAdding: .day, value: -dayOfWeek + range.lowerBound, to: today)!
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
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

private struct TrophyBox: View {
    let name: String
    let description: String
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
            
            VStack {
            Text(name)
                    .font(.headline)
                .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
        .opacity(unlocked ? 1.0 : 0.5)
    }
}

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.title2).bold()
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
    }
}

private struct ReminderButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "bell.fill")
                Text("Set Daily Reminder")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple.opacity(0.8))
            .cornerRadius(16)
        }
    }
}

// MARK: - Button Styles & Previews
struct PickerButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
            .foregroundColor(.white)
        .cornerRadius(12)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(StreakManager())
            .environmentObject(TrophyManager())
            .environmentObject(LearningStatsManager())
            .preferredColorScheme(.dark)
    }
}
