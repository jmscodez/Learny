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
        
        // Store reference to managers to prevent deallocation
        let statsManager = statsManager
        let notificationsManager = notificationsManager

        // Use unstructured task to prevent cancellation when views dismiss
        // Store the task to prevent it from being deallocated
        generationTask = Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            
            do {
                let lessonTitles = suggestions.map { $0.title }

                // Step 1: Generate course metadata
                self.statusMessage = "Designing course structure..."
                let metadata = await self.aiService.generateCourseMetadata(for: topic, lessonTitles: lessonTitles)
                await self.updateProgress(to: 0.1)

                // Step 2: Generate detailed content for each lesson suggestion (PARALLEL)
                self.statusMessage = "Generating all lessons simultaneously..."
                var completedLessons = 0
                let totalLessons = suggestions.count
                
                // Use TaskGroup to generate all lessons in parallel
                let generatedLessons: [Lesson] = await withTaskGroup(of: (Int, Lesson?).self) { group in
                    // Start a task for each lesson
                    for (index, suggestion) in suggestions.enumerated() {
                        group.addTask { [weak self] in
                            do {
                                // Check if task was cancelled
                                try Task.checkCancellation()
                                
                                // Generate lesson screens
                                let screens = await self?.aiService.generateLessonScreens(
                                    for: suggestion.title, 
                                    topic: topic, 
                                    difficulty: difficulty, 
                                    pace: pace
                                )
                                
                                // A lesson needs at least one screen to be valid
                                guard let screens = screens, !screens.isEmpty else { 
                                    return (index, nil) 
                                }
                                
                                // Create the lesson
                                let newLesson = Lesson(
                                    title: suggestion.title,
                                    lessonNumber: index + 1,
                                    screens: screens,
                                    isCurrent: index == 0 // First lesson is the current one
                                )
                                
                                return (index, newLesson)
                            } catch {
                                print("📱 [GENERATION] Failed to generate lesson \(index + 1): \(error)")
                                return (index, nil)
                            }
                        }
                    }
                    
                    // Collect results and update progress as each lesson completes
                    var lessonResults: [(Int, Lesson?)] = []
                    
                    for await result in group {
                        lessonResults.append(result)
                        completedLessons += 1
                        
                        // Update progress and status as each lesson completes
                        let progressValue = 0.1 + (0.8 * (Double(completedLessons) / Double(totalLessons)))
                        await self.updateProgress(to: progressValue)
                        
                        if let lesson = result.1 {
                            await MainActor.run {
                                self.statusMessage = "Completed lesson: \(lesson.title)"
                            }
                        }
                    }
                    
                    // Sort results by original index and filter out nils
                    return lessonResults
                        .sorted { $0.0 < $1.0 }
                        .compactMap { $0.1 }
                }
                
                guard !generatedLessons.isEmpty else {
                    throw GenerationError.contentFailed
                }

                // Step 3: Assemble the final course
                self.statusMessage = "Finalizing your course..."
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
                await self.updateProgress(to: 1.0)
                
                self.statusMessage = "Done!"
                
                // Wait a moment on the "Done!" message before finishing
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                self.generatedCourse = newCourse
                self.isGenerating = false
                
                // Schedule a notification in case the user has backgrounded the app
                notificationsManager.scheduleCourseReadyNotification(courseName: topic)

            } catch is CancellationError {
                self.statusMessage = "Generation cancelled."
                self.isGenerating = false
                print("📱 [GENERATION] Course generation cancelled")
            } catch {
                print("Course generation error: \(error)")
                self.errorMessage = "Something went wrong during generation. Please try again."
                self.isGenerating = false
                print("📱 [GENERATION] Course generation failed: \(error)")
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