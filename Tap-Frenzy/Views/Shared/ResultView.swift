//
//  ResultView.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let gameMode: String
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Game Over")
                    .font(.title.bold())
                
                Text(gameMode)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 20)
            
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text(String(score))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: onHome) {
                    Label("Home", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

#Preview {
    ResultView(
        score: 150,
        gameMode: "Quiz Rush",
        onPlayAgain: {},
        onHome: {}
    )
}
