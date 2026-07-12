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
    @State private var cameraPosition: MapCameraPosition = .automatic

    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .green
        case .lightItUp: return .blue
        case .quizRush: return .orange
        }
    }

    private func focus(on session: GameSession) {
        selectedSession = session
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition) {
                ForEach(store.sessions) { session in
                    Annotation(session.mode.rawValue, coordinate: CLLocationCoordinate2D(
                        latitude: session.latitude,
                        longitude: session.longitude
                    )) {
                        Circle()
                            .fill(color(for: session.mode))
                            .frame(width: session.id == selectedSession?.id ? 22 : 14,
                                   height: session.id == selectedSession?.id ? 22 : 14)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .onTapGesture {
                                focus(on: session)
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
                            focus(on: session)
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
                            .background(session.id == selectedSession?.id ? Color.gray.opacity(0.15) : .clear)
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationTitle("Map")
    }
}

#Preview {
    MapTab()
}