import SwiftUI
import SwiftData

@main
struct DeadTapesApp: App {
    @State private var audioPlayer = AudioPlayerService()
    @State private var playerViewModel = PlayerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(audioPlayer)
                .environment(playerViewModel)
                .preferredColorScheme(.dark)
                .task {
                    // Load top all-time rankings in the background
                    await ShowRankingService.shared.loadTopAllTime()
                }
        }
        .modelContainer(for: [FavoriteShow.self])
    }
}
