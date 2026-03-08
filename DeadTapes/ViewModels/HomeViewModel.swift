import Foundation
import Observation

@Observable
final class HomeViewModel {
    var todayShows: [Show] = []
    var trendingShow: Show?
    var randomShow: Show?
    var isLoading = false
    var isLoadingRandom = false
    var errorMessage: String?

    var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }

    var hasShows: Bool {
        !todayShows.isEmpty
    }

    var topShow: Show? {
        todayShows.first
    }

    var otherShows: [Show] {
        Array(todayShows.dropFirst())
    }

    // MARK: - Load Today in History

    func loadTodayInHistory() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())

        do {
            let shows = try await ArchiveAPI.shared.showsOnThisDay(month: month, day: day)
            await MainActor.run {
                self.todayShows = shows
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Load Trending Show (most downloaded this week)

    func loadTrendingShow() async {
        do {
            let shows = try await ArchiveAPI.shared.fetchTrending(rows: 1)
            await MainActor.run {
                self.trendingShow = shows.first
            }
        } catch {
            // Silently fail — this is a bonus feature
        }
    }

    // MARK: - Random Show (4.0+ rating)

    func loadRandomShow() async {
        isLoadingRandom = true

        do {
            // Fetch a random page of well-rated shows
            let randomYear = Int.random(in: 1966...1995)
            let shows = try await ArchiveAPI.shared.searchShows(year: randomYear, rows: 50)

            // Filter for 4.0+ rating, then pick a random one
            let goodShows = shows.filter { ($0.avgRating ?? 0) >= 4.0 }

            await MainActor.run {
                if let pick = goodShows.randomElement() ?? shows.randomElement() {
                    self.randomShow = pick
                }
                self.isLoadingRandom = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingRandom = false
            }
        }
    }
}
