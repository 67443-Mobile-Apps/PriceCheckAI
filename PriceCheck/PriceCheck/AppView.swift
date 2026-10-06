// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI

struct AppView: View {

    @Environment(\.priceAPI) private var priceAPI
    @Environment(\.historyStore) private var historyStore
    @Environment(LocationStore.self) private var locationStore

    @State private var scanPath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $scanPath) {
                HomeView()
                    .navigationDestination(for: ScanRoute.self) { route in
                        switch route {
                        case .picker:
                            ScanPickerView()
                        case .result(let result):
                            ResultsView(result: result)
                        }
                    }
            }
            .environment(\.scanPath, $scanPath)
            .tabItem {
                Label("Scan", systemImage: "barcode.viewfinder")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
        }
        .task {
            do {
                try await locationStore.load(from: priceAPI)
                try historyStore?.purgeOlderThan(days: 90)
            } catch {
                print("Startup task failed: \(error)")
            }
        }
    }
}

