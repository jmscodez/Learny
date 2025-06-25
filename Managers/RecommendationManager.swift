import Foundation
import Combine

struct CourseRecommendation: Identifiable {
    let id = UUID()
    let course: Course
    let reason: String
    let confidence: Double // 0.0 to 1.0
    let type: RecommendationType
}

enum RecommendationType {
    case similar
    case nextInPath
    case basedOnInterests
    case trending
    case difficulty
    case category
    case userCreated
}

@MainActor
class RecommendationManager: ObservableObject {
    @Published var recommendedCourses: [CourseRecommendation] = []
    @Published var trendingCourses: [Course] = []
    @Published var learningPaths: [LearningPath] = []
    @Published var dailyRecommendations: [CourseRecommendation] = []
    
    private let analytics: LearningStatsManager
    
    init(analytics: LearningStatsManager) {
        self.analytics = analytics
        generateInitialRecommendations()
    }
    
    func generateRecommendations(for user: UserProfile? = nil) {
        var recommendations: [CourseRecommendation] = []
        
        // Based on completed courses
        let completedCourses = analytics.courses.filter { $0.isCompleted }
        for course in completedCourses {
            recommendations.append(contentsOf: generateSimilarCourseRecommendations(basedOn: course))
            recommendations.append(contentsOf: generateNextInPathRecommendations(after: course))
        }
        
        // Based on current learning patterns
        let inProgressCourses = analytics.courses.filter { !$0.isCompleted && $0.progress > 0 }
        for course in inProgressCourses {
            recommendations.append(contentsOf: generateRelatedRecommendations(basedOn: course))
        }
        
        // Based on user interests and categories
        recommendations.append(contentsOf: generateCategoryBasedRecommendations())
        
        // Remove duplicates and sort by confidence
        let uniqueRecommendations = Array(Set(recommendations.map { $0.course.id }))
            .compactMap { courseId in recommendations.first { $0.course.id == courseId } }
            .sorted { $0.confidence > $1.confidence }
        
        self.recommendedCourses = Array(uniqueRecommendations.prefix(10))
        generateDailyRecommendations()
    }
    
    private func generateSimilarCourseRecommendations(basedOn course: Course) -> [CourseRecommendation] {
        // Generate sample similar courses based on category and difficulty
        return generateSampleCourses(category: course.category, difficulty: course.difficulty, count: 2)
            .map { similarCourse in
                CourseRecommendation(
                    course: similarCourse,
                    reason: "Similar to \(course.title)",
                    confidence: 0.8,
                    type: .similar
                )
            }
    }
    
    private func generateNextInPathRecommendations(after course: Course) -> [CourseRecommendation] {
        // Generate next level courses
        let nextDifficulty: Difficulty
        switch course.difficulty {
        case .beginner: nextDifficulty = .intermediate
        case .intermediate: nextDifficulty = .advanced
        case .advanced: nextDifficulty = .advanced // Stay at advanced
        }
        
        return generateSampleCourses(category: course.category, difficulty: nextDifficulty, count: 1)
            .map { nextCourse in
                CourseRecommendation(
                    course: nextCourse,
                    reason: "Next step after \(course.title)",
                    confidence: 0.9,
                    type: .nextInPath
                )
            }
    }
    
    private func generateRelatedRecommendations(basedOn course: Course) -> [CourseRecommendation] {
        // Generate courses in related categories
        let relatedCategories = getRelatedCategories(for: course.category)
        return relatedCategories.flatMap { category in
            generateSampleCourses(category: category, difficulty: course.difficulty, count: 1)
        }.map { relatedCourse in
            CourseRecommendation(
                course: relatedCourse,
                reason: "Related to your interests",
                confidence: 0.7,
                type: .basedOnInterests
            )
        }
    }
    
    private func generateCategoryBasedRecommendations() -> [CourseRecommendation] {
        // Generate trending courses across all categories
        return CourseCategory.allCases.prefix(3).flatMap { category in
            generateSampleCourses(category: category, difficulty: .beginner, count: 1)
        }.map { trendingCourse in
            CourseRecommendation(
                course: trendingCourse,
                reason: "Trending in \(trendingCourse.category.displayName)",
                confidence: 0.6,
                type: .trending
            )
        }
    }
    
    private func generateDailyRecommendations() {
        // Select 3 best recommendations for today
        dailyRecommendations = Array(recommendedCourses.prefix(3))
    }
    
    private func getRelatedCategories(for category: CourseCategory) -> [CourseCategory] {
        switch category {
        case .history: return [.philosophy, .arts]
        case .science: return [.technology, .mathematics]
        case .technology: return [.science, .mathematics]
        case .language: return [.arts, .philosophy]
        case .arts: return [.language, .history]
        case .business: return [.technology, .mathematics]
        case .health: return [.science, .philosophy]
        case .mathematics: return [.science, .technology]
        case .philosophy: return [.history, .arts]
        case .other: return [.science, .technology]
        }
    }
    
