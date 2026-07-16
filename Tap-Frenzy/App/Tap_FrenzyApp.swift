//
//  Tap_FrenzyApp.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-06-20.
//

import SwiftUI
import UserNotifications

@main
struct Tap_FrenzyApp: App {
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        LocationService.shared.requestPermission()
    }
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeTab()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                StatsTab()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }

                MapTab()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }

                SettingsTab()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
    }
}
