// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import Testing
@testable import PriceCheck

struct APITypesTests {

    @Test func decodesPricesJSONShape() throws {
        let json = """
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

        let items = try JSONDecoder().decode([APIItem].self, from: json)

        #expect(items.count == 2)
        #expect(items[0].barcode == "037000127913")
        #expect(items[0].item == "Charmin Soft 12 Mega Rolls")
        #expect(items[0].prices.count == 2)
        #expect(items[0].prices[0].location == "Target")
        #expect(items[0].prices[0].price == 14.79)
        #expect(items[0].prices[0].daysAgo == 3)
        #expect(items[1].prices.count == 1)
    }
}
