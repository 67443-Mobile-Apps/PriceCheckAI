// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI

@main
struct PriceCheckApp: App {
    @State private var store = ScanStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
        }
    }
}
