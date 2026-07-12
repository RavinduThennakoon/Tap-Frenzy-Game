//
//  GameMode.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation

enum GameMode: String, CaseIterable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var description: String {
        self.rawValue
    }
}
