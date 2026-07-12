//
//  SettingsTab.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct SettingsTab: View {
    @State private var soundEnabled = true
    @State private var hapticEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("Sound & Haptics") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticEnabled)
                }
                
                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("StudentR")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        // Reset game data
                    } label: {
                        Text("Reset All Data")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTab()
}
