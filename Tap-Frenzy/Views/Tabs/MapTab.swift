//
//  MapTab.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @ObservedObject private var store = SessionStore.shared
    @State private var selectedSession: GameSession?

    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .green
        case .lightItUp: return .blue
        case .quizRush: return .orange
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Map {
                ForEach(store.sessions) { session in
                    Annotation(session.mode.rawValue, coordinate: CLLocationCoordinate2D(
                        latitude: session.latitude,
                        longitude: session.longitude
                    )) {
                        Circle()
                            .fill(color(for: session.mode))
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .onTapGesture {
                                selectedSession = session
                            }
                    }
                }
            }
            .frame(height: 300)

            List {
                if store.sessions.isEmpty {
                    Text("Play a game to see it appear on the map.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.sessions.sorted(by: { $0.timestamp > $1.timestamp })) { session in
                        Button {
                            selectedSession = session
                        } label: {
                            HStack {
                                Circle()
                                    .fill(color(for: session.mode))
                                    .frame(width: 10, height: 10)
                                Text(session.mode.rawValue)
                                Spacer()
                                Text("\(session.score)")
                                    .foregroundStyle(.secondary)
                                Text(session.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationTitle("Map")
        .sheet(item: $selectedSession) { session in
            VStack(spacing: 16) {
                Text(session.mode.rawValue)
                    .font(.title2.bold())
                Text("Score: \(session.score)")
                    .font(.title3)
                Text(session.timestamp, style: .date)
                    .foregroundStyle(.secondary)
                Text(session.timestamp, style: .time)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .presentationDetents([.height(220)])
        }
    }
}

#Preview {
    MapTab()
}