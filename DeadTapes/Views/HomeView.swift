import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                DeadTheme.Colors.background.ignoresSafeArea()

                AnimatedGradientBackground()

                ScrollView {
                    VStack(spacing: DeadTheme.Spacing.xl) {
                        // Header
                        headerSection

                        if viewModel.isLoading {
                            loadingSection
                        } else if let topShow = viewModel.topShow {
                            // Hero show card
                            heroCard(for: topShow)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))

                            // Other shows on this day
                            if !viewModel.otherShows.isEmpty {
                                otherShowsSection
                            }
                        } else if viewModel.errorMessage != nil {
                            errorSection
                        } else {
                            emptySection
                        }
                    }
                    .padding(.bottom, 100) // Space for Now Playing bar
                }
                .refreshable {
                    await viewModel.loadTodayInHistory()
                }
            }
            .navigationBarHidden(true)
            .task {
                if viewModel.todayShows.isEmpty {
                    await viewModel.loadTodayInHistory()
                    withAnimation(DeadTheme.Animation.smooth) {
                        showAppeared = true
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DeadTheme.Spacing.xs) {
            Text("ON THIS DAY")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(DeadTheme.Colors.accent)
                .tracking(3)

            Text(viewModel.todayDateString)
                .font(DeadTheme.Typography.largeTitle())
                .foregroundStyle(DeadTheme.Colors.textPrimary)

            if viewModel.hasShows {
                Text("\(viewModel.todayShows.count) show\(viewModel.todayShows.count == 1 ? "" : "s") on this date")
                    .font(DeadTheme.Typography.caption())
                    .foregroundStyle(DeadTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DeadTheme.Spacing.xl)
        .padding(.top, DeadTheme.Spacing.hero)
    }

    // MARK: - Hero Card

    private func heroCard(for show: Show) -> some View {
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
        .opacity(showAppeared ? 1 : 0)
        .offset(y: showAppeared ? 0 : 20)
    }

    // MARK: - Other Shows Section

    private var otherShowsSection: some View {
        VStack(alignment: .leading, spacing: DeadTheme.Spacing.md) {
            Text("MORE ON THIS DAY")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(DeadTheme.Colors.textTertiary)
                .tracking(2)
                .padding(.horizontal, DeadTheme.Spacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DeadTheme.Spacing.md) {
                    ForEach(Array(viewModel.otherShows.enumerated()), id: \.element.id) { index, show in
                        NavigationLink(destination: ShowDetailView(show: show)) {
                            VStack(alignment: .leading, spacing: DeadTheme.Spacing.sm) {
                                Text(show.yearString)
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(DeadTheme.eraGradient(for: show.year))

                                Text(show.venue)
                                    .font(DeadTheme.Typography.body())
                                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                HStack {
                                    if !show.city.isEmpty {
                                        Text(show.city)
                                            .font(DeadTheme.Typography.caption())
                                            .foregroundStyle(DeadTheme.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    SourceBadge(source: show.source)
                                }
                            }
                            .frame(width: 200)
                            .padding(DeadTheme.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DeadTheme.Radius.lg)
                                    .fill(DeadTheme.Colors.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DeadTheme.Radius.lg)
                                            .strokeBorder(
                                                DeadTheme.Colors.textTertiary.opacity(0.1),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .opacity(showAppeared ? 1 : 0)
                        .offset(y: showAppeared ? 0 : 15)
                        .animation(
                            DeadTheme.Animation.smooth.delay(Double(index) * 0.08),
                            value: showAppeared
                        )
                    }
                }
                .padding(.horizontal, DeadTheme.Spacing.xl)
            }
        }
    }

    // MARK: - States

    private var loadingSection: some View {
        LoadingQuoteView()
            .frame(maxWidth: .infinity)
            .padding(.top, DeadTheme.Spacing.hero)
    }

    private var errorSection: some View {
        VStack(spacing: DeadTheme.Spacing.lg) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(DeadTheme.Colors.textTertiary)

            Text("Couldn't load shows")
                .font(DeadTheme.Typography.headline())
                .foregroundStyle(DeadTheme.Colors.textSecondary)

            Button {
                Task { await viewModel.loadTodayInHistory() }
            } label: {
                Text("Try Again")
                    .font(DeadTheme.Typography.caption())
                    .foregroundStyle(DeadTheme.Colors.accent)
                    .padding(.horizontal, DeadTheme.Spacing.xl)
                    .padding(.vertical, DeadTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .strokeBorder(DeadTheme.Colors.accent.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding(.top, DeadTheme.Spacing.hero)
    }

    private var emptySection: some View {
        VStack(spacing: DeadTheme.Spacing.lg) {
            Image(systemName: "music.note")
                .font(.system(size: 40))
                .foregroundStyle(DeadTheme.Colors.textTertiary)

            Text("No shows on this date")
                .font(DeadTheme.Typography.headline())
                .foregroundStyle(DeadTheme.Colors.textSecondary)

            Text("The Dead didn't play on every day, but they sure tried.")
                .font(DeadTheme.Typography.caption())
                .foregroundStyle(DeadTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DeadTheme.Spacing.hero)
        .padding(.horizontal, DeadTheme.Spacing.xl)
    }
}
