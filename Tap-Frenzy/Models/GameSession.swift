//
//  GameSession.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let duration: TimeInterval
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        mode: GameMode,
        score: Int,
        timestamp: Date = Date(),
        duration: TimeInterval = 0,
        latitude: Double = 0,
        longitude: Double = 0
    ) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.duration = duration
        self.latitude = latitude
        self.longitude = longitude
    }
}
