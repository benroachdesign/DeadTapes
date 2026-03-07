import SwiftUI

struct ShowBrowserView: View {
    @State private var viewModel = ShowBrowserViewModel()
    @State private var showsVisible = false

    var body: some View {
        NavigationStack {
            ZStack {
                DeadTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: DeadTheme.Spacing.md) {
                        Text("BROWSE")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(DeadTheme.Colors.accent)
                            .tracking(3)
                            .padding(.horizontal, DeadTheme.Spacing.xl)

                        Text("Shows")
                            .font(DeadTheme.Typography.largeTitle())
                            .foregroundStyle(DeadTheme.Colors.textPrimary)
                            .padding(.horizontal, DeadTheme.Spacing.xl)

                        // Year Picker
                        YearPickerView(
                            selectedYear: $viewModel.selectedYear
                        ) { year in
                            showsVisible = false
                            viewModel.selectYear(year)
                        }
                        .padding(.top, DeadTheme.Spacing.xs)

                        // Search bar
                        HStack(spacing: DeadTheme.Spacing.sm) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                                .font(.system(size: 14))

                            TextField("Search venues, cities...", text: $viewModel.searchText)
                                .font(DeadTheme.Typography.body())
                                .foregroundStyle(DeadTheme.Colors.textPrimary)
                                .tint(DeadTheme.Colors.accent)

                            if !viewModel.searchText.isEmpty {
                                Button {
                                    viewModel.searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(DeadTheme.Colors.textTertiary)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(DeadTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DeadTheme.Radius.md)
                                .fill(DeadTheme.Colors.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DeadTheme.Radius.md)
                                        .strokeBorder(DeadTheme.Colors.textTertiary.opacity(0.15), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, DeadTheme.Spacing.lg)

                        // Result count
                        if !viewModel.isLoading {
                            Text("\(viewModel.showCount) shows")
                                .font(DeadTheme.Typography.monoSmall())
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                                .padding(.horizontal, DeadTheme.Spacing.xl)
                        }
                    }
                    .padding(.top, DeadTheme.Spacing.md)

                    Divider()
                        .background(DeadTheme.Colors.textTertiary.opacity(0.2))
                        .padding(.top, DeadTheme.Spacing.sm)

                    // Show list
                    if viewModel.isLoading {
                        ScrollView {
                            VStack(spacing: DeadTheme.Spacing.sm) {
                                ForEach(0..<8, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: DeadTheme.Radius.md)
                                        .fill(DeadTheme.Colors.cardBackground)
                                        .frame(height: 100)
                                        .shimmer()
                                }
                            }
                            .padding(DeadTheme.Spacing.lg)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DeadTheme.Spacing.sm) {
                                ForEach(Array(viewModel.filteredShows.enumerated()), id: \.element.id) { index, show in
                                    NavigationLink(destination: ShowDetailView(show: show)) {
                                        ShowCard(show: show, badges: viewModel.badges(for: show))
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(showsVisible ? 1 : 0)
                                    .offset(y: showsVisible ? 0 : 10)
                                    .animation(
                                        DeadTheme.Animation.smooth.delay(Double(min(index, 15)) * 0.03),
                                        value: showsVisible
                                    )
                                }
                            }
                            .padding(.horizontal, DeadTheme.Spacing.lg)
                            .padding(.top, DeadTheme.Spacing.sm)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                if viewModel.shows.isEmpty {
                    await viewModel.loadShows()
                }
            }
            .onChange(of: viewModel.filteredShows) { _, _ in
                showsVisible = false
                withAnimation {
                    showsVisible = true
                }
            }
        }
    }
}
