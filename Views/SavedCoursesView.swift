import SwiftUI

struct SavedCoursesView: View {
    @EnvironmentObject private var stats: LearningStatsManager
    @EnvironmentObject private var navManager: NavigationManager
    @StateObject private var recommendationManager: RecommendationManager
    
    @State private var path = NavigationPath()
    @State private var searchText = ""
    @State private var selectedCategory: CourseCategory? = nil
    @State private var selectedFilter: CourseFilter = .all
    @State private var showingRecommendations = false
    @State private var animateEntry = false
    
    enum CourseFilter: String, CaseIterable {
        case all = "All"
        case inProgress = "In Progress"
        case completed = "Completed"
        case new = "New"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .inProgress: return "clock.fill"
            case .completed: return "checkmark.circle.fill"
            case .new: return "sparkles"
            }
        }
    }
    
    init() {
        // Initialize with dependency injection
        _recommendationManager = StateObject(wrappedValue: RecommendationManager(analytics: LearningStatsManager()))
    }
    
    var body: some View {
        NavigationStack(path: $path) {
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
                
                VStack(spacing: 0) {
                    // Enhanced Header
                    ModernCoursesHeader(
                        searchText: $searchText,
                        showingRecommendations: $showingRecommendations
                    )
                    
                    if stats.courses.isEmpty {
                        EmptyStateView()
                            .environmentObject(recommendationManager)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                // Quick stats
                                QuickStatsSection()
                                    .environmentObject(stats)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                                
                                // Filter tabs
                                FilterTabsView(selectedFilter: $selectedFilter)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                                
                                // Category filter
                                if selectedFilter == .all {
                                    CategoryFilterView(selectedCategory: $selectedCategory)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 16)
                                }
                                
                                // Recommendations section (if showing)
                                if showingRecommendations {
                                    RecommendationsSection()
                                        .environmentObject(recommendationManager)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 24)
                                }
                                
                                // Courses grid
                                CoursesGridView(
                                    courses: filteredCourses,
                                    onCourseTap: { course in
                                        path.append(course)
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Course.self) { course in
                LessonMapView(course: course)
            }
            .onAppear {
                animateEntry = true
                recommendationManager.generateRecommendations()
            }
        }
    }
    
    private var filteredCourses: [Course] {
        var courses = stats.courses
        
        // Apply text search
        if !searchText.isEmpty {
            courses = courses.filter { course in
                course.title.localizedCaseInsensitiveContains(searchText) ||
                course.topic.localizedCaseInsensitiveContains(searchText) ||
                course.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            courses = courses.filter { $0.category == category }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .inProgress:
            courses = courses.filter { !$0.isCompleted && $0.progress > 0 }
        case .completed:
            courses = courses.filter { $0.isCompleted }
        case .new:
            courses = courses.filter { $0.progress == 0 }
        }
        
        return courses.sorted { first, second in
            // Sort by last accessed, then by creation date
            if let firstAccess = first.analytics.lastAccessedDate,
               let secondAccess = second.analytics.lastAccessedDate {
                return firstAccess > secondAccess
            }
            return first.createdAt > second.createdAt
        }
    }
}

// MARK: - Modern Header
private struct ModernCoursesHeader: View {
    @Binding var searchText: String
    @Binding var showingRecommendations: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and actions
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Courses")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Continue your learning journey")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Actions
                HStack(spacing: 12) {
                    Button(action: { showingRecommendations.toggle() }) {
                        Image(systemName: showingRecommendations ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(showingRecommendations ? .pink : .white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(22)
                    }
                    
                    NavigationLink(destination: TopicInputView()) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .cornerRadius(22)
                    }
                }
            }
            
            // Search bar
            SearchBarView(searchText: $searchText)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Search Bar
private struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            TextField("Search courses...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Quick Stats
private struct QuickStatsSection: View {
    @EnvironmentObject private var stats: LearningStatsManager
    
    var body: some View {
        HStack(spacing: 16) {
            QuickStatCard(
                title: "Total Courses",
                value: "\(stats.courses.count)",
                icon: "books.vertical.fill",
                color: .blue
            )
            
            QuickStatCard(
                title: "Completed",
                value: "\(stats.courses.filter { $0.isCompleted }.count)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            QuickStatCard(
                title: "In Progress",
                value: "\(stats.courses.filter { !$0.isCompleted && $0.progress > 0 }.count)",
                icon: "clock.fill",
                color: .orange
            )
        }
    }
}

private struct QuickStatCard: View {
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
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Filter Tabs
private struct FilterTabsView: View {
    @Binding var selectedFilter: SavedCoursesView.CourseFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SavedCoursesView.CourseFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        onTap: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct FilterTab: View {
    let filter: SavedCoursesView.CourseFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.white.opacity(0.1))
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Category Filter
private struct CategoryFilterView: View {
    @Binding var selectedCategory: CourseCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryChip(
                    category: nil,
                    isSelected: selectedCategory == nil,
                    onTap: { selectedCategory = nil }
                )
                
                ForEach(CourseCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct CategoryChip: View {
    let category: CourseCategory?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: 12, weight: .medium))
                    Text(category.displayName)
                        .font(.system(size: 12, weight: .medium))
                } else {
                    Text("All")
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple : Color.white.opacity(0.1))
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Recommendations Section
private struct RecommendationsSection: View {
    @EnvironmentObject private var recommendationManager: RecommendationManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to full recommendations
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recommendationManager.dailyRecommendations) { recommendation in
                        RecommendationCard(recommendation: recommendation)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct RecommendationCard: View {
    let recommendation: CourseRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and difficulty badges
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: recommendation.course.category.icon)
                        .font(.system(size: 10))
                    Text(recommendation.course.category.displayName)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(recommendation.course.category.gradient[0]).opacity(0.3))
                .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: recommendation.course.difficulty.icon)
                        .font(.system(size: 10))
                    Text(recommendation.course.difficulty.rawValue)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(recommendation.course.difficulty.color).opacity(0.3))
                .cornerRadius(8)
            }
            
            // Title
            Text(recommendation.course.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
            
            // Reason
            Text(recommendation.reason)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            // Duration and lessons
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(recommendation.course.estimatedDuration)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "book")
                        .font(.system(size: 10))
                    Text("\(recommendation.course.lessons.count) lessons")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.gray)
            }
            
            // Add button
            Button("Add Course") {
                // Add course to user's collection
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(16)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Courses Grid
private struct CoursesGridView: View {
    let courses: [Course]
    let onCourseTap: (Course) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(courses.indices, id: \.self) { index in
                ModernCourseCard(
                    course: courses[index],
                    position: index,
                    onTap: { onCourseTap(courses[index]) }
                )
            }
        }
    }
}

