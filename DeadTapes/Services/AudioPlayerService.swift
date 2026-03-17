import Foundation
import AVFoundation
import MediaPlayer
import Observation

@MainActor
@Observable
final class AudioPlayerService {
    // MARK: - State

    var currentTrack: Track?
    var currentShow: Show?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var progress: Double = 0 // 0...1
    var queue: [Track] = []
    var currentIndex: Int = 0
    var isLoading: Bool = false

    // MARK: - Private

    private var player: AVQueuePlayer?
    private var timeObserver: Any?
    private var itemObservers: [NSKeyValueObservation] = []
    private var endObserver: NSObjectProtocol?

    init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    // MARK: - Playback Control

    func play(track: Track, in tracks: [Track], show: Show) {
        guard let index = tracks.firstIndex(of: track) else { return }

        cleanup()

        self.queue = tracks
        self.currentIndex = index
        self.currentShow = show
        self.isLoading = true

        // Create player items for current and upcoming tracks (gapless)
        let items = tracks[index...].prefix(10).compactMap { $0.streamURL.map { AVPlayerItem(url: $0) } }

        player = AVQueuePlayer(items: Array(items))
        player?.actionAtItemEnd = .advance

        setupTimeObserver()
        setupItemEndObserver()
        observeCurrentItem()

        player?.play()
        isPlaying = true
        updateCurrentTrack(tracks[index])
    }

    func togglePlayPause() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updateNowPlayingPlaybackState()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingPlaybackState()
    }

    func resume() {
        player?.play()
        isPlaying = true
        updateNowPlayingPlaybackState()
    }

    func next() {
        guard currentIndex + 1 < queue.count else { return }

        player?.advanceToNextItem()
        currentIndex += 1
        updateCurrentTrack(queue[currentIndex])

        // Ensure enough items are queued ahead
        enqueueUpcoming()
    }

    func previous() {
        // If more than 3 seconds in, restart current track
        if currentTime > 3 {
            seek(to: 0)
            return
        }

        guard currentIndex > 0, let show = currentShow else { return }

        // Need to rebuild queue from previous track
        currentIndex -= 1
        let track = queue[currentIndex]
        play(track: track, in: queue, show: show)
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }

    func seekToProgress(_ progress: Double) {
        let time = duration * progress
        seek(to: time)
    }

    // MARK: - Queue Management

    private func enqueueUpcoming() {
        guard let player = player else { return }

        let itemsInQueue = player.items().count
        let desiredAhead = 5
        let nextIndex = currentIndex + itemsInQueue

        if nextIndex < queue.count && itemsInQueue < desiredAhead {
            let endIndex = min(nextIndex + (desiredAhead - itemsInQueue), queue.count)
            for i in nextIndex..<endIndex {
                guard let url = queue[i].streamURL else { continue }
                let item = AVPlayerItem(url: url)
                if player.canInsert(item, after: nil) {
                    player.insert(item, after: nil)
                }
            }
        }
    }

    // MARK: - Observers

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let seconds = CMTimeGetSeconds(time)
            guard seconds.isFinite else { return }

            self.currentTime = seconds
            if self.duration > 0 {
                self.progress = seconds / self.duration
            }

            self.updateNowPlayingTime()
        }
    }

    private func observeCurrentItem() {
        itemObservers.removeAll()

        guard let item = player?.currentItem else { return }

        let observation = item.observe(\.status) { [weak self] item, _ in
            guard let self = self else { return }
            if item.status == .readyToPlay {
                let dur = CMTimeGetSeconds(item.duration)
                if dur.isFinite {
                    Task { @MainActor [weak self] in
                        self?.duration = dur
                        self?.isLoading = false
                        self?.updateNowPlayingInfo()
                    }
                }
            }
        }
        itemObservers.append(observation)
    }

    private func setupItemEndObserver() {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let endedItem = notification.object as? AVPlayerItem else { return }

            // Only advance index when the current item finishes
            guard endedItem == self.player?.currentItem else { return }

            self.currentIndex += 1
            if self.currentIndex < self.queue.count {
                self.updateCurrentTrack(self.queue[self.currentIndex])
                self.enqueueUpcoming()
            } else {
                // End of queue
                self.isPlaying = false
                self.currentTime = 0
                self.progress = 0
            }
        }
    }

    private func updateCurrentTrack(_ track: Track) {
        currentTrack = track
        currentTime = 0
        progress = 0
        duration = track.duration
        observeCurrentItem()
        updateNowPlayingInfo()
    }

    // MARK: - Now Playing Info Center

    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentTrack?.title ?? "Unknown"
        info[MPMediaItemPropertyArtist] = "Grateful Dead"
        info[MPMediaItemPropertyAlbumTitle] = currentShow?.venue ?? ""
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let index = currentTrack.flatMap({ t in queue.firstIndex(of: t) }) {
            info[MPNowPlayingInfoPropertyPlaybackQueueIndex] = index
            info[MPNowPlayingInfoPropertyPlaybackQueueCount] = queue.count
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingTime() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    }

    private func updateNowPlayingPlaybackState() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    }

    // MARK: - Remote Commands

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.next()
            return .success
        }

        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.previous()
            return .success
        }

        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let posEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: posEvent.positionTime)
            return .success
        }
    }

    // MARK: - Cleanup

    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
        itemObservers.removeAll()
        player?.pause()
        player?.removeAllItems()
        player = nil
    }
}
