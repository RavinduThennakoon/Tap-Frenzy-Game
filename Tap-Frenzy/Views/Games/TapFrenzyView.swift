import SwiftUI
import Combine
import CoreLocation

struct TapFrenzyView: View {
    // MARK: - Game State
    @AppStorage("tapFrenzy_highScore") private var highScore = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    @State private var highScore = 0
    @Environment(\.dismiss) private var dismiss
    @State private var isBonusColor = true
    @State private var colorSwitchCounter = 0

    // A timer that fires once per second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if isGameOver {
            gameOverView
        } else {
            gameView
        }
    }

    // MARK: - Main Game Screen
    var gameView: some View {
        VStack(spacing: 40) {
            Text("Tap Frenzy")
                .font(.largeTitle)
                .bold()

            Text("Score: \(score)")
                .font(.title2)

            Text("Time: \(timeRemaining)")
                .font(.title3)
                .foregroundStyle(.secondary)
            
         

            Text(isBonusColor ? "BONUS! Tap for +1" : "PENALTY! Tap costs -1")
                .font(.headline)
                .foregroundStyle(isBonusColor ? .green : .red)

            Spacer()

            
            Button(action: {
                if isBonusColor{
                    score += 1
                } else{
                    score = max(0, score - 1)
                    
                }
                
            }) {
                Text("TAP")
                    .font(.title)
                    .frame(width: 160, height: 160)
                    .background(isBonusColor ? Color.green : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }

            Spacer()
        }
        .padding()
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

    // MARK: - Game Over Screen
    var gameOverView: some View {
        VStack(spacing: 24) {
            Text("Game Over")
                .font(.largeTitle)
                .bold()

            Text("Final Score: \(score)")
                .font(.title2)
            if score >= highScore {
                Text("New High Score!")
                    .foregroundStyle(.red)
            } else {
                Text("High Score: \(highScore)")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Button("Play Again") {
                    resetGame()
                }
                .font(.title3)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())

                Button("Home") {
                    dismiss()
                }
                .font(.title3)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundStyle(.primary)
                .clipShape(Capsule())
            }
        }
        .padding()
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
