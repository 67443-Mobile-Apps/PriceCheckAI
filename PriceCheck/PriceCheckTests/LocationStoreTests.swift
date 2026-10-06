// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import Testing
@testable import PriceCheck

@MainActor
struct LocationStoreTests {

    static let sampleJSON = """
    [
      { "barcode": "A", "item": "Alpha",
        "prices": [ { "location": "Target", "price": 1.00, "daysAgo": 1 } ] },
      { "barcode": "B", "item": "Beta",
        "prices": [ { "location": "Giant Eagle", "price": 2.00, "daysAgo": 2 } ] },
      { "barcode": "C", "item": "Gamma",
        "prices": [ { "location": "Aldi", "price": 3.00, "daysAgo": 3 } ] }
    ]
    """.data(using: .utf8)!

    private func makeDefaults() -> UserDefaults {
        let name = "LocationStoreTests-\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return d
    }

    private func makeAPI() -> MockPriceAPI {
        MockPriceAPI(dataSource: { Self.sampleJSON })
    }

    @Test func loadPopulatesLocationsSortedAlphabetically() async throws {
        let store = LocationStore(defaults: makeDefaults())
        try await store.load(from: makeAPI())
        #expect(store.all == ["Aldi", "Giant Eagle", "Target"])
    }

    @Test func defaultCurrentIsFirstAlphabeticallyOnFirstLaunch() async throws {
        let store = LocationStore(defaults: makeDefaults())
        try await store.load(from: makeAPI())
        #expect(store.current == "Aldi")
    }

    @Test func changingCurrentPersistsAcrossRelaunch() async throws {
        let defaults = makeDefaults()

        let first = LocationStore(defaults: defaults)
        try await first.load(from: makeAPI())
        first.current = "Target"

        let second = LocationStore(defaults: defaults)
        try await second.load(from: makeAPI())
        #expect(second.current == "Target")
    }

    @Test func persistedCurrentIsResetIfNoLongerKnown() async throws {
        let defaults = makeDefaults()
        defaults.set("Whole Foods", forKey: "LocationStore.current")

        let store = LocationStore(defaults: defaults)
        try await store.load(from: makeAPI())
        #expect(store.current == "Aldi")
    }
}
