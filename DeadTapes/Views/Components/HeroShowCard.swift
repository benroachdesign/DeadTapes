import SwiftUI

struct HeroShowCard: View {
    let show: Show
    var isVisible: Bool = true

    var body: some View {
        NavigationLink(destination: ShowDetailView(show: show)) {
            VStack(alignment: .leading, spacing: DeadTheme.Spacing.lg) {
                // Year badge
                HStack {
                    Text(show.yearString)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DeadTheme.Colors.accent, DeadTheme.Colors.psychPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        SourceBadge(source: show.source)

                        if let rating = show.avgRating {
                            HStack(spacing: 3) {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < show.ratingStars ? "star.fill" : "star")
                                        .font(.system(size: 10))
                                        .foregroundStyle(
                                            i < show.ratingStars ?
                                            DeadTheme.Colors.accent : DeadTheme.Colors.textTertiary
                                        )
                                }
                                Text(String(format: "%.1f", rating))
                                    .font(DeadTheme.Typography.monoSmall())
                                    .foregroundStyle(DeadTheme.Colors.textSecondary)
                            }
                        }
                    }
                }

                // Venue
                Text(show.venue)
                    .font(DeadTheme.Typography.title())
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                    .multilineTextAlignment(.leading)

                // City & Date
                HStack {
                    if !show.city.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                            Text(show.city)
                        }
                        .font(DeadTheme.Typography.caption())
                        .foregroundStyle(DeadTheme.Colors.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 12))
                        Text(show.formattedDownloads + " plays")
                    }
                    .font(DeadTheme.Typography.caption())
                    .foregroundStyle(DeadTheme.Colors.textTertiary)
                }

                // CTA
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                        Text("Listen Now")
                            .font(DeadTheme.Typography.caption())
                    }
                    .foregroundStyle(DeadTheme.Colors.background)
                    .padding(.horizontal, DeadTheme.Spacing.lg)
                    .padding(.vertical, DeadTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(DeadTheme.Colors.accent)
                            .shadow(color: DeadTheme.Colors.accent.opacity(0.4), radius: 8, y: 2)
                    )
                }
            }
            .padding(DeadTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DeadTheme.Radius.xl)
                    .fill(DeadTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DeadTheme.Radius.xl)
                            .fill(DeadTheme.Gradients.cardGlow)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DeadTheme.Radius.xl)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        DeadTheme.Colors.accent.opacity(0.3),
                                        DeadTheme.Colors.psychPurple.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: DeadTheme.Colors.accent.opacity(0.1), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DeadTheme.Spacing.lg)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }
}
