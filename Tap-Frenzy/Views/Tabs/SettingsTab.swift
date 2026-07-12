//
//  SettingsTab.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeTime") private var dailyChallengeTimeInterval = Date().timeIntervalSince1970

    @State private var showResetConfirmation = false

    private var dailyChallengeTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: dailyChallengeTimeInterval) },
            set: { dailyChallengeTimeInterval = $0.timeIntervalSince1970 }
        )
    }

    var body: some View {
        Form {
            Section("Daily Challenge") {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleDailyReminder(at: dailyChallengeTime.wrappedValue)
                        } else {
                            NotificationService.shared.cancelDailyReminder()
                        }
                    }

                if notificationsEnabled {
                    DatePicker("Reminder Time", selection: dailyChallengeTime, displayedComponents: .hourAndMinute)
                        .onChange(of: dailyChallengeTimeInterval) { _, _ in
                            NotificationService.shared.scheduleDailyReminder(at: dailyChallengeTime.wrappedValue)
                        }
                }
            }

            Section {
                Button("Reset All Data", role: .destructive) {
                    showResetConfirmation = true
                }
            } footer: {
                Text("This clears all saved game sessions and high scores. This cannot be undone.")
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Reset all game data?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                resetEverything()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all played sessions and high scores.")
        }
    }

    private func resetEverything() {
        SessionStore.shared.reset()
        UserDefaults.standard.removeObject(forKey: "tapFrenzy_highScore")
        UserDefaults.standard.removeObject(forKey: "lightItUp_highScore")
    }
}

#Preview {
    SettingsTab()
}