import Foundation
import Observation

/// Manages player UI presentation state (full-screen/queue visibility).
/// Intentionally thin — playback logic lives in `AudioPlayerService`.
@Observable
final class PlayerViewModel {
    var isFullScreenPresented = false
    var showQueue = false

    func presentFullScreen() {
        isFullScreenPresented = true
    }

    func dismissFullScreen() {
        isFullScreenPresented = false
    }
}
