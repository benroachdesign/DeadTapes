import Foundation

actor ArchiveAPI {
    static let shared = ArchiveAPI()

    private let baseSearchURL = "https://archive.org/advancedsearch.php"
    private let baseMetadataURL = "https://archive.org/metadata"

    private let session: URLSession
    private var cache: [String: (data: Data, timestamp: Date)] = [:]
    private let cacheDuration: TimeInterval = 300 // 5 minutes

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Search Shows by Year

     func searchShows(year: Int, page: Int = 1, rows: Int = 50) async throws -> [Show] {
        let fields = [
            "identifier", "title", "date", "avg_rating",
            "num_reviews", "downloads", "source", "venue", "coverage"
        ]
        let fieldParams = fields.map { "fl[]=\($0)" }.joined(separator: "&")

        let query: String
        if year == 0 {
            // All-time query — no year filter
            query = "collection:GratefulDead"
        } else {
            query = "collection:GratefulDead AND date:\(year)*"
        }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        let urlString = "\(baseSearchURL)?q=\(encodedQuery)&\(fieldParams)&output=json&rows=\(rows)&page=\(page)&sort[]=downloads+desc"

        let data = try await fetchData(urlString: urlString)
        let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)
        return response.response.docs.compactMap { $0.toShow() }
    }

    // MARK: - Trending (sorted by weekly downloads)

    func fetchTrending(rows: Int = 5) async throws -> [Show] {
        let fields = [
            "identifier", "title", "date", "avg_rating",
            "num_reviews", "downloads", "source", "venue", "coverage"
        ]
        let fieldParams = fields.map { "fl[]=\($0)" }.joined(separator: "&")

        let query = "collection:GratefulDead"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        let urlString = "\(baseSearchURL)?q=\(encodedQuery)&\(fieldParams)&output=json&rows=\(rows)&sort[]=week+desc"

        let data = try await fetchData(urlString: urlString)
        let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)
        return response.response.docs.compactMap { $0.toShow() }
    }

    // MARK: - Today in History

    func showsOnThisDay(month: Int, day: Int) async throws -> [Show] {
        // Query across all GD active years for this month/day
        // Archive.org doesn't support wildcard month/day, so we search a date range
        // We'll query each year individually and merge for accuracy
        let years = Array(1965...1995)
        let paddedMonth = String(format: "%02d", month)
        let paddedDay = String(format: "%02d", day)

        var allShows: [Show] = []

        // Batch queries — 5 at a time to be nice to the API
        let batchSize = 5
        for batchStart in stride(from: 0, to: years.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, years.count)
            let batch = years[batchStart..<batchEnd]

            try await withThrowingTaskGroup(of: [Show].self) { group in
                for year in batch {
                    group.addTask { [self] in
                        let dateStr = "\(year)-\(paddedMonth)-\(paddedDay)"
                        return try await self.searchShowsForDate(dateStr)
                    }
                }

                for try await shows in group {
                    allShows.append(contentsOf: shows)
                }
            }
        }

        // Deduplicate by date (keep highest download count per unique date)
        var seen: [String: Show] = [:]
        for show in allShows {
            let key = show.formattedDate
            if let existing = seen[key] {
                if show.downloads > existing.downloads {
                    seen[key] = show
                }
            } else {
                seen[key] = show
            }
        }

        return seen.values.sorted { $0.downloads > $1.downloads }
    }

    private func searchShowsForDate(_ dateStr: String) async throws -> [Show] {
        let fields = [
            "identifier", "title", "date", "avg_rating",
            "num_reviews", "downloads", "source", "venue", "coverage"
        ]
        let fieldParams = fields.map { "fl[]=\($0)" }.joined(separator: "&")

        let query = "collection:GratefulDead AND date:\(dateStr)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        let urlString = "\(baseSearchURL)?q=\(encodedQuery)&\(fieldParams)&output=json&rows=10&sort[]=downloads+desc"

        let data = try await fetchData(urlString: urlString)
        let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)
        return response.response.docs.compactMap { $0.toShow() }
    }

    // MARK: - Metadata Fetching
    
    func fetchShowMetadataOnly(identifier: String) async throws -> Show? {
        let fields = [
            "identifier", "title", "date", "avg_rating",
            "num_reviews", "downloads", "source", "venue", "coverage"
        ]
        let fieldParams = fields.map { "fl[]=\($0)" }.joined(separator: "&")
        
        let query = "identifier:\(identifier)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let urlString = "\(baseSearchURL)?q=\(encodedQuery)&\(fieldParams)&output=json&rows=1"
        
        let data = try await fetchData(urlString: urlString)
        let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)
        return response.response.docs.compactMap { $0.toShow() }.first
    }

    // MARK: - Fetch Track Listing

    func fetchTracks(for identifier: String) async throws -> [Track] {
        let urlString = "\(baseMetadataURL)/\(identifier)/files"
        let data = try await fetchData(urlString: urlString)
        let response = try JSONDecoder().decode(ArchiveFilesResponse.self, from: data)

        return response.result
            .compactMap { $0.toTrack(showIdentifier: identifier) }
            .sorted { ($0.disc, $0.trackNumber) < ($1.disc, $1.trackNumber) }
    }

    // MARK: - Networking

    private func fetchData(urlString: String) async throws -> Data {
        // Check cache
        if let cached = cache[urlString],
           Date().timeIntervalSince(cached.timestamp) < cacheDuration {
            return cached.data
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }

        // Store in cache
        cache[urlString] = (data: data, timestamp: Date())

        return data
    }
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case serverError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError: return "Server error. Please try again."
        case .decodingError: return "Failed to parse response."
        }
    }
}
