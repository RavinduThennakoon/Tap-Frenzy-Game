//
//  QuizRushView.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//
import SwiftUI

struct QuizRushView: View {
    var body: some View {
        Text("Quiz Rush coming soon")
            .task {
                do {
                    let qs = try await TriviaService().fetchQuestions()
                    print(qs.count, qs.first?.question ?? "")
                } catch {
                    print("error: \(error)")
                }
            }
    }
}
