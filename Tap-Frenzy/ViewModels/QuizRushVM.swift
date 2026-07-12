//
//  QuizRushVM.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation
import Combine
import CoreLocation

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
    @Published var lastAnswerCorrect: Bool? = nil
    @Published var selectedAnswerIndex: Int? = nil

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
            selectedAnswerIndex = nil
            state = .loaded
        } catch {
            print("Error loading questions: \(error)")
            state = .failed
        }
    }

    func answer(_ selected: String) {
        guard let question = currentQuestion else { return }
        
        // Find selected answer index
        let selectedIndex = question.allAnswers.firstIndex { $0 == selected }
        let correctIndex = question.allAnswers.firstIndex { $0 == question.correctAnswer }
        
        selectedAnswerIndex = selectedIndex
        
        let isCorrect = (selectedIndex == correctIndex)
        lastAnswerCorrect = isCorrect

        if isCorrect {
            streak += 1
            // Bonus points for 3+ streak
            let bonus = streak >= 3 ? 5 : 0
            score += 10 + bonus
        } else {
            streak = 0
            score = max(0, score - 5)
        }

        // Pause to show color feedback before advancing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.currentIndex += 1

            if self.currentIndex >= self.questions.count {
                LocationService.shared.requestLocation()
                let loc = LocationService.shared.lastLocation
                let session = GameSession(
                    mode: .quizRush,
                    score: self.score,
                    latitude: loc?.coordinate.latitude ?? 0,
                    longitude: loc?.coordinate.longitude ?? 0
                )
                SessionStore.shared.add(session)
            }

            self.selectedAnswerIndex = nil
        }
    }
}

