//
//  StatsVM.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation
import Combine

@MainActor
class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []
    @Published var totalGamesPlayed = 0
    @Published var averageScore = 0.0
    @Published var highScore = 0
    
    private let sessionStore = SessionStore.shared
    
    init() {
        loadSessions()
    }
    
    private func loadSessions() {
        sessions = sessionStore.loadSessions()
        calculateStats()
    }
    
    private func calculateStats() {
        totalGamesPlayed = sessions.count
        highScore = sessions.map { $0.score }.max() ?? 0
        let total = sessions.reduce(0) { $0 + $1.score }
        averageScore = totalGamesPlayed > 0 ? Double(total) / Double(totalGamesPlayed) : 0
    }
    
    func addSession(_ session: GameSession) {
        sessions.append(session)
        sessionStore.saveSession(session)
        calculateStats()
    }
}
