import SwiftUI

struct SongDetailView: View {
    @State var viewModel: SongDetailViewModel
    @Environment(AudioPlayerService.self) private var audioPlayer
    
    var body: some View {
        ZStack {
            DeadTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DeadTheme.Spacing.xl) {
                    
                    // Header
                    VStack(alignment: .center, spacing: DeadTheme.Spacing.md) {
                        Text(viewModel.song.title)
                            .font(DeadTheme.Typography.largeTitle())
                            .foregroundStyle(DeadTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: DeadTheme.Spacing.lg) {
                            statBadge(value: "\(viewModel.song.playCount)", label: "Total Plays")
                            statBadge(value: String(viewModel.song.debutYear), label: "Debut Year")
                        }
                        
                        if viewModel.song.originalArtist != "Grateful Dead" {
                            Text("Original Artist: \(viewModel.song.originalArtist)")
                                .font(DeadTheme.Typography.caption())
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                                .padding(.top, 4)
                        }
                        
                        // Play Random Action
                        Button(action: playRandomVersion) {
                            HStack {
                                Image(systemName: "dice.fill")
                                Text("Play Random Version")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [DeadTheme.Colors.accent, Color(hex: "FF4500")], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .padding(.top, DeadTheme.Spacing.md)
                        }
                    }
                    .padding(.horizontal, DeadTheme.Spacing.lg)
                    .padding(.top, DeadTheme.Spacing.lg)
                    
                    // Show List Title
                    Text("Notable Performances")
                        .font(DeadTheme.Typography.title2())
                        .foregroundStyle(DeadTheme.Colors.textPrimary)
                        .padding(.horizontal, DeadTheme.Spacing.lg)
                        .padding(.top, DeadTheme.Spacing.md)
                    
                    // Shows
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(DeadTheme.Colors.accent)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = viewModel.errorMessage {
                        Text("Error loading shows: \(error)")
                            .foregroundStyle(.red)
                            .padding()
                    } else if viewModel.recentShows.isEmpty {
                        Text("No specific performances tracked for this song in our database yet.")
                            .font(DeadTheme.Typography.body())
                            .foregroundStyle(DeadTheme.Colors.textSecondary)
                            .padding(.horizontal, DeadTheme.Spacing.lg)
                    } else {
                        LazyVStack(spacing: DeadTheme.Spacing.md) {
                            ForEach(viewModel.recentShows) { show in
                                NavigationLink(destination: ShowDetailView(show: show)) {
                                    ShowCard(show: show)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, DeadTheme.Spacing.lg)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadShows()
        }
    }
    
    private func statBadge(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(DeadTheme.Colors.accent)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(DeadTheme.Colors.textTertiary)
                .tracking(1)
        }
        .padding(.horizontal, DeadTheme.Spacing.md)
        .padding(.vertical, DeadTheme.Spacing.sm)
        .background(DeadTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func playRandomVersion() {
        guard let randomShow = viewModel.randomShow() else { return }
        
        Task {
            // Need to fetch full files to play
            do {
                let tracks = try await ArchiveAPI.shared.fetchTracks(for: randomShow.identifier)
                // Find the index of this song in the tracks
                // We'll fuzzy match the track title against the song title
                let lowerSongTitle = viewModel.song.title.lowercased()
                
                var startIndex = 0
                if let idx = tracks.firstIndex(where: { $0.title.lowercased().contains(lowerSongTitle) }) {
                    startIndex = idx
                }
                
                await MainActor.run {
                    audioPlayer.play(track: tracks[startIndex], in: tracks, show: randomShow)
                }
            } catch {
                print("Failed to start random song version: \\(error)")
            }
        }
    }
}
