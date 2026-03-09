import Foundation
import Observation

@Observable
class SongDetailViewModel {
    let song: Song
    var recentShows: [Show] = []
    var isLoading = false
    var errorMessage: String?
    
    private let api = ArchiveAPI.shared
    
    init(song: Song) {
        self.song = song
    }
    
    func loadShows() async {
        guard recentShows.isEmpty && !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch metadata for each show identifier assigned to this song
            var fetchedShows: [Show] = []
            
            // To prevent massive parallel spam, we chunk or fetch them concurrently up to the array size
            // We only included 3-5 shows per song in our DB anyway.
            try await withThrowingTaskGroup(of: Show?.self) { group in
                for id in song.shows {
                    group.addTask {
                        do {
                            return try await self.api.fetchShowMetadataOnly(identifier: id)
                        } catch {
                            return nil // Skip failed ones silently for now
                        }
                    }
                }
                
                for try await show in group {
                    if let s = show {
                        fetchedShows.append(s)
                    }
                }
            }
            
            // Sort shows by date descending
            fetchedShows.sort { $0.date > $1.date }
            
            await MainActor.run { [fetchedShows] in
                self.recentShows = fetchedShows
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func randomShow() -> Show? {
        return recentShows.randomElement()
    }
}
