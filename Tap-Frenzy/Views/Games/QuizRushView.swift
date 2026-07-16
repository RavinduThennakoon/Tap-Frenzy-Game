import SwiftUI

private enum QuizRushPalette {
    static let background = Color(red: 0.05, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
    static let inactive = Color(red: 0.16, green: 0.20, blue: 0.30)
}

private struct AnswerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct QuizRushView: View {
    @StateObject private var vm = QuizRushVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            QuizRushPalette.background.ignoresSafeArea()

            content
                .padding()
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            ProgressView("Loading trivia questions...")
                .progressViewStyle(.circular)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed:
            VStack(spacing: 18) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text("Couldn't load questions")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("Check your internet connection and try again.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Button(action: {
                    Task { await vm.load() }
                }) {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .tint(QuizRushPalette.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            if vm.isFinished {
                resultView
            } else if let question = vm.currentQuestion {
                quizView(for: question)
            }
        }
    }

    private func quizView(for question: TriviaQuestion) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                HStack(spacing: 16) {
                    scoreChip(label: "Q", value: "\(vm.currentIndex + 1)/\(vm.questions.count)")
                    scoreChip(label: "Score", value: "\(vm.score)")
                    scoreChip(label: "Streak", value: "\(vm.streak)")
                }

                Text(question.question)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(QuizRushPalette.surface)
                    .cornerRadius(24)
            }

            VStack(spacing: 14) {
                ForEach(Array(question.allAnswers.enumerated()), id: \.offset) { index, answer in
                    Button(action: {
                        vm.answer(answer)
                    }) {
                        HStack(alignment: .top, spacing: 12) {
                            Text(answer)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if vm.selectedAnswerIndex != nil {
                                let correctIndex = question.allAnswers.firstIndex { $0 == question.correctAnswer }
                                if index == correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                } else if index == vm.selectedAnswerIndex && vm.selectedAnswerIndex != correctIndex {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(backgroundColorFor(index: index, question: question))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(AnswerButtonStyle())
                    .disabled(vm.selectedAnswerIndex != nil)
                }
            }

            Spacer()
        }
    }

    private func backgroundColorFor(index: Int, question: TriviaQuestion) -> Color {
        guard let selectedIndex = vm.selectedAnswerIndex else {
            return QuizRushPalette.inactive
        }

        let correctIndex = question.allAnswers.firstIndex { $0 == question.correctAnswer }
        if index == correctIndex {
            return Color.green.opacity(0.88)
        }
        if index == selectedIndex {
            return Color.red.opacity(0.88)
        }
        return Color.gray.opacity(0.25)
    }

    private func scoreChip(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(QuizRushPalette.surface)
        .cornerRadius(18)
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 14) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(QuizRushPalette.accent)
                Text("Quiz Complete!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(spacing: 10) {
                Text("Final Score")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("\(vm.score)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(QuizRushPalette.accent)
                Text("\(vm.questions.count) questions")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(QuizRushPalette.surface)
            .cornerRadius(22)

            HStack(spacing: 12) {
                Button(action: {
                    Task { await vm.load() }
                }) {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(QuizRushPalette.accent)

                Button(action: {
                    dismiss()
                }) {
                    Label("Home", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }

            ShareLink(item: "I just scored \(vm.score) on Quiz Rush — beat that!") {
                Label("Share your score", systemImage: "square.and.arrow.up")
            }
            .foregroundColor(.gray)
            .font(.system(size: 14, design: .rounded))

            Spacer()
        }
        .padding()
        .background(QuizRushPalette.surface)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.30), radius: 18, x: 0, y: 16)
    }
}

#Preview {
    QuizRushView()
}
