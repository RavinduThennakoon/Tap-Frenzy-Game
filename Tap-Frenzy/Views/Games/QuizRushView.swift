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
        NavigationStack {
            VStack(spacing: 20) {
                switch vm.state {
                case .loading:
                    ProgressView("Loading trivia questions...")

                case .failed:
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("Couldn't load questions")
                            .font(.headline)
                        Text("Check your internet connection")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button(action: {
                            Task { await vm.load() }
                        }) {
                            Label("Retry", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

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
            .navigationBarTitleDisplayMode(.inline)
        }
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

            ForEach(Array(question.allAnswers.enumerated()), id: \.offset) { index, answer in
                Button(action: {
                    vm.answer(answer)
                }) {
                    HStack(spacing: 12) {
                        Text(answer)
                            .lineLimit(2)
                        Spacer()
                        if vm.selectedAnswerIndex != nil {
                            let correctIndex = question.allAnswers.firstIndex { $0 == question.correctAnswer }
                            if index == correctIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                            } else if index == vm.selectedAnswerIndex && vm.selectedAnswerIndex != correctIndex {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(backgroundColorFor(index: index, question: question))
                .foregroundStyle(.white)
                .font(.headline.bold())
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                )
                .disabled(vm.selectedAnswerIndex != nil)
            }
        }
    }

    private func backgroundColorFor(index: Int, question: TriviaQuestion) -> Color {
        guard let selectedIndex = vm.selectedAnswerIndex else {
            return Color.blue.opacity(0.6)
        }
        
        let correctIndex = question.allAnswers.firstIndex { $0 == question.correctAnswer }
        let isCorrectAnswer = (index == correctIndex)
        let isSelectedAnswer = (index == selectedIndex)
        
        // Green = correct answer
        if isCorrectAnswer {
            return Color.green.opacity(0.85)
        }
        
        // Red = wrong answer clicked
        if isSelectedAnswer && !isCorrectAnswer {
            return Color.red.opacity(0.85)
        }
        
        // Gray = unselected
        return Color.gray.opacity(0.35)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Quiz Complete!")
                    .font(.title.bold())
            }
            .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                Text(String(vm.score))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("\(vm.questions.count) questions")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            HStack(spacing: 12) {
                Button(action: {
                    Task { await vm.load() }
                }) {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    dismiss()
                }) {
                    Label("Home", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            ShareLink(item: "I just scored \(vm.score) on Quiz Rush — beat that!")
            .padding(.top, 4)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    QuizRushView()
}
