// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import Testing
@testable import PriceCheck

struct MockPriceAPITests {

    static let sampleJSON = """
    [
      {
        "barcode": "037000127913",
        "item": "Charmin Soft 12 Mega Rolls",
        "prices": [
          { "location": "Target",      "price": 14.79, "daysAgo": 3 },
          { "location": "Giant Eagle", "price": 14.95, "daysAgo": 5 }
        ]
      },
      {
        "barcode": "034000111206",
        "item": "Hershey Miniatures 17.6oz",
        "prices": [
          { "location": "Giant Eagle", "price": 5.89, "daysAgo": 6 }
        ]
      }
    ]
    """.data(using: .utf8)!

    private func makeAPI() -> MockPriceAPI {
        MockPriceAPI(dataSource: { Self.sampleJSON })
    }

    @Test func lookupKnownBarcodeAtKnownLocationReturnsPrice() async throws {
        let api = makeAPI()
        let result = try await api.lookup(barcode: "037000127913", at: "Target")

        #expect(result?.itemName == "Charmin Soft 12 Mega Rolls")
        #expect(result?.price == 14.79)
        #expect(result?.location == "Target")
    }

    @Test func lookupKnownBarcodeAtAbsentLocationReturnsNil() async throws {
        let api = makeAPI()
        let result = try await api.lookup(barcode: "034000111206", at: "Target")
        #expect(result == nil)
    }

    @Test func lookupUnknownBarcodeReturnsNil() async throws {
        let api = makeAPI()
        let result = try await api.lookup(barcode: "999999999999", at: "Target")
        #expect(result == nil)
    }

    @Test func knownLocationsReturnsSortedUniqueChains() async throws {
        let api = makeAPI()
        let locations = try await api.knownLocations()
        #expect(locations == ["Giant Eagle", "Target"])
    }

    @Test func allBarcodesSortedAlphabeticallyByItemName() async throws {
        let api = makeAPI()
        let entries = try await api.allBarcodes()
        #expect(entries.map(\.item) == [
            "Charmin Soft 12 Mega Rolls",
            "Hershey Miniatures 17.6oz"
        ])
    }
}
