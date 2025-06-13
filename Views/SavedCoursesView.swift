import SwiftUI

struct SavedCoursesView: View {
    @EnvironmentObject private var stats: LearningStatsManager
    
    // State for multi-selection
    @State private var isSelecting = false
    @State private var selectedCourseIDs = Set<UUID>()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Courses")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button(isSelecting ? "Cancel" : "Select") {
                        isSelecting.toggle()
                        // Clear selection when exiting selection mode
                        if !isSelecting {
                            selectedCourseIDs.removeAll()
                        }
                    }
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 12)

                if stats.courses.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(stats.courses) { course in
                            CourseRow(
                                course: course,
                                isSelected: selectedCourseIDs.contains(course.id),
                                isSelecting: isSelecting
                            )
                            .onTapGesture {
                                if isSelecting {
                                    toggleSelection(for: course)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            // Standard swipe-to-delete, disabled in selection mode
                            if !isSelecting {
                            stats.deleteCourses(at: indexSet)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                        .listRowBackground(Color.black)
                    }
                    .listStyle(.plain)
                }
                
                // "Delete Selected" button appears when selecting
                if isSelecting {
                    deleteButton
                        .padding(.horizontal, 24)
                        .padding(.vertical)
            }
        }
        }
    }
    
    private var deleteButton: some View {
        Button(action: deleteSelectedCourses) {
            Text("Delete Selected (\(selectedCourseIDs.count))")
                .font(.headline)
                .foregroundColor(selectedCourseIDs.isEmpty ? .gray : .white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedCourseIDs.isEmpty ? Color.gray.opacity(0.4) : Color.red)
                .cornerRadius(16)
        }
        .disabled(selectedCourseIDs.isEmpty)
        .animation(.easeInOut, value: selectedCourseIDs.isEmpty)
    }
    
    private func toggleSelection(for course: Course) {
        if selectedCourseIDs.contains(course.id) {
            selectedCourseIDs.remove(course.id)
        } else {
            selectedCourseIDs.insert(course.id)
        }
    }
    
    private func deleteSelectedCourses() {
        // Find the IndexSet corresponding to the selected IDs
        let indicesToDelete = stats.courses.indices.filter {
            selectedCourseIDs.contains(stats.courses[$0].id)
        }
        
        if !indicesToDelete.isEmpty {
            stats.deleteCourses(at: IndexSet(indicesToDelete))
        }

        // Reset selection state
        selectedCourseIDs.removeAll()
        isSelecting = false
    }
}

// The new Empty State View, extracted for clarity
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.8))
            
            Text("No Courses Yet")
                .font(.title2).bold()
                .foregroundColor(.white)
            
            Text("Start your learning journey on the Learn tab.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// A new view for the row to handle its own navigation and selection display
private struct CourseRow: View {
    let course: Course
    let isSelected: Bool
    let isSelecting: Bool
    
    var body: some View {
        ZStack {
            // The NavigationLink is in the background, making the whole row tappable
            // without showing a disclosure arrow (">"). It's disabled during selection.
            NavigationLink(destination: LessonMapView(course: course)) {
                EmptyView()
            }
            .opacity(0)
            .disabled(isSelecting)
            
            HStack(spacing: 12) {
                // Checkmark appears during selection mode
                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .gray)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
                
                CourseCard(course: course)
            }
        }
    }
}

private struct CourseCard: View {
    let course: Course

    private var progress: Double {
        guard !course.lessons.isEmpty else { return 0 }
        return Double(course.lessons.filter(\.isComplete).count) / Double(course.lessons.count)
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(course.title.capitalized)
                    .font(.headline)
                    .foregroundColor(.white)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 8)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: (UIScreen.main.bounds.width - 150) * CGFloat(progress), height: 8)
                        .foregroundColor(.blue)
                }

                Text("\(Int(progress * 100))% • \(course.lessons.filter(\.isComplete).count)/\(course.lessons.count) lessons")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

                Text("0 XP")
                    .font(.caption2)
                .fontWeight(.bold)
                .padding(8)
                    .background(Color.purple)
                    .cornerRadius(8)
                    .foregroundColor(.white)
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(16)
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
            .preferredColorScheme(.dark)
    }
}
