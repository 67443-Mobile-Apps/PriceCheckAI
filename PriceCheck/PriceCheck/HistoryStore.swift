// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import SwiftData

@MainActor
struct HistoryStore {
    let container: ModelContainer

    var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func save(_ lookup: PriceLookup, at date: Date = Date()) throws {
        let dayKey = PriceObservation.dayKey(from: date)
        let all = try context.fetch(FetchDescriptor<PriceObservation>())
        let existing = all.first { observation in
            observation.barcode == lookup.barcode &&
            observation.location == lookup.location &&
            observation.dayKey == dayKey
        }

        if let existing {
            existing.price = lookup.price
            existing.itemName = lookup.itemName
            existing.date = date
        } else {
            context.insert(PriceObservation(from: lookup, savedAt: date))
        }
        try context.save()
    }

    func allObservations() throws -> [PriceObservation] {
        let descriptor = FetchDescriptor<PriceObservation>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func purgeOlderThan(days: Int, now: Date = Date()) throws {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: now) else {
            return
        }
        let predicate = #Predicate<PriceObservation> { $0.date < cutoff }
        try context.delete(model: PriceObservation.self, where: predicate)
        try context.save()
    }
}
