// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import Testing
import SwiftData
@testable import PriceCheck

@MainActor
struct HistoryStoreTests {

    private func makeStore() throws -> HistoryStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PriceObservation.self, configurations: config)
        return HistoryStore(container: container)
    }

    private func lookup(barcode: String = "037000127913",
                        itemName: String = "Charmin Soft 12 Mega Rolls",
                        location: String = "Target",
                        price: Double = 14.79) -> PriceLookup {
        PriceLookup(barcode: barcode,
                    itemName: itemName,
                    price: price,
                    location: location,
                    date: Date())
    }

    @Test func savingSameKeyTwiceLeavesOneRowWithLatestPrice() throws {
        let store = try makeStore()
        let today = Date()

        try store.save(lookup(price: 14.79), at: today)
        try store.save(lookup(price: 13.99), at: today)

        let all = try store.allObservations()
        #expect(all.count == 1)
        #expect(all.first?.price == 13.99)
    }

    @Test func savingDifferentLocationsOnSameDayKeepsBothRows() throws {
        let store = try makeStore()
        let today = Date()

        try store.save(lookup(location: "Target", price: 14.79), at: today)
        try store.save(lookup(location: "Giant Eagle", price: 14.95), at: today)

        let all = try store.allObservations()
        #expect(all.count == 2)
    }

    @Test func purgeRemovesObservationsOlderThanCutoff() throws {
        let store = try makeStore()
        let now = Date()
        let old = Calendar.current.date(byAdding: .day, value: -100, to: now)!
        let recent = Calendar.current.date(byAdding: .day, value: -5, to: now)!

        try store.save(lookup(barcode: "A", location: "Target"), at: old)
        try store.save(lookup(barcode: "B", location: "Target"), at: recent)

        try store.purgeOlderThan(days: 90, now: now)

        let all = try store.allObservations()
        #expect(all.count == 1)
        #expect(all.first?.barcode == "B")
    }

    @Test func allObservationsSortedNewestFirst() throws {
        let store = try makeStore()
        let now = Date()
        let older = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        let newer = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        try store.save(lookup(barcode: "A", location: "Target"), at: older)
        try store.save(lookup(barcode: "B", location: "Target"), at: newer)

        let all = try store.allObservations()
        #expect(all.map(\.barcode) == ["B", "A"])
    }
}
