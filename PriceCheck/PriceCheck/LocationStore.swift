// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import Foundation
import Observation

@Observable
@MainActor
final class LocationStore {

    private(set) var all: [String] = []

    var current: String {
        didSet {
            defaults.set(current, forKey: Self.storageKey)
        }
    }

    private let defaults: UserDefaults
    private static let storageKey = "LocationStore.current"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = defaults.string(forKey: Self.storageKey) ?? ""
    }

    func load(from api: PriceAPI) async throws {
        let locations = try await api.knownLocations()
        self.all = locations

        if current.isEmpty || !locations.contains(current) {
            current = locations.first ?? ""
        }
    }
}
