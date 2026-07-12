//
//  SessionStore.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation
import Combine

class SessionStore: ObservableObject {
    static let shared = SessionStore()
    
    @Published private(set) var sessions: [GameSession] = []
    
    private let sessionFileName = "game_sessions.json"
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(sessionFileName)
    }
    
    private init() {
        sessions = loadSessions()
    }
    
    func saveSession(_ session: GameSession) {
        sessions.append(session)
        
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: fileURL)
        } catch {
            print("Error saving session: \(error)")
        }
    }

    func add(_ session: GameSession) {
        saveSession(session)
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
        sessions = []
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error clearing sessions: \(error)")
        }
    }
    
    func reset() {
        clearSessions()
    }
}
