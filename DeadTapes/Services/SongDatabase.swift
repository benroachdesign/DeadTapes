import Foundation

class SongDatabase {
    static let shared = SongDatabase()
    
    private(set) var allSongs: [Song] = []
    
    private init() {
        loadDatabase()
    }
    
    private func loadDatabase() {
        guard let url = Bundle.main.url(forResource: "songs_db", withExtension: "json") else {
            print("Error: songs_db.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            allSongs = try decoder.decode([Song].self, from: data)
            
            // Sort alphabetically by default
            allSongs.sort { $0.title < $1.title }
        } catch {
            print("Error parsing songs_db.json: \(error)")
        }
    }
    
    // Sort functions for views
    func getSongsSortedAlphabetically() -> [Song] {
        return allSongs.sorted { $0.title < $1.title }
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

