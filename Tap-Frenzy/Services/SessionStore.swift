//
//  SessionStore.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation

class SessionStore {
    static let shared = SessionStore()
    
    private let sessionFileName = "game_sessions.json"
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(sessionFileName)
    }
    
    func saveSession(_ session: GameSession) {
        var sessions = loadSessions()
        sessions.append(session)
        
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: fileURL)
        } catch {
            print("Error saving session: \(error)")
        }
    }
    
    func loadSessions() -> [GameSession] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("Error loading sessions: \(error)")
            return []
        }
    }
    
    func clearSessions() {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error clearing sessions: \(error)")
        }
    }
}
