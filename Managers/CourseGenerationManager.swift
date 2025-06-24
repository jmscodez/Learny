import SwiftUI
import Combine

@MainActor
final class CourseGenerationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isGenerating: Bool = false
    @Published var generationProgress: Double = 0.0
    @Published var generatedCourse: Course?
    @Published var errorMessage: String?
    @Published var statusMessage: String = "Getting started..."

    // MARK: - Private Properties
    private let aiService = OpenAIService.shared
    private var generationTask: Task<Void, Error>?

    // MARK: - Public Methods
    
    /// Starts the asynchronous course generation process.
    func generateCourse(topic: String, suggestions: [LessonSuggestion], difficulty: Difficulty, pace: Pace, statsManager: LearningStatsManager, notificationsManager: NotificationsManager) {
        // Reset state from any previous generation
        resetState()
        isGenerating = true

        generationTask = Task {
            do {
                var generatedLessons: [Lesson] = []
                let lessonTitles = suggestions.map { $0.title }
                let checkpointInterval = 3 // Add a quiz after every 3 lessons

                // Step 1: Generate course metadata
                statusMessage = "Designing course structure..."
                let metadata = await aiService.generateCourseMetadata(for: topic, lessonTitles: lessonTitles)
                await updateProgress(to: 0.1)

                // Step 2: Generate detailed content for each lesson suggestion
                for (index, suggestion) in suggestions.enumerated() {
                    let lessonIndex = Double(index + 1)
                    let totalLessons = Double(suggestions.count)
                    
                    statusMessage = "Creating lesson \(index + 1): \(suggestion.title)..."
                    // The new AI service call that generates all screens for a lesson at once.
                    let screens = await aiService.generateLessonScreens(for: suggestion.title, topic: topic)
                    
                    // A lesson needs at least one screen to be valid.
                    guard !screens.isEmpty else { continue }
                    
                    // Create a new lesson with the generated screens.
                    let newLesson = Lesson(
                        title: suggestion.title,
                        lessonNumber: index + 1,
                        screens: screens,
                        isCurrent: generatedLessons.isEmpty // First lesson is the current one.
                    )
                    generatedLessons.append(newLesson)
                    
                    // Update progress after each lesson is fully generated.
                    await updateProgress(to: 0.1 + (0.8 * (lessonIndex / totalLessons)))
                }
                
                guard !generatedLessons.isEmpty else {
                    throw GenerationError.contentFailed
                }

                // Step 3: Assemble the final course
                statusMessage = "Finalizing your course..."
                let newCourse = Course(
                    id: UUID(),
                    title: topic,
                    topic: topic,
                    difficulty: difficulty,
                    pace: pace,
                    creationMethod: .aiAssistant,
                    lessons: generatedLessons,
                    createdAt: Date(),
                    overview: metadata?.overview ?? "A fantastic course about \(topic).",
                    learningObjectives: metadata?.learningObjectives ?? [],
                    whoIsThisFor: metadata?.whoIsThisFor ?? "Anyone interested in \(topic).",
                    estimatedTime: metadata?.estimatedTime ?? "45-60 minutes"
                )
                
                // Step 4: Save and publish the result
                statsManager.addCourse(newCourse)
                await updateProgress(to: 1.0)
                statusMessage = "Done!"
                
                // Wait a moment on the "Done!" message before finishing
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                self.generatedCourse = newCourse
                self.isGenerating = false
                
                // Schedule a notification in case the user has backgrounded the app
                notificationsManager.scheduleCourseReadyNotification(courseName: topic)

            } catch {
                self.errorMessage = "Something went wrong during generation. Please try again."
                self.isGenerating = false
            }
        }
    }
    
    /// Cancels the ongoing generation task.
    func cancelGeneration() {
        generationTask?.cancel()
        isGenerating = false
        statusMessage = "Generation cancelled."
    }
    
    // MARK: - Private Helpers
    
    private func updateProgress(to value: Double) async {
        self.generationProgress = value
    }
    
    private func resetState() {
        isGenerating = false
        generationProgress = 0.0
        generatedCourse = nil
        errorMessage = nil
        statusMessage = "Getting started..."
        generationTask = nil
    }
}

enum GenerationError: Error {
    case suggestionFailed
    case contentFailed
} 