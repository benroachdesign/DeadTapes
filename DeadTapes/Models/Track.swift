import Foundation

struct Track: Identifiable, Codable, Hashable {
    let id: String            // filename (unique within a show)
    let title: String
    let trackNumber: Int
    let disc: Int
    let duration: TimeInterval
    let format: String
    let fileName: String
    let showIdentifier: String

    var setName: String {
        switch disc {
        case 1: return "Set 1"
        case 2: return "Set 2"
        case 3: return "Encore"
        case 4: return "Encore 2"
        default: return "Set \(disc)"
        }
    }

    var streamURL: URL {
        let encoded = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        return URL(string: "https://archive.org/download/\(showIdentifier)/\(encoded)")!
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Track Set Grouping

struct TrackSet: Identifiable {
    let name: String
    let tracks: [Track]
    var id: String { name }
}

// MARK: - File Metadata Response

struct ArchiveFilesResponse: Codable {
    let result: [ArchiveFileDoc]
}

struct ArchiveFileDoc: Codable {
    let name: String
    let source: String?
    let format: String?
    let title: String?
    let track: String?
    let album: String?
    let creator: String?
    let length: String?
    let bitrate: String?

    func toTrack(showIdentifier: String) -> Track? {
        guard format == "VBR MP3" else { return nil }
        guard let title = title, !title.isEmpty else { return nil }

        // Parse disc and track from filename pattern: dXtYY
        let discNum: Int
        let trackNum: Int

        if let range = name.range(of: #"d(\d+)t(\d+)"#, options: .regularExpression) {
            let matched = String(name[range])
            let scanner = Scanner(string: matched)
            scanner.charactersToBeSkipped = CharacterSet.decimalDigits.inverted
            var d = 0, t = 0
            if scanner.scanInt(&d) {
                scanner.charactersToBeSkipped = CharacterSet.decimalDigits.inverted
                if scanner.scanInt(&t) {
                    discNum = d
                    trackNum = t
                } else {
                    discNum = 1
                    trackNum = d
                }
            } else if let trackStr = track, let tVal = Int(trackStr) {
                discNum = tVal <= 9 ? 1 : (tVal <= 18 ? 2 : 3)
                trackNum = tVal
            } else {
                return nil
            }
        } else if let trackStr = track, let t = Int(trackStr) {
            // Fallback to track metadata
            discNum = t <= 9 ? 1 : (t <= 18 ? 2 : 3)
            trackNum = t
        } else {
            return nil
        }

        // Parse duration
        let dur: TimeInterval
        if let lengthStr = length {
            if lengthStr.contains(":") {
                // Format: "MM:SS"
                let parts = lengthStr.split(separator: ":")
                if parts.count == 2,
                   let min = Double(parts[0]),
                   let sec = Double(parts[1]) {
                    dur = min * 60 + sec
                } else {
                    dur = 0
                }
            } else if let seconds = Double(lengthStr) {
                dur = seconds
            } else {
                dur = 0
            }
        } else {
            dur = 0
        }

        return Track(
            id: name,
            title: title,
            trackNumber: trackNum,
            disc: discNum,
            duration: dur,
            format: format ?? "MP3",
            fileName: name,
            showIdentifier: showIdentifier
        )
    }
}
