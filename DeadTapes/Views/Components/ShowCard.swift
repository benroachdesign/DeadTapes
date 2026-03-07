import SwiftUI

struct SourceBadge: View {
    let source: String

    private var label: String {
        let s = source.lowercased()
        if s.contains("soundboard") || s.contains("sbd") { return "SBD" }
        if s.contains("matrix") { return "MTX" }
        return "AUD"
    }

    private var color: Color {
        switch label {
        case "SBD": return DeadTheme.Colors.sbd
        case "MTX": return DeadTheme.Colors.matrix
        default: return DeadTheme.Colors.aud
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
                    .overlay(
                        Capsule()
                            .strokeBorder(color.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Show Card

struct ShowCard: View {
    let show: Show
    var isCompact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DeadTheme.Spacing.sm) {
            // Date & Source
            HStack {
                Text(show.formattedDate)
                    .font(DeadTheme.Typography.mono())
                    .foregroundStyle(DeadTheme.Colors.accent)

                SourceBadge(source: show.source)

                Spacer()

                if let rating = show.avgRating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(DeadTheme.Colors.accent)
                        Text(String(format: "%.1f", rating))
                            .font(DeadTheme.Typography.monoSmall())
                            .foregroundStyle(DeadTheme.Colors.textSecondary)
                    }
                }
            }

            // Venue
            Text(show.venue)
                .font(isCompact ? DeadTheme.Typography.body() : DeadTheme.Typography.headline())
                .foregroundStyle(DeadTheme.Colors.textPrimary)
                .lineLimit(isCompact ? 1 : 2)

            // City & Downloads
            HStack {
                if !show.city.isEmpty {
                    Text(show.city)
                        .font(DeadTheme.Typography.caption())
                        .foregroundStyle(DeadTheme.Colors.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 10))
                    Text(show.formattedDownloads)
                        .font(DeadTheme.Typography.monoSmall())
                }
                .foregroundStyle(DeadTheme.Colors.textTertiary)
            }
        }
        .padding(DeadTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DeadTheme.Radius.md)
                .fill(DeadTheme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DeadTheme.Radius.md)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    DeadTheme.Colors.textTertiary.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Track Row

struct TrackRow: View {
    let track: Track
    let isPlaying: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DeadTheme.Spacing.md) {
                // Track number or playing indicator
                ZStack {
                    if isPlaying {
                        NowPlayingBars()
                            .frame(width: 20, height: 16)
                    } else {
                        Text("\(track.trackNumber)")
                            .font(DeadTheme.Typography.mono())
                            .foregroundStyle(DeadTheme.Colors.textTertiary)
                    }
                }
                .frame(width: 28)

                // Title
                Text(track.title)
                    .font(DeadTheme.Typography.body())
                    .foregroundStyle(isPlaying ? DeadTheme.Colors.accent : DeadTheme.Colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                // Duration
                Text(track.formattedDuration)
                    .font(DeadTheme.Typography.monoSmall())
                    .foregroundStyle(DeadTheme.Colors.textTertiary)
            }
            .padding(.vertical, DeadTheme.Spacing.sm)
            .padding(.horizontal, DeadTheme.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(TrackButtonStyle())
    }
}

// MARK: - Now Playing Bars Animation

struct NowPlayingBars: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(DeadTheme.Colors.accent)
                    .frame(width: 3)
                    .scaleEffect(y: animating ? CGFloat.random(in: 0.3...1.0) : 0.5, anchor: .bottom)
                    .animation(
                        .easeInOut(duration: 0.4 + Double(i) * 0.15)
                        .repeatForever(autoreverses: true),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Button Styles

struct TrackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: DeadTheme.Radius.sm)
                    .fill(configuration.isPressed ?
                          DeadTheme.Colors.elevatedBackground : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
