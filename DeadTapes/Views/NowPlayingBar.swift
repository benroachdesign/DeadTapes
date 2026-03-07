import SwiftUI

struct NowPlayingBar: View {
    @Environment(AudioPlayerService.self) private var audioPlayer
    @Environment(PlayerViewModel.self) private var playerViewModel

    var body: some View {
        Button {
            playerViewModel.isFullScreenPresented = true
        } label: {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(DeadTheme.Colors.progressTrack)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [DeadTheme.Colors.accent, DeadTheme.Colors.psychPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * audioPlayer.progress)
                            .animation(.linear(duration: 0.5), value: audioPlayer.progress)
                    }
                }
                .frame(height: 2)

                // Content
                HStack(spacing: DeadTheme.Spacing.md) {
                    // Track info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(audioPlayer.currentTrack?.title ?? "Not Playing")
                            .font(DeadTheme.Typography.body())
                            .foregroundStyle(DeadTheme.Colors.textPrimary)
                            .lineLimit(1)

                        if let show = audioPlayer.currentShow {
                            Text("\(show.shortDate) • \(show.venue)")
                                .font(DeadTheme.Typography.monoSmall())
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Controls
                    HStack(spacing: DeadTheme.Spacing.lg) {
                        Button {
                            audioPlayer.togglePlayPause()
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(DeadTheme.Colors.textPrimary)
                                .contentTransition(.symbolEffect(.replace))
                        }

                        Button {
                            audioPlayer.next()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(DeadTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, DeadTheme.Spacing.lg)
                .padding(.vertical, DeadTheme.Spacing.md)
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .overlay(
                        Rectangle()
                            .fill(DeadTheme.Colors.background.opacity(0.7))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
