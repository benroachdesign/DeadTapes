import Foundation
import Observation

@MainActor
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
    private var loadTask: Task<Void, Never>?

    var showCount: Int { filteredShows.count }

    var isAllTime: Bool { selectedYear == 0 }

    var headerTitle: String {
        isAllTime ? "Top Shows" : "Shows"
    }

    var headerSubtitle: String {
        isAllTime ? "TOP" : "BROWSE"
    }

    var countLabel: String {
        isAllTime ? "\(showCount) top shows" : "\(showCount) shows"
    }

    func loadShows() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let rows = isAllTime ? 100 : 50
            let results = try await ArchiveAPI.shared.searchShows(year: selectedYear, rows: rows)
            shows = results
            filterShows()
            isLoading = false
        } catch is CancellationError {
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func selectYear(_ year: Int) {
        loadTask?.cancel()
        selectedYear = year
        shows = []
        filteredShows = []
        loadTask = Task {
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

        // Check Top 10 of Year (only when browsing a specific year)
        if !isAllTime, let yearRank = rankingService.yearRank(for: show, in: shows), yearRank <= 10 {
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
