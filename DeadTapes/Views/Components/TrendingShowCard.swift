import SwiftUI

struct TrendingShowCard: View {
    let show: Show

    var body: some View {
        VStack(alignment: .leading, spacing: DeadTheme.Spacing.md) {
            HStack {
                Text("TRENDING THIS WEEK")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(DeadTheme.Colors.textTertiary)
                    .tracking(2)
                Spacer()
            }
            .padding(.horizontal, DeadTheme.Spacing.xl)

            NavigationLink(destination: ShowDetailView(show: show)) {
                VStack(alignment: .leading, spacing: DeadTheme.Spacing.lg) {
                    HStack(alignment: .top) {
                        // Crown + rank
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "FFD700"))
                            Text("#1")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: "FFD700"))
                        }

                        Spacer()

                        // Year
                        Text(show.yearString)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), DeadTheme.Colors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    Text(show.venue)
                        .font(DeadTheme.Typography.headline())
                        .foregroundStyle(DeadTheme.Colors.textPrimary)
                        .multilineTextAlignment(.leading)

                    HStack {
                        if !show.city.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 11))
                                Text(show.city)
                            }
                            .font(DeadTheme.Typography.caption())
                            .foregroundStyle(DeadTheme.Colors.textSecondary)
                        }

                        Spacer()

                        HStack(spacing: DeadTheme.Spacing.md) {
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

                            HStack(spacing: 3) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 10))
                                Text(show.formattedDownloads)
                                    .font(DeadTheme.Typography.monoSmall())
                            }
                            .foregroundStyle(DeadTheme.Colors.textTertiary)
                        }
                    }
                }
                .padding(DeadTheme.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: DeadTheme.Radius.xl)
                        .fill(DeadTheme.Colors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: DeadTheme.Radius.xl)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FFD700").opacity(0.3),
                                            Color(hex: "FFD700").opacity(0.05),
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
            .buttonStyle(.plain)
            .padding(.horizontal, DeadTheme.Spacing.lg)
        }
    }
}
