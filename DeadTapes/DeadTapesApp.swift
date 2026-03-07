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
        }
        .modelContainer(for: [FavoriteShow.self])
    }
}
