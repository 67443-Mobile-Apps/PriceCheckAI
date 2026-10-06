// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI

private struct PriceAPIKey: EnvironmentKey {
    static let defaultValue: any PriceAPI = MockPriceAPI.bundled()
}

private struct HistoryStoreKey: EnvironmentKey {
    @MainActor
    static let defaultValue: HistoryStore? = nil
}

private struct ScanPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath>? = nil
}

extension EnvironmentValues {
    var priceAPI: any PriceAPI {
        get { self[PriceAPIKey.self] }
        set { self[PriceAPIKey.self] = newValue }
    }

    var historyStore: HistoryStore? {
        get { self[HistoryStoreKey.self] }
        set { self[HistoryStoreKey.self] = newValue }
    }

    var scanPath: Binding<NavigationPath>? {
        get { self[ScanPathKey.self] }
        set { self[ScanPathKey.self] = newValue }
    }
}
