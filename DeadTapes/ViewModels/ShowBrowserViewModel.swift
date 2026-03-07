import Foundation
import Observation

@Observable
final class ShowBrowserViewModel {
    var shows: [Show] = []
    var filteredShows: [Show] = []
    var selectedYear: Int = 1977
    var searchText: String = "" {
        didSet { filterShows() }
    }
    var isLoading = false
    var errorMessage: String?

    let years = Array(1965...1995)

    private let rankingService = ShowRankingService.shared

    var showCount: Int { filteredShows.count }

    func loadShows() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let results = try await ArchiveAPI.shared.searchShows(year: selectedYear)
            await MainActor.run {
                self.shows = results
                self.filterShows()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func selectYear(_ year: Int) {
        selectedYear = year
        shows = []
        filteredShows = []
        Task {
            await loadShows()
        }
    }

    /// Get badges for a show based on its ranking
    func badges(for show: Show) -> [ShowBadge] {
        var result: [ShowBadge] = []

        // Check Top All Time
        if let allTimeRank = rankingService.allTimeRank(for: show.identifier) {
            result.append(.topAllTime(rank: allTimeRank))
        }

        // Check Top 10 of Year (based on position in the full unfiltered list)
        if let yearRank = rankingService.yearRank(for: show, in: shows), yearRank <= 10 {
            result.append(.topOfYear(rank: yearRank, year: selectedYear))
        }

        return result
    }

    private func filterShows() {
        if searchText.isEmpty {
            filteredShows = shows
        } else {
            let query = searchText.lowercased()
            filteredShows = shows.filter { show in
                show.venue.lowercased().contains(query) ||
                show.city.lowercased().contains(query) ||
                show.title.lowercased().contains(query)
            }
        }
    }
}
