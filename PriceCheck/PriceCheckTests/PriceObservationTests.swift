// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import Testing
import SwiftData
@testable import PriceCheck

@MainActor
struct PriceObservationTests {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: PriceObservation.self, configurations: config)
    }

    @Test func insertAndFetchRoundTrip() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let obs = PriceObservation(
            barcode: "037000127913",
            itemName: "Charmin Soft 12 Mega Rolls",
            location: "Target",
            price: 14.79,
            date: Date()
        )
        context.insert(obs)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<PriceObservation>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.barcode == "037000127913")
        #expect(fetched.first?.price == 14.79)
    }

    @Test func dayKeyMatchesCalendarDate() {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 10
        comps.day = 5
        let date = Calendar.current.date(from: comps)!
        #expect(PriceObservation.dayKey(from: date) == "2026-10-05")
    }

    @Test func convenienceInitFromLookupCopiesFields() {
        let lookup = PriceLookup(
            barcode: "999",
            itemName: "Widget",
            price: 1.23,
            location: "Target",
            date: Date()
        )
        let obs = PriceObservation(from: lookup)
        #expect(obs.barcode == "999")
        #expect(obs.itemName == "Widget")
        #expect(obs.price == 1.23)
        #expect(obs.location == "Target")
    }
}
