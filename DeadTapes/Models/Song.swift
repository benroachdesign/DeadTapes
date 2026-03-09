import Foundation

struct Song: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let playCount: Int
    let originalArtist: String
    let debutYear: Int
    let shows: [String] // Array of Archive API identifiers
}
