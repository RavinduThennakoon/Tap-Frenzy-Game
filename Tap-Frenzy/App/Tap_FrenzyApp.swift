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
            HomeTab()
        }
    }
}
