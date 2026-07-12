//
//  TriviaService.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation

enum TriviaError: Error {
    case badResponse
    case decodingFailed
}

struct TriviaService {
    func fetchQuestions() async throws -> [TriviaQuestion] {
        let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TriviaError.badResponse
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return decoded.results
        } catch {
            throw TriviaError.decodingFailed
        }
    }
}
