import SwiftUI

struct NowPlayingFullView: View {
    @Environment(AudioPlayerService.self) private var audioPlayer
    @Environment(PlayerViewModel.self) private var playerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showQueue = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        @Bindable var audio = audioPlayer

        ZStack {
            // Background
            backgroundLayer

            VStack(spacing: 0) {
                // Drag handle
                dragHandle

                if showQueue {
                    queueView
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    playerView
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        dismiss()
                    }
                    withAnimation(DeadTheme.Animation.springy) {
                        dragOffset = 0
                    }
                }
        )
        .offset(y: dragOffset)
        .interactiveDismissDisabled(false)
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            DeadTheme.Colors.background.ignoresSafeArea()

            // Animated mesh gradient
            AnimatedGradientBackground(
                colors: eraColors
            )
            .opacity(0.6)

            // Additional blur overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .opacity(0.3)
                .ignoresSafeArea()
        }
    }

    private var eraColors: [Color] {
        let year = audioPlayer.currentShow?.year ?? 1977
        switch year {
        case ...1969:
            return [
                Color(hex: "DC2626").opacity(0.4),
                Color(hex: "F97316").opacity(0.3),
                Color(hex: "FBBF24").opacity(0.2),
                DeadTheme.Colors.background
            ]
        case 1970...1974:
            return [
                Color(hex: "B45309").opacity(0.4),
                Color(hex: "D97706").opacity(0.3),
                Color(hex: "92400E").opacity(0.25),
                DeadTheme.Colors.background
            ]
        case 1975...1979:
            return [
                Color(hex: "D97706").opacity(0.35),
                Color(hex: "78350F").opacity(0.3),
                Color(hex: "B45309").opacity(0.25),
                DeadTheme.Colors.background
            ]
        case 1980...1989:
            return [
                Color(hex: "7C3AED").opacity(0.4),
                Color(hex: "EC4899").opacity(0.3),
                Color(hex: "06B6D4").opacity(0.2),
                DeadTheme.Colors.background
            ]
        default:
            return [
                DeadTheme.Colors.psychPurple.opacity(0.3),
                DeadTheme.Colors.psychPink.opacity(0.2),
                DeadTheme.Colors.psychBlue.opacity(0.25),
                DeadTheme.Colors.background
            ]
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        VStack(spacing: DeadTheme.Spacing.lg) {
            Capsule()
                .fill(DeadTheme.Colors.textTertiary.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, DeadTheme.Spacing.sm)

            HStack {
                Spacer()
                Button {
                    withAnimation(DeadTheme.Animation.springy) {
                        showQueue.toggle()
                    }
                } label: {
                    Image(systemName: showQueue ? "music.note" : "list.bullet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DeadTheme.Colors.textSecondary)
                        .contentTransition(.symbolEffect(.replace))
                        .padding(DeadTheme.Spacing.sm)
                }
            }
            .padding(.horizontal, DeadTheme.Spacing.lg)
        }
    }

    // MARK: - Player View

    private var playerView: some View {
        VStack(spacing: DeadTheme.Spacing.xxl) {
            Spacer()

            // Circular progress
            CircularProgressSlider(
                progress: Binding(
                    get: { audioPlayer.progress },
                    set: { _ in }
                )
            ) { newProgress in
                audioPlayer.seekToProgress(newProgress)
            }
            .frame(width: 260, height: 260)
            .overlay {
                // Center content
                VStack(spacing: DeadTheme.Spacing.xs) {
                    if audioPlayer.isLoading {
                        ProgressView()
                            .tint(DeadTheme.Colors.accent)
                    } else {
                        Text(formatTime(audioPlayer.currentTime))
                            .font(.system(size: 36, weight: .light, design: .monospaced))
                            .foregroundStyle(DeadTheme.Colors.textPrimary)

                        Text(formatTime(audioPlayer.duration))
                            .font(DeadTheme.Typography.monoSmall())
                            .foregroundStyle(DeadTheme.Colors.textTertiary)
                    }
                }
            }

            // Track info
            VStack(spacing: DeadTheme.Spacing.sm) {
                Text(audioPlayer.currentTrack?.title ?? "—")
                    .font(DeadTheme.Typography.title2())
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if let show = audioPlayer.currentShow {
                    Text("\(show.formattedDate) • \(show.venue)")
                        .font(DeadTheme.Typography.caption())
                        .foregroundStyle(DeadTheme.Colors.textSecondary)
                        .lineLimit(1)

                    if !show.city.isEmpty {
                        Text(show.city)
                            .font(DeadTheme.Typography.monoSmall())
                            .foregroundStyle(DeadTheme.Colors.textTertiary)
                    }
                }

                // Track position
                if !audioPlayer.queue.isEmpty {
                    Text("\(audioPlayer.currentIndex + 1) of \(audioPlayer.queue.count)")
                        .font(DeadTheme.Typography.monoSmall())
                        .foregroundStyle(DeadTheme.Colors.textTertiary)
                        .padding(.top, DeadTheme.Spacing.xs)
                }
            }
            .padding(.horizontal, DeadTheme.Spacing.xl)

            // Transport controls
            transportControls

            Spacer()
        }
    }

    // MARK: - Transport Controls

    private var transportControls: some View {
        HStack(spacing: DeadTheme.Spacing.hero) {
            // Previous
            Button {
                audioPlayer.previous()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
            }

            // Play/Pause
            Button {
                audioPlayer.togglePlayPause()
            } label: {
                ZStack {
                    Circle()
                        .fill(DeadTheme.Colors.accent)
                        .frame(width: 64, height: 64)
                        .shadow(color: DeadTheme.Colors.accent.opacity(0.4), radius: 12, y: 4)

                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(DeadTheme.Colors.background)
                        .contentTransition(.symbolEffect(.replace))
                }
            }

            // Next
            Button {
                audioPlayer.next()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
            }
        }
        .padding(.top, DeadTheme.Spacing.md)
    }

    // MARK: - Queue View

    private var queueView: some View {
        VStack(alignment: .leading, spacing: DeadTheme.Spacing.md) {
            Text("UP NEXT")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(DeadTheme.Colors.accent)
                .tracking(2)
                .padding(.horizontal, DeadTheme.Spacing.xl)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(audioPlayer.queue.enumerated()), id: \.element.id) { index, track in
                        let isCurrentTrack = index == audioPlayer.currentIndex

                        HStack(spacing: DeadTheme.Spacing.md) {
                            if isCurrentTrack {
                                NowPlayingBars()
                                    .frame(width: 20, height: 14)
                            } else {
                                Text("\(index + 1)")
                                    .font(DeadTheme.Typography.monoSmall())
                                    .foregroundStyle(DeadTheme.Colors.textTertiary)
                                    .frame(width: 20)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title)
                                    .font(DeadTheme.Typography.body())
                                    .foregroundStyle(
                                        isCurrentTrack ?
                                        DeadTheme.Colors.accent :
                                        DeadTheme.Colors.textPrimary
                                    )
                                    .lineLimit(1)

                                Text(track.setName)
                                    .font(DeadTheme.Typography.monoSmall())
                                    .foregroundStyle(DeadTheme.Colors.textTertiary)
                            }

                            Spacer()

                            Text(track.formattedDuration)
                                .font(DeadTheme.Typography.monoSmall())
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                        }
                        .padding(.horizontal, DeadTheme.Spacing.xl)
                        .padding(.vertical, DeadTheme.Spacing.sm)
                        .background(
                            isCurrentTrack ?
                            DeadTheme.Colors.elevatedBackground.opacity(0.5) :
                            Color.clear
                        )
                        .onTapGesture {
                            if !isCurrentTrack, let show = audioPlayer.currentShow {
                                audioPlayer.play(track: track, in: audioPlayer.queue, show: show)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
