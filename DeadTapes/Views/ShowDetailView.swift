import SwiftUI
import SwiftData

struct ShowDetailView: View {
    let show: Show
    @State private var viewModel: ShowDetailViewModel
    @Environment(AudioPlayerService.self) private var audioPlayer
    @Environment(\.modelContext) private var modelContext
    @State private var tracksVisible = false

    init(show: Show) {
        self.show = show
        self._viewModel = State(initialValue: ShowDetailViewModel(show: show))
    }

    var body: some View {
        ZStack {
            DeadTheme.Colors.background.ignoresSafeArea()

            // Subtle gradient background
            VStack {
                DeadTheme.eraGradient(for: show.year)
                    .opacity(0.15)
                    .frame(height: 300)
                    .blur(radius: 60)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Show header
                    headerSection

                    // Track listing
                    if viewModel.isLoading {
                        loadingSection
                    } else if let error = viewModel.errorMessage {
                        errorSection(error)
                    } else {
                        trackListSection
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(DeadTheme.Animation.springy) {
                        viewModel.toggleFavorite(in: modelContext)
                    }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? DeadTheme.Colors.psychRose : DeadTheme.Colors.textSecondary)
                        .symbolEffect(.bounce, value: viewModel.isFavorite)
                }
            }
        }
        .task {
            viewModel.checkFavorite(in: modelContext)
            await viewModel.loadTracks()
            withAnimation(DeadTheme.Animation.smooth) {
                tracksVisible = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DeadTheme.Spacing.md) {
            // Date
            Text(show.formattedDate)
                .font(DeadTheme.Typography.mono())
                .foregroundStyle(DeadTheme.Colors.accent)

            // Venue
            Text(show.venue)
                .font(DeadTheme.Typography.title())
                .foregroundStyle(DeadTheme.Colors.textPrimary)

            // City & Source
            HStack(spacing: DeadTheme.Spacing.md) {
                if !show.city.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                        Text(show.city)
                    }
                    .font(DeadTheme.Typography.caption())
                    .foregroundStyle(DeadTheme.Colors.textSecondary)
                }

                SourceBadge(source: show.source)

                Spacer()

                if let rating = show.avgRating {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(DeadTheme.Colors.accent)
                        Text(String(format: "%.1f", rating))
                            .font(DeadTheme.Typography.mono())
                            .foregroundStyle(DeadTheme.Colors.textSecondary)
                        if let reviews = show.numReviews {
                            Text("(\(reviews))")
                                .font(DeadTheme.Typography.monoSmall())
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                        }
                    }
                }
            }

            // Play All button
            Button {
                if let firstTrack = viewModel.allTracks.first {
                    audioPlayer.play(track: firstTrack, in: viewModel.allTracks, show: show)
                }
            } label: {
                HStack(spacing: DeadTheme.Spacing.sm) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                    Text("Play Show")
                        .font(DeadTheme.Typography.headline())
                }
                .foregroundStyle(DeadTheme.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DeadTheme.Spacing.md)
                .background(
                    Capsule()
                        .fill(DeadTheme.Colors.accent)
                        .shadow(color: DeadTheme.Colors.accent.opacity(0.3), radius: 8, y: 3)
                )
            }
            .disabled(viewModel.allTracks.isEmpty)
            .opacity(viewModel.allTracks.isEmpty ? 0.5 : 1)
            .padding(.top, DeadTheme.Spacing.sm)

            // Downloads info
            HStack(spacing: DeadTheme.Spacing.lg) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 11))
                    Text(show.formattedDownloads + " downloads")
                }

                HStack(spacing: 4) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 11))
                    Text("\(viewModel.allTracks.count) tracks")
                }
            }
            .font(DeadTheme.Typography.monoSmall())
            .foregroundStyle(DeadTheme.Colors.textTertiary)
        }
        .padding(.horizontal, DeadTheme.Spacing.xl)
        .padding(.top, DeadTheme.Spacing.lg)
        .padding(.bottom, DeadTheme.Spacing.xl)
    }

    // MARK: - Track List

    private var trackListSection: some View {
        VStack(spacing: DeadTheme.Spacing.xl) {
            ForEach(Array(viewModel.trackSets.enumerated()), id: \.element.id) { setIndex, trackSet in
                VStack(alignment: .leading, spacing: DeadTheme.Spacing.xs) {
                    // Set header
                    Text(trackSet.name.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(DeadTheme.Colors.accent.opacity(0.7))
                        .tracking(2)
                        .padding(.horizontal, DeadTheme.Spacing.xl)
                        .padding(.bottom, DeadTheme.Spacing.xs)

                    Divider()
                        .background(DeadTheme.Colors.textTertiary.opacity(0.15))
                        .padding(.horizontal, DeadTheme.Spacing.lg)

                    // Tracks
                    ForEach(Array(trackSet.tracks.enumerated()), id: \.element.id) { trackIndex, track in
                        let isCurrentlyPlaying = audioPlayer.currentTrack?.id == track.id

                        TrackRow(
                            track: track,
                            isPlaying: isCurrentlyPlaying
                        ) {
                            audioPlayer.play(
                                track: track,
                                in: viewModel.allTracks,
                                show: show
                            )
                        }
                        .padding(.horizontal, DeadTheme.Spacing.sm)
                        .opacity(tracksVisible ? 1 : 0)
                        .offset(y: tracksVisible ? 0 : 8)
                        .animation(
                            DeadTheme.Animation.smooth.delay(
                                Double(setIndex) * 0.1 + Double(trackIndex) * 0.03
                            ),
                            value: tracksVisible
                        )
                    }
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingSection: some View {
        LoadingQuoteView()
            .frame(maxWidth: .infinity)
            .padding(.top, DeadTheme.Spacing.xl)
    }

    private func errorSection(_ error: String) -> some View {
        VStack(spacing: DeadTheme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(DeadTheme.Colors.textTertiary)

            Text(error)
                .font(DeadTheme.Typography.body())
                .foregroundStyle(DeadTheme.Colors.textSecondary)

            Button {
                Task { await viewModel.loadTracks() }
            } label: {
                Text("Retry")
                    .font(DeadTheme.Typography.caption())
                    .foregroundStyle(DeadTheme.Colors.accent)
            }
        }
        .padding(.top, DeadTheme.Spacing.hero)
    }
}
