import Foundation

final class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    private var lastStudy: Date?

    func recordStudy() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = lastStudy {
            // count days between lastStudy and today
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if daysBetween == 1 {
                // you studied yesterday → increment streak
                currentStreak += 1
            } else if daysBetween != 0 {
                // skipped at least one day → reset
                currentStreak = 1
            }
        } else {
            // first-ever study
            currentStreak = 1
        }

        lastStudy = today
        longestStreak = max(longestStreak, currentStreak)
    }
}
