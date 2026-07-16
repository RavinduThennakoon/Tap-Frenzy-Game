import SwiftUI
import Combine
import CoreLocation

private enum LightItUpPalette {
    static let background = Color(red: 0.05, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let tileActive = Color.blue
    static let tileInactive = Color(red: 0.14, green: 0.18, blue: 0.28)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
}

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
        ZStack {
            LightItUpPalette.background.ignoresSafeArea()

            VStack(spacing: 18) {
                header

                gameGrid

                if !isRoundActive {
                    gameOverOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startRound() }
        .onReceive(roundClock) { _ in tickRound() }
        .onDisappear { isRoundActive = false }
    }

    private var header: some View {
        HStack(spacing: 14) {
            hudChip(label: "Score", value: "\(score)", icon: "star.fill")
            hudChip(label: "Lives", value: "\(lives)", icon: "heart.fill")
            hudChip(label: "Time", value: "\(timeRemaining)s", icon: "clock.fill")
        }
        .padding(.horizontal)
    }

    private func hudChip(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(LightItUpPalette.surface)
                .cornerRadius(10)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(12)
        .background(LightItUpPalette.surface)
        .cornerRadius(18)
    }

    private var gameGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(cards) { card in
                RoundedRectangle(cornerRadius: 16)
                    .fill(litCardIDs.contains(card.id) ? LightItUpPalette.tileActive : LightItUpPalette.tileInactive)
                    .frame(height: 88)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(litCardIDs.contains(card.id) ? Color.white.opacity(0.24) : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: litCardIDs.contains(card.id) ? LightItUpPalette.tileActive.opacity(0.30) : Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
                    .scaleEffect(litCardIDs.contains(card.id) ? 1.02 : 1)
                    .animation(.easeInOut(duration: 0.18), value: litCardIDs)
                    .onTapGesture { handleTap(card) }
            }
        }
        .padding(.horizontal)
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 18) {
            Text("Round over")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Score: \(score)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(LightItUpPalette.accent)

            Text("Best: \(highScore)")
                .foregroundColor(.gray)
                .font(.system(size: 15, design: .rounded))

            HStack(spacing: 14) {
                Button("Play Again") {
                    startRound()
                }
                .buttonStyle(.borderedProminent)
                .tint(LightItUpPalette.accent)

                Button("Home") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }

            ShareLink(item: "I just scored \(score) on Light It Up — beat that!") {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .foregroundColor(.gray)
            .font(.system(size: 14, design: .rounded))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(LightItUpPalette.surface)
        .cornerRadius(28)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.30), radius: 20, x: 0, y: 16)
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

        LocationService.shared.requestLocation { loc in
            let session = GameSession(
                mode: .lightItUp,
                score: score,
                latitude: loc?.coordinate.latitude ?? 0,
                longitude: loc?.coordinate.longitude ?? 0
            )
            SessionStore.shared.add(session)
        }
    }
}

#Preview {
    LightItUpView()
}
