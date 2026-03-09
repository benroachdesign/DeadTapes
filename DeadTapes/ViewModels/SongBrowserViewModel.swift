import Foundation
import Observation

@Observable
class SongBrowserViewModel {
    var allSongs: [Song] = []
    var displayedSongs: [Song] = []
    
    var searchText: String = "" {
        didSet {
            filterAndSortSongs()
        }
    }
    
    enum SortOption: String, CaseIterable {
        case alphabetical = "A-Z"
        case mostPlayed = "Most Played"
    }
    
    var selectedSort: SortOption = .mostPlayed {
        didSet {
            filterAndSortSongs()
        }
    }
    
    init() {
        loadData()
    }
    
    private func loadData() {
        allSongs = SongDatabase.shared.allSongs
        filterAndSortSongs()
    }
    
    private func filterAndSortSongs() {
        var filtered = allSongs
        
        if !searchText.isEmpty {
            let lower = searchText.lowercased()
            filtered = filtered.filter { $0.title.lowercased().contains(lower) }
        }
        
        switch selectedSort {
        case .alphabetical:
            filtered.sort { $0.title < $1.title }
        case .mostPlayed:
            filtered.sort { $0.playCount > $1.playCount }
        }
        
        displayedSongs = filtered
    }
}