    private func generateSampleCourses(category: CourseCategory, difficulty: Difficulty, count: Int) -> [Course] {
        let sampleTitles = getSampleTitles(for: category, difficulty: difficulty)
        return sampleTitles.prefix(count).map { title in
            Course(
                id: UUID(),
                title: title,
                topic: title.lowercased(),
                difficulty: difficulty,
                pace: .balanced,
                creationMethod: .aiAssistant,
                lessons: generateSampleLessons(count: Int.random(in: 5...12)),
                createdAt: Date(),
                overview: "An engaging course on \(title.lowercased()) designed for \(difficulty.rawValue) learners.",
                learningObjectives: ["Understand core concepts", "Apply knowledge practically", "Master key skills"],
                whoIsThisFor: "\(difficulty.rawValue.capitalized) learners interested in \(category.displayName.lowercased())",
                estimatedTime: "\(Int.random(in: 2...8)) hours",
                category: category,
                tags: [category.displayName.lowercased(), difficulty.rawValue]
            )
        }
    }
    
    private func getSampleTitles(for category: CourseCategory, difficulty: Difficulty) -> [String] {
        let prefix = difficulty == .beginner ? "Introduction to" : difficulty == .intermediate ? "Understanding" : "Advanced"
        
        switch category {
        case .history:
            return ["\(prefix) Ancient Civilizations", "\(prefix) World War II", "\(prefix) Renaissance Period"]
        case .science:
            return ["\(prefix) Physics Fundamentals", "\(prefix) Chemistry Basics", "\(prefix) Biology Essentials"]
        case .technology:
            return ["\(prefix) Programming", "\(prefix) Artificial Intelligence", "\(prefix) Cybersecurity"]
        case .language:
            return ["\(prefix) Spanish", "\(prefix) French Grammar", "\(prefix) English Literature"]
        case .arts:
            return ["\(prefix) Digital Art", "\(prefix) Classical Music", "\(prefix) Photography"]
        case .business:
            return ["\(prefix) Marketing", "\(prefix) Entrepreneurship", "\(prefix) Finance"]
        case .health:
            return ["\(prefix) Nutrition", "\(prefix) Mental Health", "\(prefix) Exercise Science"]
        case .mathematics:
            return ["\(prefix) Calculus", "\(prefix) Statistics", "\(prefix) Linear Algebra"]
        case .philosophy:
            return ["\(prefix) Ethics", "\(prefix) Logic", "\(prefix) Ancient Philosophy"]
        case .other:
            return ["\(prefix) Critical Thinking", "\(prefix) Problem Solving", "\(prefix) Communication"]
        }
    }
    
    private func generateSampleLessons(count: Int) -> [Lesson] {
        (1...count).map { index in
            Lesson(
                title: "Lesson \(index)",
                lessonNumber: index,
                estimatedDuration: Int.random(in: 10...25)
            )
        }
    }
    
    private func generateInitialRecommendations() {
        // Generate some initial recommendations
        generateRecommendations()
        
        // Generate learning paths
        learningPaths = [
            LearningPath(
                id: UUID(),
                title: "Complete History Journey",
                description: "From ancient civilizations to modern times",
                courses: [],
                category: .history,
                estimatedDuration: "24 hours",
                difficulty: .beginner
            ),
            LearningPath(
                id: UUID(),
                title: "Science Foundation",
                description: "Build a strong foundation in natural sciences",
                courses: [],
                category: .science,
                estimatedDuration: "18 hours",
                difficulty: .beginner
            ),
            LearningPath(
                id: UUID(),
                title: "Tech Skills Mastery",
                description: "From programming basics to advanced concepts",
                courses: [],
                category: .technology,
                estimatedDuration: "32 hours",
                difficulty: .intermediate
            )
        ]
    }
}

struct LearningPath: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var courses: [UUID] // Course IDs in order
    var category: CourseCategory
    var estimatedDuration: String
    var difficulty: Difficulty
    var prerequisites: [UUID] = []
    var tags: [String] = []
    var isPublic: Bool = true
    var createdBy: String = "Learny AI"
    var createdAt: Date = Date()
    
    var progressPercentage: Double = 0.0
    var isStarted: Bool = false
    var isCompleted: Bool = false
}

struct UserProfile: Codable {
    var interests: [CourseCategory] = []
    var preferredDifficulty: Difficulty = .beginner
    var preferredPace: Pace = .balanced
    var learningGoals: [String] = []
    var availableTimePerDay: Int = 30 // minutes
    var preferredLearningStyle: LearningStyle = .visual
    var completedCategories: Set<CourseCategory> = []
    var weakAreas: [CourseCategory] = []
    var strongAreas: [CourseCategory] = []
} 