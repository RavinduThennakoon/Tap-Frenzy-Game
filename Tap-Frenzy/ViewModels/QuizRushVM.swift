//
//  QuizRushVM.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation
import Combine

enum QuizState {
    case loading
    case loaded
    case failed
}

@MainActor
class QuizRushVM: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .loading
    @Published var lastAnswerCorrect: Bool?
    @Published var selectedAnswer: String?

    private let service = TriviaService()

    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        currentIndex >= questions.count
    }

    func load() async {
        state = .loading
        do {
            questions = try await service.fetchQuestions()
            currentIndex = 0
            score = 0
            streak = 0
            state = .loaded
        } catch {
            state = .failed
        }
    }

    func answer(_ selected: String) {
        guard let question = currentQuestion else { return }
        let correct = selected == question.correctAnswer

        selectedAnswer = selected
        lastAnswerCorrect = correct

        if correct {
            streak += 1
            score += 10 + (streak >= 3 ? 5 : 0)
        } else {
            streak = 0
            score = max(0, score - 5)
        }

        // pause briefly so the color feedback is visible before moving on
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.currentIndex += 1
            self.selectedAnswer = nil
        }
    }
}
