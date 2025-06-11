//
//  OpenAIService.swift
//  Learny
//
//  Created by Jake Stoltz on 6/11/25.
//

import Foundation

final class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey = "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"
    private let model  = "meta-llama/llama-4-scout"
    private init() {}

    func generateLessons(for courseSetup: Course) async throws -> [Lesson] {
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an AI assistant that generates structured course outlines."],
            ["role": "user",   "content": "Generate a lesson outline for a course about \(courseSetup.topic) with difficulty \(courseSetup.difficulty.rawValue) and pace \(courseSetup.pace.rawValue)."]
        ]
        let payload: [String: Any] = [
            "model": model,
            "messages": messages
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        // TODO: parse `data` into [Lesson]
        return []
    }
}
