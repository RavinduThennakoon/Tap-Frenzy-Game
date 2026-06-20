import SwiftUI

struct LightItUpView: View {
    @State private var cards: [Card] = []
    @State private var litCardIDs: Set<Int> = []
    @State private var level: Level = .l1
    @State private var isRoundActive = true

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: level.columns)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Light It Up")
                .font(.largeTitle.bold())

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(litCardIDs.contains(card.id) ? Color.yellow : Color.gray.opacity(0.25))
                        .scaleEffect(litCardIDs.contains(card.id) ? 1.05 : 1.0)
                        .frame(height: 80)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: litCardIDs)
            .padding()
        }
        .navigationTitle("Light It Up")
        .onAppear {
            cards = (0..<level.gridSize).map { Card(id: $0) }
            scheduleNextFlip()
        }
        .onDisappear {
            isRoundActive = false
        }
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
        let chosenIDs = cards.map(\.id).shuffled().prefix(level.simultaneousLit)
        litCardIDs = Set(chosenIDs)
    }
}

#Preview {
    LightItUpView()
}
