# DeadTapes 🎶

A high-fidelity iOS app for streaming Grateful Dead concerts from the [Internet Archive](https://archive.org).

Built with SwiftUI, MVVM + `@Observable`, `AVQueuePlayer` (gapless playback), and SwiftData.

## Features

- **Today in History** — Shows played on this calendar day, ranked by popularity
- **Show Browser** — Filter by year (1965–1995), search venues
- **Set-Grouped Track Listings** — Set 1 / Set 2 / Encore structure
- **Gapless Streaming** — Essential for Dead sets, via `AVQueuePlayer`
- **Now Playing** — Mini-bar + full-screen player with circular progress slider
- **Background Audio** — Now Playing Info Center + remote controls
- **Favorites** — Save shows with SwiftData persistence
- **Dark Mode First** — "Modern Psychedelia" aesthetic with animated mesh gradients

## Requirements

- iOS 18.0+
- Xcode 16+
- Swift 5.9+

## Getting Started

1. Clone the repo
2. Open `DeadTapes.xcodeproj`
3. Select a simulator and hit ⌘R
4. Browse shows, tap a track, and enjoy the music ✌️

## Architecture

- **MVVM** with `@Observable` (no third-party dependencies)
- **Services**: `ArchiveAPI` (networking + caching), `AudioPlayerService` (playback)
- **SwiftData** for favorites persistence
- **Archive.org Advanced Search API** + Metadata API

## License

This project is for personal/educational use. Grateful Dead live recordings on Archive.org are shared under the band's taping policy.
