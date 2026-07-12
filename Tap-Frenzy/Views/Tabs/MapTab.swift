//
//  MapTab.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct MapTab: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "map")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Game Map")
                    .font(.title2.bold())
                
                Text("Unlock levels by progressing through the games!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Map")
        }
    }
}

#Preview {
    MapTab()
}
