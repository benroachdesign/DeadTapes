import Foundation
import SwiftData
import Observation

@Observable
final class ShowDetailViewModel {
    var show: Show
    var trackSets: [TrackSet] = []
    var allTracks: [Track] = []
    var isLoading = false
    var errorMessage: String?
    var isFavorite = false

    init(show: Show) {
        self.show = show
    }

    func loadTracks() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let tracks = try await ArchiveAPI.shared.fetchTracks(for: show.identifier)
            await MainActor.run {
                self.allTracks = tracks
                self.groupTracksBySets(tracks)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    private func groupTracksBySets(_ tracks: [Track]) {
        let grouped = Dictionary(grouping: tracks) { $0.disc }
        let sorted = grouped.keys.sorted()

        trackSets = sorted.map { disc in
            let setName: String
            switch disc {
            case 1: setName = "Set 1"
            case 2: setName = "Set 2"
            case 3: setName = "Encore"
            case 4: setName = "Encore 2"
            default: setName = "Set \(disc)"
            }
            let setTracks = (grouped[disc] ?? []).sorted { $0.trackNumber < $1.trackNumber }
            return TrackSet(name: setName, tracks: setTracks)
        }
    }

    func checkFavorite(in context: ModelContext) {
        let identifier = show.identifier
        let descriptor = FetchDescriptor<FavoriteShow>(
            predicate: #Predicate { $0.identifier == identifier }
        )
        isFavorite = (try? context.fetchCount(descriptor)) ?? 0 > 0
    }

    func toggleFavorite(in context: ModelContext) {
        let identifier = show.identifier
        if isFavorite {
            // Remove
            let descriptor = FetchDescriptor<FavoriteShow>(
                predicate: #Predicate { $0.identifier == identifier }
            )
            if let favorites = try? context.fetch(descriptor) {
                for fav in favorites {
                    context.delete(fav)
                }
            }
        } else {
            // Add
            let favorite = FavoriteShow(from: show)
            context.insert(favorite)
        }
        try? context.save()
        isFavorite.toggle()
    }
}
