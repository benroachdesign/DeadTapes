import Foundation

class SongDatabase {
    static let shared = SongDatabase()
    
    private(set) var allSongs: [Song] = []
    
    private init() {
        loadDatabase()
    }
    
    private func loadDatabase() {
        // We embed the raw JSON literal to ensure it loads without needing to manage Xcode's Copy Bundle Resources phase.
        let rawJSON = """
        [
          {
            "id": "scarlet-begonias",
            "title": "Scarlet Begonias",
            "playCount": 314,
            "originalArtist": "Grateful Dead",
            "debutYear": 1974,
            "shows": [
              "gd95-07-09.sbd.7233.sbeok.shnf",
              "gd89-07-17.sbd.unknown.17702.sbeok.shnf",
              "gd89-10-09.sbd.serafin.7721.sbeok.shnf"
            ]
          },
          {
            "id": "fire-on-the-mountain",
            "title": "Fire on the Mountain",
            "playCount": 253,
            "originalArtist": "Grateful Dead",
            "debutYear": 1977,
            "shows": [
              "gd70-05-15.early-late.sbd.97.sbeok.shnf",
              "gd1969-01-18.tv.ukmutt.33931.flac16",
              "gd1977-05-08.shure57.stevenson.29303.flac16",
              "gd87-04-03.sennme80.clark-miller.24898.sbeok.shnf"
            ]
          },
          {
            "id": "dark-star",
            "title": "Dark Star",
            "playCount": 269,
            "originalArtist": "Grateful Dead",
            "debutYear": 1967,
            "shows": [
              "gd89-07-17.sbd.unknown.17702.sbeok.shnf",
              "gd90-07-23.sbd.oconner.7612.sbeok.shnf",
              "gd87-04-03.sennme80.clark-miller.24898.sbeok.shnf"
            ]
          },
          {
            "id": "morning-dew",
            "title": "Morning Dew",
            "playCount": 272,
            "originalArtist": "Bonnie Dobson",
            "debutYear": 1967,
            "shows": [
              "gd1970-11-08.aud.weiner.28609.sbeok.shnf",
              "gd71-02-18.sbd.orf.107.sbeok.shnf",
              "gd72-08-27.sbd.orf.3328.sbeok.shnf"
            ]
          },
          {
            "id": "playing-in-the-band",
            "title": "Playing in the Band",
            "playCount": 581,
            "originalArtist": "Bob Weir",
            "debutYear": 1971,
            "shows": [
              "gd71-12-14.sbd.deibert.12763.sbeok.shnf",
              "gd75-08-13.fm.vernon.23661.sbeok.shnf",
              "gd89-07-17.sbd.unknown.17702.sbeok.shnf"
            ]
          },
          {
            "id": "the-other-one",
            "title": "The Other One",
            "playCount": 587,
            "originalArtist": "Grateful Dead",
            "debutYear": 1967,
            "shows": [
              "gd73-06-10.sbd.hollister.174.sbeok.shnf",
              "gd1977-06-09.28614.sbeok.flac16",
              "gd77-05-08.sbd.hicks.4982.sbeok.shnf",
              "gd78-01-22.sbd.popi.4974.sbeok.shnf",
              "gd89-10-09.sbd.serafin.7721.sbeok.shnf"
            ]
          },
          {
            "id": "eyes-of-the-world",
            "title": "Eyes of the World",
            "playCount": 381,
            "originalArtist": "Grateful Dead",
            "debutYear": 1973,
            "shows": [
              "gd1969-01-18.tv.ukmutt.33931.flac16",
              "gd77-05-08.sbd.hicks.4982.sbeok.shnf",
              "gd1977-06-09.28614.sbeok.flac16"
            ]
          },
          {
            "id": "not-fade-away",
            "title": "Not Fade Away",
            "playCount": 530,
            "originalArtist": "The Crickets",
            "debutYear": 1969,
            "shows": [
              "gd73-06-10.sbd.hollister.174.sbeok.shnf",
              "gd75-08-13.fm.vernon.23661.sbeok.shnf",
              "gd69-12-26.sbd.murphy.1821.sbeok.shnf",
              "gd70-02-11.early-late.sbd.sacks.90.sbefail.shnf"
            ]
          },
          {
            "id": "st-stephen",
            "title": "St. Stephen",
            "playCount": 289,
            "originalArtist": "Grateful Dead",
            "debutYear": 1968,
            "shows": [
              "gd_nrps70-05-15.sbd.reynolds-kaplan.29473.shnf",
              "gd1978-12-16.sonyecm250-no-dolby.walker-scotton.miller.82212.sbeok.flac16",
              "gd86-12-15.nakcm101-dwonk.25263.sbeok.flacf"
            ]
          },
          {
            "id": "terrapin-station",
            "title": "Terrapin Station",
            "playCount": 302,
            "originalArtist": "Grateful Dead",
            "debutYear": 1977,
            "shows": [
              "gd89-10-09.sbd.serafin.7721.sbeok.shnf",
              "gd74-02-24.sbd.windsor.199.sbefail.shnf",
              "gd90-07-23.sbd.oconner.7612.sbeok.shnf"
            ]
          },
          {
            "id": "sugaree",
            "title": "Sugaree",
            "playCount": 356,
            "originalArtist": "Jerry Garcia",
            "debutYear": 1971,
            "shows": [
              "gd90-03-29.aud-fob.set2.unknown.1317.sbeok.shnf",
              "gd73-02-09.sbd.bertha-fink.14939.sbeok.shnf",
              "gd77-09-03.sbd.unk.276.sbefixed.shnf",
              "gd70-02-11.early-late.sbd.sacks.90.sbefail.shnf"
            ]
          },
          {
            "id": "china-cat-sunflower",
            "title": "China Cat Sunflower",
            "playCount": 555,
            "originalArtist": "Grateful Dead",
            "debutYear": 1968,
            "shows": [
              "gd69-12-26.sbd.murphy.1821.sbeok.shnf",
              "gd90-03-29.sbd.nawrocki.3389.sbeok.shnf",
              "gd77-09-03.sbd.unk.276.sbefixed.shnf",
              "gd1969-01-18.tv.ukmutt.33931.flac16"
            ]
          },
          {
            "id": "i-know-you-rider",
            "title": "I Know You Rider",
            "playCount": 802,
            "originalArtist": "Traditional",
            "debutYear": 1965,
            "shows": [
              "gd78-01-22.sbd.popi.4974.sbeok.shnf",
              "gd69-12-26.sbd.murphy.1821.sbeok.shnf",
              "gd1969-01-18.tv.ukmutt.33931.flac16",
              "gd77-05-08.maizner.hicks.5002.sbeok.shnf"
            ]
          },
          {
            "id": "shakedown-street",
            "title": "Shakedown Street",
            "playCount": 169,
            "originalArtist": "Grateful Dead",
            "debutYear": 1978,
            "shows": [
              "gd70-02-11.early-late.sbd.sacks.90.sbefail.shnf",
              "gd77-05-08.maizner.hicks.5002.sbeok.shnf",
              "gd1977-06-09.28614.sbeok.flac16",
              "gd71-02-18.sbd.orf.107.sbeok.shnf"
            ]
          },
          {
            "id": "althea",
            "title": "Althea",
            "playCount": 272,
            "originalArtist": "Grateful Dead",
            "debutYear": 1979,
            "shows": [
              "gd89-10-09.sbd.serafin.7721.sbeok.shnf",
              "gd_nrps70-05-15.sbd.reynolds-kaplan.29473.shnf",
              "gd86-12-15.nakcm101-dwonk.25263.sbeok.flacf",
              "gd77-09-03.sbd.unk.276.sbefixed.shnf",
              "gd71-02-18.sbd.orf.107.sbeok.shnf"
            ]
          },
          {
            "id": "franklins-tower",
            "title": "Franklin's Tower",
            "playCount": 224,
            "originalArtist": "Grateful Dead",
            "debutYear": 1975,
            "shows": [
              "gd89-10-09.sbd.serafin.7721.sbeok.shnf",
              "gd1975-06-17.aud.unknown.87560.flac16",
              "gd75-08-13.fm.vernon.23661.sbeok.shnf"
            ]
          },
          {
            "id": "help-on-the-way",
            "title": "Help on the Way",
            "playCount": 113,
            "originalArtist": "Grateful Dead",
            "debutYear": 1975,
            "shows": [
              "gd72-08-27.sbd.orf.3328.sbeok.shnf",
              "gd89-07-07.aud.wiley.7855.sbeok.shnf",
              "gd70-05-15.early-late.sbd.97.sbeok.shnf",
              "gd71-02-18.sbd.orf.107.sbeok.shnf"
            ]
          },
          {
            "id": "slipknot",
            "title": "Slipknot!",
            "playCount": 113,
            "originalArtist": "Grateful Dead",
            "debutYear": 1974,
            "shows": [
              "gd79-01-11.gatto.kempka.308.sbeok.shnf",
              "gd1970-11-08.aud.weiner.28609.sbeok.shnf",
              "gd89-07-04.aud.wiley.9045.sbeok.shnf"
            ]
          },
          {
            "id": "truckin",
            "title": "Truckin'",
            "playCount": 519,
            "originalArtist": "Grateful Dead",
            "debutYear": 1970,
            "shows": [
              "gd70-02-11.early-late.sbd.sacks.90.sbefail.shnf",
              "gd73-07-28.sbd.weiner.14196.sbeok.shnf",
              "gd1983-10-17.mtx.seamons.fix2.92424.sbeok.flac16"
            ]
          },
          {
            "id": "uncle-johns-band",
            "title": "Uncle John's Band",
            "playCount": 332,
            "originalArtist": "Grateful Dead",
            "debutYear": 1969,
            "shows": [
              "gd77-09-03.sbd.unk.276.sbefixed.shnf",
              "gd1975-06-17.aud.unknown.87560.flac16",
              "gd90-07-23.sbd.oconner.7612.sbeok.shnf",
              "gd71-12-14.sbd.deibert.12763.sbeok.shnf",
              "gd77-05-05.sbd.stephens.8832.sbeok.shnf"
            ]
          },
          {
            "id": "wharf-rat",
            "title": "Wharf Rat",
            "playCount": 394,
            "originalArtist": "Grateful Dead",
            "debutYear": 1971,
            "shows": [
              "gd86-12-15.nakcm101-dwonk.25263.sbeok.flacf",
              "gd1977-06-09.28614.sbeok.flac16",
              "gd89-07-17.sbd.unknown.17702.sbeok.shnf",
              "gd87-04-03.sennme80.clark-miller.24898.sbeok.shnf"
            ]
          },
          {
            "id": "bird-song",
            "title": "Bird Song",
            "playCount": 296,
            "originalArtist": "Jerry Garcia",
            "debutYear": 1971,
            "shows": [
              "gd1983-10-17.mtx.seamons.fix2.92424.sbeok.flac16",
              "gd70-05-15.early-late.sbd.97.sbeok.shnf",
              "gd90-03-29.sbd.nawrocki.3389.sbeok.shnf",
              "gd71-08-06.aud.bertrando.yerys.129.sbeok.shnf"
            ]
          },
          {
            "id": "cassidy",
            "title": "Cassidy",
            "playCount": 340,
            "originalArtist": "Bob Weir",
            "debutYear": 1974,
            "shows": [
              "gd70-09-20.aud.remaster.sirmick.27583.sbeok.shnf",
              "gd79-01-08.gatto.glyde.10283.sbeok.shnf",
              "gd70-02-11.early-late.sbd.sacks.90.sbefail.shnf",
              "gd95-07-09.sbd.7233.sbeok.shnf"
            ]
          },
          {
            "id": "dire-wolf",
            "title": "Dire Wolf",
            "playCount": 226,
            "originalArtist": "Grateful Dead",
            "debutYear": 1969,
            "shows": [
              "gd77-02-26.sbd.alphadog.9752.sbeok.shnf",
              "gd73-06-10.sbd.hollister.174.sbeok.shnf",
              "gd90-03-29.aud-fob.set2.unknown.1317.sbeok.shnf",
              "gd77-05-08.maizner.hicks.5002.sbeok.shnf",
              "gd78-01-22.sbd.popi.4974.sbeok.shnf"
            ]
          },
          {
            "id": "estimated-prophet",
            "title": "Estimated Prophet",
            "playCount": 387,
            "originalArtist": "Grateful Dead",
            "debutYear": 1977,
            "shows": [
              "gd87-09-18.sbd.samaritano.20025.sbeok.shnf",
              "gd74-05-19.sbd.clugston.6957.sbeok.shnf",
              "gd1978-12-16.sonyecm250-no-dolby.walker-scotton.miller.82212.sbeok.flac16",
              "gd74-08-06.merin.weiner.gdADT.5914.sbefail.shnf",
              "gd1975-06-17.aud.unknown.87560.flac16"
            ]
          },
          {
            "id": "brown-eyed-women",
            "title": "Brown-Eyed Women",
            "playCount": 345,
            "originalArtist": "Grateful Dead",
            "debutYear": 1971,
            "shows": [
              "gd74-05-19.sbd.clugston.6957.sbeok.shnf",
              "gd1978-12-16.sonyecm250-no-dolby.walker-scotton.miller.82212.sbeok.flac16",
              "gd71-08-06.aud.bertrando.yerys.129.sbeok.shnf",
              "gd74-02-24.sbd.windsor.199.sbefail.shnf",
              "gd77-05-08.sbd.hicks.4982.sbeok.shnf"
            ]
          },
          {
            "id": "jack-straw",
            "title": "Jack Straw",
            "playCount": 472,
            "originalArtist": "Grateful Dead",
            "debutYear": 1971,
            "shows": [
              "gd71-02-18.sbd.orf.107.sbeok.shnf",
              "gd73-02-15.sbd.hall.1580.sbeok.shnf",
              "gd95-07-09.sbd.7233.sbeok.shnf",
              "gd75-08-13.fm.vernon.23661.sbeok.shnf",
              "gd1975-06-17.aud.unknown.87560.flac16"
            ]
          },
          {
            "id": "going-down-the-road-feeling-bad",
            "title": "Going Down the Road Feeling Bad",
            "playCount": 293,
            "originalArtist": "Traditional",
            "debutYear": 1970,
            "shows": [
              "gd77-05-08.maizner.hicks.5002.sbeok.shnf",
              "gd75-08-13.fm.vernon.23661.sbeok.shnf",
              "gd65-11-03.sbd.vernon.9044.sbeok.shnf",
              "gd69-12-26.sbd.murphy.1821.sbeok.shnf"
            ]
          },
          {
            "id": "ripple",
            "title": "Ripple",
            "playCount": 40,
            "originalArtist": "Grateful Dead",
            "debutYear": 1970,
            "shows": [
              "gd1983-10-17.mtx.seamons.fix2.92424.sbeok.flac16",
              "gd74-05-19.sbd.clugston.6957.sbeok.shnf",
              "gd78-01-22.sbd.popi.4974.sbeok.shnf"
            ]
          },
          {
            "id": "stella-blue",
            "title": "Stella Blue",
            "playCount": 322,
            "originalArtist": "Grateful Dead",
            "debutYear": 1972,
            "shows": [
              "gd77-09-03.sbd.unk.276.sbefixed.shnf",
              "gd1975-06-17.aud.unknown.87560.flac16",
              "gd1983-10-17.mtx.seamons.fix2.92424.sbeok.flac16",
              "gd1977-06-09.28614.sbeok.flac16"
            ]
          },
          {
            "id": "me-and-my-uncle",
            "title": "Me and My Uncle",
            "playCount": 916,
            "originalArtist": "John Phillips",
            "debutYear": 1966,
            "shows": [
              "gd90-07-23.sbd.oconner.7612.sbeok.shnf",
              "gd77-05-05.sbd.stephens.8832.sbeok.shnf",
              "gd73-02-09.sbd.bertha-fink.14939.sbeok.shnf",
              "gd74-05-19.sbd.clugston.6957.sbeok.shnf",
              "gd78-01-22.sbd.popi.4974.sbeok.shnf"
            ]
          },
          {
            "id": "sugar-magnolia",
            "title": "Sugar Magnolia",
            "playCount": 596,
            "originalArtist": "Grateful Dead",
            "debutYear": 1970,
            "shows": [
              "gd1970-11-08.aud.weiner.28609.sbeok.shnf",
              "gd77-02-26.sbd.alphadog.9752.sbeok.shnf",
              "gd74-05-19.sbd.clugston.6957.sbeok.shnf",
              "gd87-04-03.sennme80.clark-miller.24898.sbeok.shnf",
              "gd1977-06-09.28614.sbeok.flac16"
            ]
          },
          {
            "id": "around-and-around",
            "title": "Around and Around",
            "playCount": 414,
            "originalArtist": "Chuck Berry",
            "debutYear": 1970,
            "shows": [
              "gd78-01-22.sbd.popi.4974.sbeok.shnf",
              "gd_nrps70-05-15.sbd.reynolds-kaplan.29473.shnf",
              "gd75-08-13.fm.vernon.23661.sbeok.shnf",
              "gd95-07-09.sbd.7233.sbeok.shnf"
            ]
          },
          {
            "id": "good-lovin",
            "title": "Good Lovin'",
            "playCount": 406,
            "originalArtist": "The Olympics / The Rascals",
            "debutYear": 1969,
            "shows": [
              "gd1977-05-08.shure57.stevenson.29303.flac16",
              "gd77-05-08.sbd.hicks.4982.sbeok.shnf",
              "gd89-07-07.aud.wiley.7855.sbeok.shnf",
              "gd87-09-18.sbd.samaritano.20025.sbeok.shnf"
            ]
          }
        ]
        """
        
        let data = rawJSON.data(using: .utf8)!
        do {
            let decoder = JSONDecoder()
            allSongs = try decoder.decode([Song].self, from: data)
            
            // Sort alphabetically by default
            allSongs.sort { $0.title < $1.title }
        } catch {
            print("Error parsing embedded songs db: \\(error)")
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
