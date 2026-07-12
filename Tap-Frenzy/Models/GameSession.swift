//
//  GameSession.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let gameMode: String
    let score: Int
    let timestamp: Date
    let duration: TimeInterval
    
    init(id: UUID = UUID(), gameMode: String, score: Int, timestamp: Date = Date(), duration: TimeInterval = 0) {
        self.id = id
        self.gameMode = gameMode
        self.score = score
        self.timestamp = timestamp
        self.duration = duration
    }
}
