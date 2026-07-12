import SwiftUI
import Combine
import CoreLocation

struct LightItUpView: View {
    @State private var cards: [Card] = []
    @State private var litCardIDs: Set<Int> = []
    @State private var score = 0
    @State private var lives = 3
    @State private var level: Level = .l1
    @State private var timeRemaining = 60
    @State private var isRoundActive = true

    @Environment(\.dismiss) private var dismiss

    @AppStorage("lightItUp_highScore") private var highScore = 0

    private let roundClock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: level.columns)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Score: \(score)")
                Spacer()
                Text("Lives: \(lives)")
                Spacer()
                Text("\(timeRemaining)s")
            }
            .font(.headline)
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(litCardIDs.contains(card.id) ? Color.yellow : Color.gray.opacity(0.25))
                        .scaleEffect(litCardIDs.contains(card.id) ? 1.05 : 1.0)
                        .frame(height: 80)
                        .onTapGesture { handleTap(card) }
                }
            }
            .animation(.easeInOut(duration: 0.15), value: litCardIDs)
            .padding()

            if !isRoundActive {
                VStack(spacing: 12) {
                    Text("Round over — Score \(score) · Best \(highScore)")
                        .font(.title3.bold())

                    HStack(spacing: 16) {
                        Button("Play Again") {
                            startRound()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Home") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top)
            }
        }
        .navigationTitle("Light It Up")
        .onAppear { startRound() }
        .onReceive(roundClock) { _ in tickRound() }
        .onDisappear { isRoundActive = false }
    }

    // MARK: - Round lifecycle
    private func startRound() {
        score = 0; lives = 3; timeRemaining = 60; level = .l1
        isRoundActive = true
        rebuildCards(for: .l1)
        scheduleNextFlip()
    }

    private func rebuildCards(for level: Level) {
        cards = (0..<level.gridSize).map { Card(id: $0) }
        litCardIDs = []
    }

    private func tickRound() {
        guard isRoundActive else { return }
        timeRemaining -= 1

        let elapsed = 60 - timeRemaining
        let newLevel = Level.level(atElapsed: elapsed)
        if newLevel != level {
            level = newLevel
            rebuildCards(for: newLevel)
        }

        if timeRemaining <= 0 { endRound() }
    }

    private func scheduleNextFlip() {
        guard isRoundActive else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + level.litWindow) {
            guard isRoundActive else { return }
            flipRandomCards()
            scheduleNextFlip()
        }
    }

    private func flipRandomCards() {
        if !litCardIDs.isEmpty {
            applyPenalty() // missed cards
        }
        let chosen = cards.map(\.id).shuffled().prefix(level.simultaneousLit)
        litCardIDs = Set(chosen)
    }

    private func handleTap(_ card: Card) {
        guard isRoundActive else { return }
        withAnimation {
            if litCardIDs.contains(card.id) {
                score += 1
                litCardIDs.remove(card.id)
            } else {
                applyPenalty()
            }
        }
    }

    private func applyPenalty() {
        lives -= 1
        if lives <= 0 { endRound() }
    }

    private func endRound() {
    isRoundActive = false
    litCardIDs = []
    if score > highScore { highScore = score }

    LocationService.shared.requestLocation()
    let loc = LocationService.shared.lastLocation
    let session = GameSession(
        mode: .lightItUp,
        score: score,
        latitude: loc?.coordinate.latitude ?? 0,
        longitude: loc?.coordinate.longitude ?? 0
    )
    SessionStore.shared.add(session)
}
}

#Preview {
    LightItUpView()
}
