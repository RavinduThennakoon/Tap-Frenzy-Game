import SwiftUI
import Combine
import CoreLocation

private enum TapFrenzyPalette {
    static let background = Color(red: 0.05, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.12, green: 0.16, blue: 0.28)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
    static let success = Color.green
    static let danger = Color.red
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct TapFrenzyView: View {
    // MARK: - Game State
    @AppStorage("tapFrenzy_highScore") private var highScore = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    @Environment(\.dismiss) private var dismiss
    @State private var isBonusColor = true
    @State private var colorSwitchCounter = 0
    @State private var score = 0

    // A timer that fires once per second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            TapFrenzyPalette.background.ignoresSafeArea()

            if isGameOver {
                gameOverView
            } else {
                gameView
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.gray)
    }

    var gameView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Tap Frenzy")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Tap fast while the timer counts down. Bonus taps reward you, penalties cost you.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            HStack(spacing: 14) {
                hudChip(icon: "star.fill", label: "Score", value: "\(score)")
                hudChip(icon: "clock.fill", label: "Time", value: "\(timeRemaining)s")
                hudChip(icon: "sparkles", label: "Best", value: "\(highScore)")
            }
            .padding(.horizontal)

            bonusBanner

            Spacer()

            Button(action: {
                if isBonusColor {
                    score += 1
                } else {
                    score = max(0, score - 1)
                }
            }) {
                Text("TAP")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 190, height: 190)
                    .background(isBonusColor ? TapFrenzyPalette.accent : Color.gray.opacity(0.30))
                    .clipShape(Circle())
                    .shadow(color: isBonusColor ? TapFrenzyPalette.accent.opacity(0.45) : Color.black.opacity(0.22), radius: 20, x: 0, y: 14)
            }
            .buttonStyle(PressableButtonStyle())

            Spacer()
        }
        .padding(.vertical)
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1

                colorSwitchCounter += 1
                if colorSwitchCounter >= 3 {
                    isBonusColor.toggle()
                    colorSwitchCounter = 0
                }
            } else {
                endGame()
            }
        }
    }

    private var bonusBanner: some View {
        HStack {
            Image(systemName: isBonusColor ? "arrow.up.right" : "minus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text(isBonusColor ? "Bonus +1" : "Penalty -1")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .background(isBonusColor ? TapFrenzyPalette.success.opacity(0.95) : TapFrenzyPalette.danger.opacity(0.95))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
    }

    private func hudChip(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(TapFrenzyPalette.surface)
        .cornerRadius(18)
    }

    var gameOverView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(TapFrenzyPalette.accent)
                Text("Game Over")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Final score")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, design: .rounded))
            }

            Text("\(score)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(TapFrenzyPalette.accent)

            Text(score >= highScore ? "New high score!" : "High score: \(highScore)")
                .foregroundColor(score >= highScore ? TapFrenzyPalette.success : .gray)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            HStack(spacing: 16) {
                Button("Play Again") {
                    resetGame()
                }
                .buttonStyle(.borderedProminent)
                .tint(TapFrenzyPalette.accent)

                Button("Home") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }

            ShareLink(item: "I just scored \(score) on Tap Frenzy — beat that!") {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .foregroundColor(.gray)
            .font(.system(size: 15, design: .rounded))

            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(TapFrenzyPalette.surface)
        .cornerRadius(28)
        .padding()
        .shadow(color: Color.black.opacity(0.30), radius: 20, x: 0, y: 20)
    }

    // MARK: - Logic
    func endGame() {
        if score > highScore {
            highScore = score
        }
        isGameOver = true

        LocationService.shared.requestLocation { loc in
            let session = GameSession(
                mode: .tapFrenzy,
                score: score,
                latitude: loc?.coordinate.latitude ?? 0,
                longitude: loc?.coordinate.longitude ?? 0
            )
            SessionStore.shared.add(session)
        }
    }

    func resetGame() {
        score = 0
        timeRemaining = 10
        isGameOver = false
    }
}

#Preview {
    TapFrenzyView()
}
