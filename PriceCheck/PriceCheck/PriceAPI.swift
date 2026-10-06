// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation

protocol PriceAPI {
    func lookup(barcode: String, at location: String) async throws -> PriceLookup?
    func allBarcodes() async throws -> [BarcodeEntry]
    func knownLocations() async throws -> [String]
}

struct BarcodeEntry: Equatable, Hashable {
    let barcode: String
    let item: String
}

enum PriceAPIError: Error {
    case bundledResourceMissing(String)
}

actor MockPriceAPI: PriceAPI {

    private let dataSource: @Sendable () throws -> Data
    private var cache: [APIItem]?

    init(dataSource: @escaping @Sendable () throws -> Data) {
        self.dataSource = dataSource
    }

    static func bundled(resourceName: String = "prices") -> MockPriceAPI {
        MockPriceAPI(dataSource: {
            guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
                throw PriceAPIError.bundledResourceMissing("\(resourceName).json")
            }
            return try Data(contentsOf: url)
        })
    }

    func lookup(barcode: String, at location: String) async throws -> PriceLookup? {
        let items = try load()
        guard let item = items.first(where: { $0.barcode == barcode }),
              let price = item.prices.first(where: { $0.location == location })
        else { return nil }

        return PriceLookup(
            barcode: item.barcode,
            itemName: item.item,
            price: price.price,
            location: price.location,
            date: Self.date(daysAgo: price.daysAgo)
        )
    }

    func allBarcodes() async throws -> [BarcodeEntry] {
        let items = try load()
        return items
            .map { BarcodeEntry(barcode: $0.barcode, item: $0.item) }
            .sorted { $0.item.localizedCaseInsensitiveCompare($1.item) == .orderedAscending }
    }

    func knownLocations() async throws -> [String] {
        let items = try load()
        let all = items.flatMap { $0.prices.map(\.location) }
        return Array(Set(all)).sorted()
    }

    private func load() throws -> [APIItem] {
        if let cache { return cache }
        let data = try dataSource()
        let items = try JSONDecoder().decode([APIItem].self, from: data)
        cache = items
        return items
    }

    private static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }
}
