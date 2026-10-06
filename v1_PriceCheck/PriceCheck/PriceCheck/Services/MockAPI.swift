import Foundation

enum MockAPIError: Error {
    case resourceMissing
    case noScansAvailable
    case itemNotFound
}

struct MockAPI {
    static func fetchLocations() throws -> [Location] {
        guard let url = Bundle.main.url(forResource: "scan_by_location", withExtension: "json") else {
            throw MockAPIError.resourceMissing
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode([Location].self, from: data)
    }

    /// Simulates a barcode scan by picking a random item from the given location's history.
    static func simulateScan(at location: Location) throws -> String {
        guard let scan = location.scans.randomElement() else {
            throw MockAPIError.noScansAvailable
        }
        return scan.item
    }

    /// Returns the latest known price for `item` at `location`.
    static func lookupPrice(for item: String, at location: Location) throws -> Double {
        let matches = location.scans.filter { $0.item == item }
        guard let latest = matches.max(by: { $0.date < $1.date }) else {
            throw MockAPIError.itemNotFound
        }
        return latest.price
    }
}
