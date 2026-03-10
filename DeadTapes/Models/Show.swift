import Foundation

struct Show: Identifiable, Codable, Hashable {
    let identifier: String
    let title: String
    let date: Date
    let venue: String
    let city: String
    let source: String
    let avgRating: Double?
    let downloads: Int
    let numReviews: Int?

    var id: String { identifier }

    var isSoundboard: Bool {
        let s = source.lowercased()
        return s.contains("soundboard") || s.contains("sbd")
    }

    var isMatrix: Bool {
        source.lowercased().contains("matrix")
    }

    var sourceLabel: String {
        if isSoundboard { return "SBD" }
        if isMatrix { return "MTX" }
        return "AUD"
    }

    var formattedDate: String {
        Show.formattedDateFormatter.string(from: date)
    }

    var shortDate: String {
        Show.shortDateFormatter.string(from: date)
    }

    var yearString: String {
        Show.yearFormatter.string(from: date)
    }

    var year: Int {
        Calendar.current.component(.year, from: date)
    }

    var formattedDownloads: String {
        if downloads >= 1_000_000 {
            return String(format: "%.1fM", Double(downloads) / 1_000_000)
        } else if downloads >= 1_000 {
            return String(format: "%.0fK", Double(downloads) / 1_000)
        }
        return "\(downloads)"
    }

    var ratingStars: Int {
        guard let rating = avgRating else { return 0 }
        return Int(rating.rounded())
    }

    // MARK: - Static Formatters (created once, reused across all Show instances)

    private static let formattedDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d/yy"
        return f
    }()

    private static let yearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f
    }()
}

// MARK: - API Response Wrappers

struct ArchiveSearchResponse: Codable {
    let response: ArchiveSearchResult
}

struct ArchiveSearchResult: Codable {
    let numFound: Int
    let start: Int
    let docs: [ArchiveShowDoc]
}

struct ArchiveShowDoc: Codable {
    let identifier: String
    let title: String?
    let date: String?
    let venue: String?
    let coverage: String?
    let source: String?
    let avg_rating: Double?
    let downloads: Int?
    let num_reviews: Int?

    func toShow() -> Show? {
        guard let dateStr = date else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let parsedDate: Date

        if let d = formatter.date(from: dateStr) {
            parsedDate = d
        } else {
            // Try simpler format
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            df.timeZone = TimeZone(identifier: "UTC")
            if let d = df.date(from: dateStr) {
                parsedDate = d
            } else {
                return nil
            }
        }

        return Show(
            identifier: identifier,
            title: title ?? "Unknown Show",
            date: parsedDate,
            venue: venue ?? "Unknown Venue",
            city: coverage ?? "",
            source: source ?? "Unknown",
            avgRating: avg_rating,
            downloads: downloads ?? 0,
            numReviews: num_reviews
        )
    }
}
