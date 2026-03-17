import SwiftUI

struct ContentView: View {
    @Environment(AudioPlayerService.self) private var audioPlayer
    @Environment(PlayerViewModel.self) private var playerViewModel
    @State private var selectedTab = 0

    var body: some View {
        @Bindable var player = playerViewModel

        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                SongListView()
                    .tabItem {
                        Label("Songs", systemImage: "music.mic")
                    }
                    .tag(1)

                ShowBrowserView()
                    .tabItem {
                        Label("Browse", systemImage: "music.note.list")
                    }
                    .tag(2)

                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "heart.fill")
                    }
                    .tag(3)
            }
            .tint(DeadTheme.Colors.accent)

            // Now Playing Bar - above tab bar
            if audioPlayer.currentTrack != nil {
                NowPlayingBar()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 49) // Tab bar height
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $player.isFullScreenPresented) {
            NowPlayingFullView()
                .environment(audioPlayer)
                .environment(playerViewModel)
        }
        .animation(DeadTheme.Animation.springy, value: audioPlayer.currentTrack != nil)
        .onAppear {
            setupTabBarAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DeadTheme.Colors.background)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(DeadTheme.Colors.textTertiary)
        itemAppearance.selected.iconColor = UIColor(DeadTheme.Colors.accent)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(DeadTheme.Colors.textTertiary)]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(DeadTheme.Colors.accent)]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
