// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI
import SwiftData

@main
struct PriceCheckApp: App {

    @State private var locationStore = LocationStore()
    private let modelContainer: ModelContainer
    private let priceAPI: any PriceAPI

    init() {
        do {
            modelContainer = try ModelContainer(for: PriceObservation.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        priceAPI = MockPriceAPI.bundled()
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(modelContainer)
                .environment(\.priceAPI, priceAPI)
                .environment(\.historyStore, HistoryStore(container: modelContainer))
                .environment(locationStore)
                .tint(Color.brand)
        }
    }
}
