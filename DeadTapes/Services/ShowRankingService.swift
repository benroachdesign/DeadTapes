import Foundation
import Observation

@MainActor
@Observable
final class ShowRankingService {
    static let shared = ShowRankingService()

    var topAllTimeIdentifiers: [String: Int] = [:]  // identifier -> rank (1-based)
    var isLoaded = false

    private init() {}

    /// Fetch the top 100 all-time most downloaded shows
    func loadTopAllTime() async {
        guard !isLoaded else { return }

        do {
            let shows = try await ArchiveAPI.shared.searchShows(
                year: 0, // special: all years
                page: 1,
                rows: 100
            )
            for (index, show) in shows.enumerated() {
                topAllTimeIdentifiers[show.identifier] = index + 1
            }
            isLoaded = true
        } catch {
            // Silently fail — badges are enhancement, not critical
            print("Failed to load top all-time: \(error)")
        }
    }

    /// Get the all-time rank for a show, if it's in the top 100
    func allTimeRank(for identifier: String) -> Int? {
        topAllTimeIdentifiers[identifier]
    }

    /// Check if a show is in the top N all-time
    func isTopAllTime(_ identifier: String, threshold: Int = 100) -> Bool {
        guard let rank = topAllTimeIdentifiers[identifier] else { return false }
        return rank <= threshold
    }

    /// Determine the badge for a show based on its position in a year's list
    func yearRank(for show: Show, in shows: [Show]) -> Int? {
        guard let index = shows.firstIndex(where: { $0.identifier == show.identifier }) else {
            return nil
        }
        let rank = index + 1
        return rank <= 10 ? rank : nil
    }
}
