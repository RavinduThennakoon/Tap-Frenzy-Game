import SwiftUI

private enum ResultPalette {
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
}

struct ResultView: View {
    let score: Int
    let gameMode: String
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ResultPalette.accent)

                Text("Game Over")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text(gameMode)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 10) {
                Text("Final Score")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                Text(String(score))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(ResultPalette.accent)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(ResultPalette.surface)
            .cornerRadius(20)

            HStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(ResultPalette.accent)

                Button(action: onHome) {
                    Label("Home", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
        }
        .padding()
        .background(ResultPalette.surface)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.28), radius: 18, x: 0, y: 14)
        .padding(.horizontal)
    }
}

#Preview {
    ResultView(score: 150, gameMode: "Quiz Rush", onPlayAgain: {}, onHome: {})
}
