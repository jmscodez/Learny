//
//  PersistenceService.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private let fileURL: URL

    private init() {
        let fm  = FileManager.default
        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent("courses.json")
    }

    func loadCourses() throws -> [Course] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Course].self, from: data)
    }

    func saveCourses(_ courses: [Course]) throws {
        let data = try JSONEncoder().encode(courses)
        try data.write(to: fileURL)
    }
}
