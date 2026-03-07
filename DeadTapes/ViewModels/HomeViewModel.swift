import Foundation
import Observation

@Observable
final class HomeViewModel {
    var todayShows: [Show] = []
    var isLoading = false
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
}
