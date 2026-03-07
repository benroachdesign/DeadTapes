import Foundation
import Observation

@Observable
final class PlayerViewModel {
    var isFullScreenPresented = false
    var showQueue = false

    // Computed from AudioPlayerService — bridging for views
    var hasActiveTrack: Bool {
        _audioPlayer?.currentTrack != nil
    }

    private weak var _audioPlayer: AudioPlayerService?

    func bind(to audioPlayer: AudioPlayerService) {
        _audioPlayer = audioPlayer
    }

    func presentFullScreen() {
        withObservationTracking {
            _ = isFullScreenPresented
        } onChange: { }
        isFullScreenPresented = true
    }

    func dismissFullScreen() {
        isFullScreenPresented = false
    }
}
