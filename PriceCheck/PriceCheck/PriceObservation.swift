// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import SwiftData

@Model
final class PriceObservation {
    var barcode: String
    var itemName: String
    var location: String
    var price: Double
    var date: Date
    var dayKey: String

    init(barcode: String,
         itemName: String,
         location: String,
         price: Double,
         date: Date) {
        self.barcode = barcode
        self.itemName = itemName
        self.location = location
        self.price = price
        self.date = date
        self.dayKey = Self.dayKey(from: date)
    }

    convenience init(from lookup: PriceLookup, savedAt date: Date = Date()) {
        self.init(barcode: lookup.barcode,
                  itemName: lookup.itemName,
                  location: lookup.location,
                  price: lookup.price,
                  date: date)
    }

    static func dayKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
