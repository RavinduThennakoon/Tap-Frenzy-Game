//
//  StatsTab.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct StatsTab: View {
    @ObservedObject private var store = SessionStore.shared

    private func bestScore(for mode: GameMode) -> Int {
        store.sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }

    var body: some View {
        List {
            Section("Overview") {
                Text("Total games played: \(store.sessions.count)")
            }

            Section("Best Scores") {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    HStack {
                        Text(mode.rawValue)
                        Spacer()
                        Text("\(bestScore(for: mode))")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Recent Games") {
                ForEach(store.sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10)) { session in
                    HStack {
                        Text(session.mode.rawValue)
                        Spacer()
                        Text("\(session.score)")
                        Text(session.timestamp, style: .time)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Stats")
    }
}

#Preview {
    StatsTab()
}
