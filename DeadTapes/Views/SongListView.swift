import SwiftUI

struct SongListView: View {
    @State private var viewModel = SongBrowserViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                DeadTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: DeadTheme.Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(DeadTheme.Colors.textTertiary)
                        
                        TextField("Search songs...", text: $viewModel.searchText)
                            .font(DeadTheme.Typography.body())
                            .foregroundStyle(DeadTheme.Colors.textPrimary)
                            .tint(DeadTheme.Colors.accent)
                    }
                    .padding(DeadTheme.Spacing.md)
                    .background(DeadTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, DeadTheme.Spacing.lg)
                    .padding(.top, DeadTheme.Spacing.sm)
                    
                    // Sort Controls
                    HStack {
                        Text("\(viewModel.displayedSongs.count) songs")
                            .font(DeadTheme.Typography.monoSmall())
                            .foregroundStyle(DeadTheme.Colors.textTertiary)
                        
                        Spacer()
                        
                        Picker("Sort", selection: $viewModel.selectedSort) {
                            ForEach(SongBrowserViewModel.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .tint(DeadTheme.Colors.accent)
                    }
                    .padding(.horizontal, DeadTheme.Spacing.lg)
                    .padding(.vertical, DeadTheme.Spacing.sm)
                    
                    // List
                    if viewModel.displayedSongs.isEmpty && !viewModel.searchText.isEmpty {
                        // Empty search state
                        Spacer()
                        VStack(spacing: DeadTheme.Spacing.md) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 36))
                                .foregroundStyle(DeadTheme.Colors.textTertiary)

                            Text("No songs found for \"\(viewModel.searchText)\"")
                                .font(DeadTheme.Typography.headline())
                                .foregroundStyle(DeadTheme.Colors.textSecondary)

                            Text("Our catalog covers the most popular songs in the Dead's repertoire. Rare deep cuts and one-off covers may not be listed yet.")
                                .font(DeadTheme.Typography.caption())
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DeadTheme.Spacing.xl)
                        }
                        .padding(.top, DeadTheme.Spacing.hero)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.displayedSongs) { song in
                                    NavigationLink(value: song) {
                                        SongRow(song: song)
                                    }
                                    .buttonStyle(.plain)
                                }

                                // Footer note
                                HStack(spacing: DeadTheme.Spacing.xs) {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 11))
                                    Text("This catalog features the Dead's most-played songs. Not every tune from every setlist is here.")
                                        .font(DeadTheme.Typography.caption())
                                }
                                .foregroundStyle(DeadTheme.Colors.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DeadTheme.Spacing.xl)
                                .padding(.top, DeadTheme.Spacing.xl)
                            }
                            .padding(.top, DeadTheme.Spacing.sm)
                            .padding(.bottom, 100) // Space for mini player
                        }
                    }
                }
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Song.self) { song in
                SongDetailView(viewModel: SongDetailViewModel(song: song))
            }
        }
        .tint(DeadTheme.Colors.accent)
        .task { await viewModel.load() }
    }
}

struct SongRow: View {
    let song: Song
    
    var body: some View {
        HStack(alignment: .center, spacing: DeadTheme.Spacing.md) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(DeadTheme.Typography.headline())
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if song.originalArtist != "Grateful Dead" && !song.originalArtist.isEmpty {
                        Text(song.originalArtist)
                    } else {
                        Text("Grateful Dead")
                    }
                    
                    Text("•")
                        .foregroundStyle(DeadTheme.Colors.textTertiary)
                    
                    Text("Debut: \(String(song.debutYear))")
                }
                .font(DeadTheme.Typography.caption())
                .foregroundStyle(DeadTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(song.playCount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(DeadTheme.Colors.accent)
                
                Text("plays")
                    .font(DeadTheme.Typography.monoSmall())
                    .foregroundStyle(DeadTheme.Colors.textTertiary)
            }
        }
        .padding(.vertical, DeadTheme.Spacing.md)
        .padding(.horizontal, DeadTheme.Spacing.lg)
        .background(DeadTheme.Colors.cardBackground.opacity(0.3))
        .containerShape(Rectangle())
        
        Divider()
            .background(DeadTheme.Colors.textTertiary.opacity(0.2))
            .padding(.leading, DeadTheme.Spacing.lg)
    }
}
