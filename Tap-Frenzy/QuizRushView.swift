//
//  QuizRushView.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            switch vm.state {
            case .loading:
                ProgressView("Loading questions...")

            case .failed:
                VStack(spacing: 12) {
                    Text("Couldn't load questions")
                        .font(.headline)
                    Button("Retry") {
                        Task { await vm.load() }
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .loaded:
                if vm.isFinished {
                    resultView
                } else if let question = vm.currentQuestion {
                    quizView(for: question)
                }
            }
        }
        .padding()
        .navigationTitle("Quiz Rush")
        .task {
            await vm.load()
        }
    }

    private func quizView(for question: TriviaQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Q\(vm.currentIndex + 1)/\(vm.questions.count)")
                Spacer()
                Text("Score: \(vm.score)")
                Spacer()
                Text("Streak: \(vm.streak)")
            }
            .font(.headline)

            Text(question.question)
                .font(.title3.bold())
                .padding(.vertical, 8)

            ForEach(question.allAnswers, id: \.self) { answer in
                Button(answer) {
                    withAnimation {
                        vm.answer(answer)
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: 12) {
            Text("Round Over")
                .font(.title.bold())
            Text("Final Score: \(vm.score)")
                .font(.title2)

            HStack(spacing: 16) {
                Button("Play Again") {
                    Task { await vm.load() }
                }
                .buttonStyle(.borderedProminent)

                Button("Home") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    QuizRushView()
}
