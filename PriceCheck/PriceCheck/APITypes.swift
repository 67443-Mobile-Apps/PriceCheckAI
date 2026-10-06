// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation

struct APIItem: Codable {
    let barcode: String
    let item: String
    let prices: [APIPrice]
}

struct APIPrice: Codable {
    let location: String
    let price: Double
    let daysAgo: Int
}

struct PriceLookup: Equatable, Hashable {
    let barcode: String
    let itemName: String
    let price: Double
    let location: String
    let date: Date
}
