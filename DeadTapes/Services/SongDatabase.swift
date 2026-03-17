import Foundation

/// Singleton providing the static Grateful Dead song catalog.
/// Intentionally a plain class (not `@Observable`) because the data is loaded once
/// from `songs_db.json` at init time and never mutates at runtime.
class SongDatabase {
    static let shared = SongDatabase()
    
    private(set) var allSongs: [Song] = []
    
    private init() {
        loadDatabase()
    }
    
    private func loadDatabase() {
        guard let url = Bundle.main.url(forResource: "songs_db", withExtension: "json") else {
            #if DEBUG
            print("Error: songs_db.json not found in bundle")
            #endif
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            allSongs = try decoder.decode([Song].self, from: data)
            
            // Sort alphabetically by default
            allSongs.sort { $0.title < $1.title }
        } catch {
            #if DEBUG
            print("Error parsing songs_db.json: \(error)")
            #endif
        }
    }
    
    // Sort functions for views
    func getSongsSortedAlphabetically() -> [Song] {
        return allSongs // already sorted alphabetically at load time
    }
    
    func getSongsSortedByPlayCount() -> [Song] {
        return allSongs.sorted { $0.playCount > $1.playCount }
    }
    
    func searchSongs(query: String) -> [Song] {
        if query.isEmpty { return allSongs }
        let lowercasedQuery = query.lowercased()
        return allSongs.filter { $0.title.lowercased().contains(lowercasedQuery) }
    }
}

