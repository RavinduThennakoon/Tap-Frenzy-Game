//
//  Tap_FrenzyApp.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-06-20.
//

import SwiftUI

@main
struct Tap_FrenzyApp: App {
    init() {
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
