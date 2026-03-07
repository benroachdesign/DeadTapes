import Foundation
import SwiftData

@Model
final class FavoriteShow {
    @Attribute(.unique) var identifier: String
    var title: String
    var date: Date
    var venue: String
    var city: String
    var source: String
    var avgRating: Double?
    var downloads: Int
    var dateAdded: Date

    init(from show: Show) {
        self.identifier = show.identifier
        self.title = show.title
        self.date = show.date
        self.venue = show.venue
        self.city = show.city
        self.source = show.source
        self.avgRating = show.avgRating
        self.downloads = show.downloads
        self.dateAdded = Date()
    }

    func toShow() -> Show {
        Show(
            identifier: identifier,
            title: title,
            date: date,
            venue: venue,
            city: city,
            source: source,
            avgRating: avgRating,
            downloads: downloads,
            numReviews: nil
        )
    }
}
