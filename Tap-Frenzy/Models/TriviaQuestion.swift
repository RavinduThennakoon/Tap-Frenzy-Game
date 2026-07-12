//
//  TriviaQuestion.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let allAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question).htmlDecoded.trimmingCharacters(in: .whitespaces)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer).htmlDecoded.trimmingCharacters(in: .whitespaces)
        incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers).map { $0.htmlDecoded.trimmingCharacters(in: .whitespaces) }

        let answers = (incorrectAnswers + [correctAnswer]).shuffled()
        var unique: [String] = []
        var seenLowercase: Set<String> = []

        for answer in answers {
            let normalized = answer.lowercased().trimmingCharacters(in: .whitespaces)
            if !seenLowercase.contains(normalized) {
                seenLowercase.insert(normalized)
                unique.append(answer)
            }
        }

        allAnswers = unique
    }
}
