import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @StateObject private var vm: LessonDetailViewModel

    init(lesson: Lesson) {
        self.lesson = lesson
        _vm = StateObject(wrappedValue: LessonDetailViewModel(lesson: lesson))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(lesson.contentBlocks.indices, id: \.self) { idx in
                    switch lesson.contentBlocks[idx] {
                    case .text(let str):
                        Text(str)
                            .padding()

                    case .dialogue(let lines):
                        ForEach(lines, id: \.id) { line in
                            HStack {
                                Text("\(line.speaker):").bold()
                                Text(line.text)
                            }
                            .padding(.horizontal)
                        }

                    case .matching(let game):
                        Text("Matching Game: \(game.pairs.count) pairs")
                            .italic()
                            .padding()
                    }
                }

                QuizView(questions: lesson.quiz)
            }
            .padding()
        }
        .navigationTitle(lesson.title)
    }
}
