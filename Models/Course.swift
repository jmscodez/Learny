import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "gear"
        case .advanced: return "crown.fill"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Perfect for newcomers! Starts with fundamentals, uses simple language, includes lots of examples, and assumes no prior knowledge. Concepts are introduced step-by-step with plenty of context."
        case .intermediate: return "Building on basics. Connects concepts together, introduces more complex topics, assumes some background knowledge, and moves at a moderate pace."
        case .advanced: return "For experienced learners. Deep technical content, complex analysis, assumes strong foundation, and covers cutting-edge topics with detailed exploration."
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "blue"
        case .intermediate: return "orange"
        case .advanced: return "purple"
        }
    }
}

enum Pace: String, Codable, CaseIterable {
    case quickReview = "quick_review", balanced, deepDive = "deep_dive"
    
    var displayName: String {
        switch self {
        case .quickReview:
            return "Quick Review"
        case .balanced:
            return "Balanced"
        case .deepDive:
            return "Deep Dive"
        }
    }
    
    var icon: String {
        switch self {
        case .quickReview: return "bolt.fill"
        case .balanced: return "arrow.left.arrow.right"
        case .deepDive: return "magnifyingglass"
        }
    }
    
    var description: String {
        switch self {
        case .quickReview: return "Quick overview. Fast-paced summary of key points, perfect for refreshers, brief explanations, and rapid knowledge acquisition."
        case .balanced: return "Perfect middle ground. Moderate pace with good depth, balanced explanations, practical examples, and steady progress through topics."
        case .deepDive: return "Comprehensive, in-depth exploration. Detailed analysis, multiple perspectives, extensive examples, and thorough coverage of subtopics. Maximum learning depth."
        }
    }
}

enum CreationMethod: String, Codable, CaseIterable {
    case guidedSetup, aiAssistant, fromDocument
}

enum CourseCategory: String, Codable, CaseIterable {
    case history, science, technology, language, arts, business, health, mathematics, philosophy, other
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .history: return "clock.fill"
        case .science: return "atom"
        case .technology: return "laptopcomputer"
        case .language: return "textformat"
        case .arts: return "paintbrush.fill"
        case .business: return "briefcase.fill"
        case .health: return "heart.fill"
        case .mathematics: return "x.squareroot"
        case .philosophy: return "brain.head.profile"
        case .other: return "star.fill"
        }
    }
    
    var gradient: [String] {
        switch self {
        case .history: return ["brown", "orange"]
        case .science: return ["green", "blue"]
        case .technology: return ["blue", "purple"]
        case .language: return ["purple", "pink"]
        case .arts: return ["pink", "red"]
        case .business: return ["orange", "yellow"]
        case .health: return ["red", "pink"]
        case .mathematics: return ["blue", "green"]
        case .philosophy: return ["purple", "blue"]
        case .other: return ["gray", "black"]
        }
    }
}

struct CourseAnalytics: Codable, Hashable {
    var totalTimeSpent: TimeInterval = 0
    var averageSessionTime: TimeInterval = 0
    var completionDate: Date?
    var lastAccessedDate: Date?
    var streakDays: Int = 0
    var totalXP: Int = 0
    var weakestTopics: [String] = []
    var strongestTopics: [String] = []
    var studySessionCount: Int = 0
}

struct Course: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var topic: String
    var difficulty: Difficulty
    var pace: Pace
    var creationMethod: CreationMethod
    var lessons: [Lesson]
    var createdAt: Date
    
    // Enhanced metadata
    var overview: String
    var learningObjectives: [String]
    var whoIsThisFor: String
    var estimatedTime: String
    var category: CourseCategory
    var tags: [String]
    var thumbnail: String? // URL or asset name for course cover
    var analytics: CourseAnalytics
    
    // Learning path connections
    var prerequisiteCourses: [UUID] = []
    var nextRecommendedCourses: [UUID] = []
    
    // Social features
    var isPublic: Bool = false
    var createdByUserId: String?
    var rating: Double = 0.0
    var reviewCount: Int = 0
    
    // Offline support
    var isDownloaded: Bool = false
    var downloadDate: Date?
    
    init(id: UUID, title: String, topic: String, difficulty: Difficulty, pace: Pace, creationMethod: CreationMethod, lessons: [Lesson], createdAt: Date, overview: String = "", learningObjectives: [String] = [], whoIsThisFor: String = "", estimatedTime: String = "", category: CourseCategory = .other, tags: [String] = [], thumbnail: String? = nil) {
        self.id = id
        self.title = title
        self.topic = topic
        self.difficulty = difficulty
        self.pace = pace
        self.creationMethod = creationMethod
        self.lessons = lessons
        self.createdAt = createdAt
        self.overview = overview
        self.learningObjectives = learningObjectives
        self.whoIsThisFor = whoIsThisFor
        self.estimatedTime = estimatedTime
        self.category = category
        self.tags = tags
        self.thumbnail = thumbnail
        self.analytics = CourseAnalytics()
    }
    
    // Computed properties
    var progress: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(lessons.filter { $0.isCompleted }.count) / Double(lessons.count)
    }
    
    var isCompleted: Bool {
        !lessons.isEmpty && lessons.allSatisfy { $0.isCompleted }
    }
    
    var currentLesson: Lesson? {
        lessons.first { $0.isCurrent } ?? lessons.first { !$0.isCompleted }
    }
    
    var completedLessonsCount: Int {
        lessons.filter { $0.isCompleted }.count
    }
    
    var totalXP: Int {
        completedLessonsCount * 10
    }
    
    var estimatedDuration: String {
        let totalMinutes = lessons.count * 15 // Assume 15 min per lesson
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
