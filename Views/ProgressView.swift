import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var streakManager: StreakManager
    @EnvironmentObject private var trophyManager: TrophyManager

    @State private var selectedTab = 0
    @State private var showTimePicker = false
    @State private var reminderTime = Date()

    private let daysOfWeek = Calendar.current.shortWeekdaySymbols

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Text("Your Learning Streak")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)

                // Streak boxes
                HStack(spacing: 16) {
                    StreakBox(label: "Current", value: "\(streakManager.currentStreak)")
                    StreakBox(label: "Longest", value: "\(streakManager.longestStreak)")
                }

                // 7-day calendar strip
                HStack(spacing: 12) {
                    ForEach(0..<7) { offset in
                        let weekday = Calendar.current.date(byAdding: .day, value: -6+offset, to: Date())!
                        let short = daysOfWeek[Calendar.current.component(.weekday, from: weekday)-1]
                        VStack {
                            Circle()
                                .strokeBorder(Color.gray, lineWidth: 1)
                                .background(
                                    Circle().fill(todayStudied(offset: offset) ? Color.cyan : Color.clear)
                                )
                                .frame(width: 24, height: 24)
                            Text(short)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Segmented control
                Picker("", selection: $selectedTab) {
                    Text("Trophies").tag(0)
                    Text("Stats").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                if selectedTab == 0 {
                    // Trophies grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TrophyBox(name: "First Steps", unlocked: trophyManager.unlockedTrophies.contains("First Course Complete"))
                            TrophyBox(name: "3-Day Streak", unlocked: trophyManager.unlockedTrophies.contains("3-Day Streak"))
                            // TODO: more trophies...
                        }
                        .padding(.horizontal, 24)
                    }
                } else {
                    // Stats grid
                    VStack(spacing: 16) {
                        StatBox(label: "Courses", value: "\(streakManager.currentStreak)") // placeholder
                        StatBox(label: "Lessons", value: "0")                       // placeholder
                        StatBox(label: "XP", value: "0")                            // placeholder
                    }
                }

                // Reminder button
                Button(action: { showTimePicker = true }) {
                    Text("Set Daily Reminder")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.red]),
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                }
                .sheet(isPresented: $showTimePicker) {
                    VStack {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                        Button("Save") {
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                            NotificationsManager().scheduleDailyReminder(
                                hour: comps.hour ?? 20,
                                minute: comps.minute ?? 0
                            )
                            showTimePicker = false
                        }
                        .font(.headline)
                        .padding()
                    }
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                }

                Spacer(minLength: 48)
            }
            .padding(.top, 48)
        }
        .preferredColorScheme(.dark)
    }

    private func todayStudied(offset: Int) -> Bool {
        // TODO: replace with real tracking of last 7 days
        return offset == 6 // only today for now
    }
}

// Reusable subviews
private struct StreakBox: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Text("days")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 100)
        .background(Color(white: 0.15))
        .cornerRadius(16)
    }
}

private struct TrophyBox: View {
    let name: String
    let unlocked: Bool

    var body: some View {
        VStack {
            Image(systemName: unlocked ? "star.fill" : "star")
                .font(.largeTitle)
                .foregroundColor(unlocked ? .yellow : .gray)
            Text(name)
                .font(.caption2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100, height: 100)
        .background(Color(white: 0.15))
        .cornerRadius(16)
    }
}

private struct StatBox: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(StreakManager())
            .environmentObject(TrophyManager())
            .preferredColorScheme(.dark)
    }
}
