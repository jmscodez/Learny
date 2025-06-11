//
//  LearningStatsManager.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Combine
import SwiftUI

final class LearningStatsManager: ObservableObject {
    @Published private(set) var courses: [Course] = []

    init() {
        do {
            courses = try PersistenceService.shared.loadCourses()
        } catch {
            courses = []
        }
    }

    func addCourse(_ course: Course) {
        courses.append(course)
        save()
    }

    func deleteCourses(at offsets: IndexSet) {
        courses.remove(atOffsets: offsets)
        save()
    }

    func updateCourse(_ course: Course) {
        guard let idx = courses.firstIndex(where: { $0.id == course.id }) else { return }
        courses[idx] = course
        save()
    }

    private func save() {
        try? PersistenceService.shared.saveCourses(courses)
    }
}
