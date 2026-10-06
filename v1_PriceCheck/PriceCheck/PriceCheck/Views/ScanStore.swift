import Foundation
import Observation

@Observable
final class ScanStore {
    var locations: [Location] = []
    var currentLocationID: String?
    var loadError: String?

    init() {
        do {
            locations = try MockAPI.fetchLocations()
            currentLocationID = locations.first?.id
        } catch {
            loadError = "Failed to load data: \(error)"
        }
    }

    var currentLocation: Location? {
        locations.first { $0.id == currentLocationID }
    }

    func saveScan(item: String, price: Double) {
        guard let id = currentLocationID,
              let idx = locations.firstIndex(where: { $0.id == id }) else { return }
        let scan = Scan(id: UUID().uuidString, item: item, price: price, date: Date())
        locations[idx].scans.append(scan)
    }
}
