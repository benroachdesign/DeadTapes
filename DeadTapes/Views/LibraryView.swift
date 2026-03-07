import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \FavoriteShow.dateAdded, order: .reverse) private var favorites: [FavoriteShow]
    @Environment(\.modelContext) private var modelContext
    @State private var itemsVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                DeadTheme.Colors.background.ignoresSafeArea()

                if favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            VStack(alignment: .leading, spacing: DeadTheme.Spacing.xs) {
                                Text("LIBRARY")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(DeadTheme.Colors.accent)
                                    .tracking(3)

                                Text("Favorites")
                                    .font(DeadTheme.Typography.largeTitle())
                                    .foregroundStyle(DeadTheme.Colors.textPrimary)

                                Text("\(favorites.count) saved show\(favorites.count == 1 ? "" : "s")")
                                    .font(DeadTheme.Typography.caption())
                                    .foregroundStyle(DeadTheme.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DeadTheme.Spacing.xl)
                            .padding(.top, DeadTheme.Spacing.md)
                            .padding(.bottom, DeadTheme.Spacing.lg)

                            LazyVStack(spacing: DeadTheme.Spacing.sm) {
                                ForEach(Array(favorites.enumerated()), id: \.element.identifier) { index, favorite in
                                    NavigationLink(destination: ShowDetailView(show: favorite.toShow())) {
                                        ShowCard(show: favorite.toShow())
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(itemsVisible ? 1 : 0)
                                    .offset(y: itemsVisible ? 0 : 10)
                                    .animation(
                                        DeadTheme.Animation.smooth.delay(Double(min(index, 15)) * 0.04),
                                        value: itemsVisible
                                    )
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                modelContext.delete(favorite)
                                                try? modelContext.save()
                                            }
                                        } label: {
                                            Label("Remove from Favorites", systemImage: "heart.slash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, DeadTheme.Spacing.lg)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(DeadTheme.Animation.smooth.delay(0.1)) {
                    itemsVisible = true
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DeadTheme.Spacing.lg) {
            Image(systemName: "heart.circle")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(DeadTheme.Colors.textTertiary)

            Text("No Favorites Yet")
                .font(DeadTheme.Typography.title2())
                .foregroundStyle(DeadTheme.Colors.textSecondary)

            Text("Tap the heart on any show to save it\nto your library for easy access.")
                .font(DeadTheme.Typography.body())
                .foregroundStyle(DeadTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DeadTheme.Spacing.xl)
    }
}