// MARK: - Modern Course Card
private struct ModernCourseCard: View {
    let course: Course
    let position: Int
    let onTap: () -> Void
    
    @State private var animateEntry = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with category and progress
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: course.category.icon)
                            .font(.system(size: 10))
                        Text(course.category.displayName)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(course.category.gradient[0]).opacity(0.3))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    CircularProgressView(progress: course.progress)
                }
                
                // Title
                Text(course.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Progress info
                HStack(spacing: 8) {
                    Text("\(course.completedLessonsCount)/\(course.lessons.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("lessons")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if course.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    } else if course.progress > 0 {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
                
                // Bottom stats
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(course.estimatedDuration)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("\(course.totalXP)")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: course.difficulty.icon)
                            .font(.system(size: 10))
                        Text(course.difficulty.rawValue)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color(course.difficulty.color))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(cardBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .scaleEffect(animateEntry ? 1.0 : 0.8)
            .opacity(animateEntry ? 1.0 : 0.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                .delay(Double(position) * 0.05),
                value: animateEntry
            )
            .onAppear {
                animateEntry = true
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture { pressed in
            isPressed = pressed
        }
    }
    
    private var cardBackground: Color {
        if course.isCompleted {
            return Color.green.opacity(0.1)
        } else if course.progress > 0 {
            return Color.blue.opacity(0.1)
        } else {
            return Color.white.opacity(0.05)
        }
    }
    
    private var cardBorder: Color {
        if course.isCompleted {
            return Color.green.opacity(0.3)
        } else if course.progress > 0 {
            return Color.blue.opacity(0.3)
        } else {
            return Color.white.opacity(0.1)
        }
    }
}

// MARK: - Support Views
private struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            if progress == 1.0 {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.green)
            } else {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// Enhanced Empty State
private struct EmptyStateView: View {
    @EnvironmentObject private var recommendationManager: RecommendationManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration
            VStack(spacing: 16) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue.opacity(0.8))
                
                Text("Start Your Learning Journey")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Create your first course and begin exploring topics that interest you.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Action buttons
            VStack(spacing: 16) {
                NavigationLink(destination: TopicInputView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Create Your First Course")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                // Sample recommendations
                if !recommendationManager.dailyRecommendations.isEmpty {
                    Text("Or explore these trending topics:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        ForEach(recommendationManager.dailyRecommendations.prefix(3), id: \.id) { recommendation in
                            Button(recommendation.course.title) {
                                // Add recommended course
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()
            Spacer()
        }
    }
}



struct SavedCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = LearningStatsManager()
        // Example courses for preview
        let course1 = Course(id: UUID(), title: "World War 2", topic: "WW2", difficulty: .beginner, pace: .balanced, creationMethod: .aiAssistant, lessons: [], createdAt: Date())
        let course2 = Course(id: UUID(), title: "The Roman Empire", topic: "Rome", difficulty: .intermediate, pace: .balanced, creationMethod: .aiAssistant, lessons: [], createdAt: Date())
        manager.addCourse(course1)
        manager.addCourse(course2)
        
        return SavedCoursesView()
            .environmentObject(manager)
            .environmentObject(NavigationManager())
            .preferredColorScheme(.dark)
    }
}
