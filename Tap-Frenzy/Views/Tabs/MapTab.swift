import SwiftUI
import MapKit

private enum MapPalette {
    static let background = Color(red: 0.06, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
}

private enum MapModeStyle {
    static func icon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "bolt.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }

    static func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color.green
        case .lightItUp: return Color.blue
        case .quizRush: return Color.orange
        }
    }
}

struct MapTab: View {
    @ObservedObject private var store = SessionStore.shared
    @State private var selectedSession: GameSession?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
        )
    )

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

    private func focus(on session: GameSession, proxy: ScrollViewProxy) {
        focus(on: session)
        withAnimation {
            proxy.scrollTo("mapTop", anchor: .top)
        }
    }

    var body: some View {
        ZStack {
            MapPalette.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        mapSection
                            .id("mapTop")

                        sessionPanel(proxy: proxy)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedSession == nil, let latest = store.sessions.last {
                focus(on: latest)
            }
        }
    }

    private var mapSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition, interactionModes: .all) {
                // Add annotations for each session
                ForEach(store.sessions) { session in
                    let coord = CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)
                    Annotation("\(session.mode.rawValue)", coordinate: coord) {
                        annotationView(for: session)
                    }
                }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.26), radius: 18, x: 0, y: 12)

            if store.sessions.isEmpty {
                Text("Play a game to place your first session on the map.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.black.opacity(0.45))
                    .cornerRadius(18)
                    .padding(18)
            }
        }
        .padding(.horizontal)
    }

    private func sessionPanel(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("Sessions")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(store.sessions.count)")
                    .foregroundColor(.gray)
            }

            if let selected = selectedSession {
                VStack(alignment: .leading, spacing: 8) {
                    Label(selected.mode.rawValue, systemImage: MapModeStyle.icon(for: selected.mode))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(MapModeStyle.color(for: selected.mode))
                    Text("Score: \(selected.score)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(selected.timestamp, style: .date)
                        .foregroundColor(.gray)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                }
                .padding()
                .background(MapPalette.surface)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
            }

            if store.sessions.isEmpty {
                EmptyStateView(text: "No sessions yet. Finish a game and check your location here.")
            } else {
                VStack(spacing: 12) {
                    ForEach(store.sessions.sorted(by: { $0.timestamp > $1.timestamp })) { session in
                        Button {
                            focus(on: session, proxy: proxy)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(MapModeStyle.color(for: session.mode))
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.mode.rawValue)
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Text(session.timestamp, style: .date)
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                }
                                Spacer()
                                Text("\(session.score)")
                                    .foregroundColor(MapModeStyle.color(for: session.mode))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .padding()
                            .background(session.id == selectedSession?.id ? MapPalette.background : MapPalette.surface)
                            .cornerRadius(18)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func annotationView(for session: GameSession) -> some View {
        VStack(spacing: 4) {
            Image(systemName: MapModeStyle.icon(for: session.mode))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .background(MapModeStyle.color(for: session.mode))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: session.id == selectedSession?.id ? 2 : 0)
                )
                .scaleEffect(session.id == selectedSession?.id ? 1.15 : 1.0)
                .onTapGesture { focus(on: session) }
        }
    }

    private func EmptyStateView(text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(MapPalette.surface)
            .cornerRadius(18)
    }
}

#Preview {
    MapTab()
}
