//
//  StatsTab.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct StatsTab: View {
    @StateObject private var vm = StatsVM()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if vm.totalGamesPlayed == 0 {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No games played yet")
                            .font(.headline)
                        Text("Play some games to see your stats!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 16) {
                        StatCard(
                            title: "Total Games",
                            value: String(vm.totalGamesPlayed),
                            icon: "gamecontroller"
                        )
                        
                        StatCard(
                            title: "High Score",
                            value: String(vm.highScore),
                            icon: "star.fill"
                        )
                        
                        StatCard(
                            title: "Average Score",
                            value: String(format: "%.1f", vm.averageScore),
                            icon: "chart.line.uptrend.xyaxis"
                        )
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
            .navigationTitle("Statistics")
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title2.bold())
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatsTab()
}
