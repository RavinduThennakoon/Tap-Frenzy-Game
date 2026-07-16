import SwiftUI
import Charts

private enum StatsPalette {
    static let background = Color(red: 0.06, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let section = Color(red: 0.14, green: 0.18, blue: 0.30)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
    static let text = Color.white
}

private enum ModeStyle {
    static func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color.green
        case .lightItUp: return Color.blue
        case .quizRush: return Color.orange
        }
    }

    static func icon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "bolt.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }
}

struct StatsTab: View {
    @ObservedObject private var store = SessionStore.shared

    private func bestScore(for mode: GameMode) -> Int {
        store.sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }

    var body: some View {
        ZStack {
            StatsPalette.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header

                    VStack(spacing: 16) {
                        overviewCard
                        bestScoreCard
                        sessionChart
                        recentGamesCard
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Performance")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(StatsPalette.text)
            Text("Track your best runs, recent games, and mode-specific progress.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(.horizontal)
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(StatsPalette.text)
            Text("Total games played")
                .foregroundColor(.gray)
            Text("\(store.sessions.count)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(StatsPalette.accent)
        }
        .padding()
        .background(StatsPalette.surface)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.20), radius: 12, x: 0, y: 10)
    }

    private var bestScoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best Scores")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(StatsPalette.text)

            ForEach(GameMode.allCases, id: \.self) { mode in
                HStack {
                    Label(mode.rawValue, systemImage: ModeStyle.icon(for: mode))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(ModeStyle.color(for: mode))
                    Spacer()
                    Text("\(bestScore(for: mode))")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(StatsPalette.surface)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 10)
    }

    private var sessionChart: some View {
        Group {
            if store.sessions.isEmpty {
                EmptyStateCard(text: "Play a game to generate your first score graph.")
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Score history")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(StatsPalette.text)

                    Chart(store.sessions) { session in
                        BarMark(
                            x: .value("Time", session.timestamp),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                    }
                    .chartForegroundStyleScale(
                        domain: GameMode.allCases.map { $0.rawValue },
                        range: GameMode.allCases.map { ModeStyle.color(for: $0) }
                    )
                    .frame(height: 220)
                }
                .padding()
                .background(StatsPalette.surface)
                .cornerRadius(22)
                .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 10)
            }
        }
    }

    private var recentGamesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent games")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(StatsPalette.text)

            if store.sessions.isEmpty {
                EmptyStateCard(text: "Your recent play history will appear here.")
            } else {
                ForEach(store.sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10)) { session in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(ModeStyle.color(for: session.mode))
                            .frame(width: 12, height: 12)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.mode.rawValue)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(StatsPalette.text)
                            Text(session.timestamp, style: .time)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(session.score)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(ModeStyle.color(for: session.mode))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .background(StatsPalette.section)
                    .cornerRadius(16)
                }
            }
        }
        .padding()
        .background(StatsPalette.surface)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 10)
    }

    private func EmptyStateCard(text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding()
            .background(StatsPalette.section)
            .cornerRadius(18)
    }
}

#Preview {
    StatsTab()
}
