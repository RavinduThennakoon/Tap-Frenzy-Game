import SwiftUI

private enum SettingsPalette {
    static let background = Color(red: 0.06, green: 0.09, blue: 0.18)
    static let surface = Color(red: 0.10, green: 0.14, blue: 0.24)
    static let accent = Color(red: 0.12, green: 0.86, blue: 0.70)
    static let destructive = Color(red: 0.94, green: 0.33, blue: 0.35)
}

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
        ZStack {
            SettingsPalette.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Customize notifications and reset your saved progress in one place.")
                            .foregroundColor(.gray)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        VStack(spacing: 18) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Daily Challenge")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Set a daily reminder and keep your streak alive.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }

                           Toggle("Enable Notifications", isOn: $notificationsEnabled)
    .toggleStyle(.automatic)
    .tint(SettingsPalette.accent)
    .font(.system(size: 16, weight: .medium, design: .rounded))
    .foregroundStyle(.white) // or any Color
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
                                    .datePickerStyle(.compact)
                                    .padding(.top, 4)
                                    .foregroundStyle(.white)
                                    .onChange(of: dailyChallengeTimeInterval) { _, _ in
                                        NotificationService.shared.scheduleDailyReminder(at: dailyChallengeTime.wrappedValue)
                                    }
                            }
                        }
                        .padding()
                        .background(SettingsPalette.surface)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 10)

                        VStack(spacing: 16) {
                            Text("Danger Zone")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Text("This will permanently delete saved sessions and high scores.")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .regular, design: .rounded))

                            Button(role: .destructive) {
                                showResetConfirmation = true
                            } label: {
                                Label("Reset All Data", systemImage: "trash.fill")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(SettingsPalette.destructive)
                                    .foregroundColor(.white)
                                    .cornerRadius(18)
                            }
                        }
                        .padding()
                        .background(SettingsPalette.surface)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
