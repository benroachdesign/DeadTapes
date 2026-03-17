import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showAppeared = false
    @State private var randomShowScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ZStack {
                DeadTheme.Colors.background.ignoresSafeArea()

                AnimatedGradientBackground()

                ScrollView {
                    VStack(spacing: DeadTheme.Spacing.xl) {
                        if viewModel.isLoading {
                            loadingSection
                        } else {
                            // Header
                            headerSection
                            if let topShow = viewModel.topShow {
                                // Hero show card
                                HeroShowCard(show: topShow, isVisible: showAppeared)
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

                            // Random Show button
                            randomShowSection
                                .padding(.top, DeadTheme.Spacing.md)

                            // Trending This Week
                            if let trending = viewModel.trendingShow {
                                TrendingShowCard(show: trending)
                            }
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
                async let todayLoad: Void = viewModel.loadTodayInHistory()
                async let trendingLoad: Void = viewModel.loadTrendingShow()
                await todayLoad
                withAnimation(DeadTheme.Animation.smooth) { showAppeared = true }
                await trendingLoad
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

    // MARK: - Random Show

    private var randomShowSection: some View {
        VStack(spacing: DeadTheme.Spacing.md) {
            HStack {
                Text("FEELING LUCKY")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(DeadTheme.Colors.textTertiary)
                    .tracking(2)
                Spacer()
            }
            .padding(.horizontal, DeadTheme.Spacing.xl)

            VStack(spacing: DeadTheme.Spacing.lg) {
                Button {
                    withAnimation(DeadTheme.Animation.springy) {
                        randomShowScale = 0.95
                    }
                    Task {
                        await viewModel.loadRandomShow()
                        withAnimation(DeadTheme.Animation.springy) {
                            randomShowScale = 1.0
                        }
                    }
                } label: {
                    HStack(spacing: DeadTheme.Spacing.sm) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 16))
                            .symbolEffect(.bounce, value: viewModel.randomShow?.id)
                        Text(viewModel.randomShow == nil ? "Random Show" : "Roll Again")
                            .font(DeadTheme.Typography.headline())
                    }
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DeadTheme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DeadTheme.Radius.lg)
                            .fill(DeadTheme.Colors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: DeadTheme.Radius.lg)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                DeadTheme.Colors.psychPurple.opacity(0.4),
                                                DeadTheme.Colors.psychBlue.opacity(0.2),
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
                .disabled(viewModel.isLoadingRandom)
                .scaleEffect(randomShowScale)
                .padding(.horizontal, DeadTheme.Spacing.lg)

                // Random show result
                if viewModel.isLoadingRandom {
                    ProgressView()
                        .tint(DeadTheme.Colors.accent)
                        .transition(.opacity)
                } else if let show = viewModel.randomShow {
                    NavigationLink(destination: ShowDetailView(show: show)) {
                        randomShowCard(show: show)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
    }

    private func randomShowCard(show: Show) -> some View {
        HStack(spacing: DeadTheme.Spacing.lg) {
            Text(show.yearString)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(DeadTheme.eraGradient(for: show.year))

            VStack(alignment: .leading, spacing: DeadTheme.Spacing.xs) {
                Text(show.venue)
                    .font(DeadTheme.Typography.body())
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: DeadTheme.Spacing.sm) {
                    if !show.city.isEmpty {
                        Text(show.city)
                            .font(DeadTheme.Typography.caption())
                            .foregroundStyle(DeadTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    if let rating = show.avgRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(DeadTheme.Colors.accent)
                            Text(String(format: "%.1f", rating))
                                .font(DeadTheme.Typography.monoSmall())
                                .foregroundStyle(DeadTheme.Colors.textSecondary)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DeadTheme.Colors.textTertiary)
        }
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
        .padding(.horizontal, DeadTheme.Spacing.lg)
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
