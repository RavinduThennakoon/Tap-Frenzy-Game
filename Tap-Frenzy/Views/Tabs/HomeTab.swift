import SwiftUI

private enum HomePalette {
    static let background = Color(red: 0.06, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
    static let text = Color.white
}

private enum HomeMode {
    static func icon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "bolt.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }

    static func subtitle(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "Fast taps, quick reflexes"
        case .lightItUp: return "Match the glowing tiles"
        case .quizRush: return "Trivia speed challenge"
        }
    }

    static func accent(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color.green
        case .lightItUp: return Color.blue
        case .quizRush: return Color.orange
        }
    }
}

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            ZStack {
                HomePalette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        VStack(spacing: 10) {
                            Text("Choose a game mode")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(HomePalette.text)
                                .multilineTextAlignment(.center)

                            Text("Three arcade mini-games, one polished hub. Pick a mode and jump in.")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)

                        VStack(spacing: 16) {
                            modeCard(title: "Tap Frenzy", mode: .tapFrenzy)
                            modeCard(title: "Light It Up", mode: .lightItUp)
                            modeCard(title: "Quiz Rush", mode: .quizRush)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.gray)
        }
    }

    private func modeCard(title: String, mode: GameMode) -> some View {
        NavigationLink(destination: destination(for: mode)) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(mode == .tapFrenzy ? Color.green.opacity(0.2) : mode == .lightItUp ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Image(systemName: HomeMode.icon(for: mode))
                        .font(.system(size: 26))
                        .foregroundColor(HomeMode.accent(for: mode))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(HomePalette.text)
                    Text(HomeMode.subtitle(for: mode))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(HomePalette.surface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destination(for mode: GameMode) -> some View {
        switch mode {
        case .tapFrenzy: TapFrenzyView()
        case .lightItUp: LightItUpView()
        case .quizRush: QuizRushView()
        }
    }
}

#Preview {
    HomeTab()
}
