import Foundation

struct Location: Identifiable, Codable, Hashable {
    let id: String
    let location: String
    var scans: [Scan]
}

struct Scan: Identifiable, Codable, Hashable {
    let id: String
    let item: String
    let price: Double
    let date: Date
}
