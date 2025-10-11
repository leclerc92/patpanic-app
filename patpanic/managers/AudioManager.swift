//
//  AudioManager.swift
//  patpanic
//
//  Refactored for iOS 26+ with modern Swift Concurrency
//

import AVFoundation
import AudioToolbox
import Observation
import SwiftUI

/// Modern audio manager using Swift Concurrency and AVAudioEngine
/// Singleton to ensure only one audio engine runs at a time
@MainActor
@Observable
final class AudioManager {

    // MARK: - Singleton

    static let shared = AudioManager()

    // MARK: - Published State

    private(set) var isMusicPlaying: Bool = false

    // MARK: - Private Properties

    private let errorHandler = ErrorHandler.shared
    private let audioEngine = AVAudioEngine()

    // Sound players pool
    private var soundPlayers: [String: SoundPlayerPool] = [:]

    // Background music
    private var musicPlayerNode: AVAudioPlayerNode?
    private var musicAudioFile: AVAudioFile?

    // Timer tick player with volume control
    private var tickPlayerNode: AVAudioPlayerNode?
    private var tickBuffer: AVAudioPCMBuffer?

    // Concurrency tasks - nonisolated for deinit access
    nonisolated(unsafe) private var fadeTask: Task<Void, Never>?
    nonisolated(unsafe) private var criticalTickTask: Task<Void, Never>?

    // Audio session observers - nonisolated for deinit access
    nonisolated(unsafe) private var interruptionTask: Task<Void, Never>?
    nonisolated(unsafe) private var routeChangeTask: Task<Void, Never>?

    // Constants
    private let gameAudioSounds = ["validateCard", "passCard", "endTimer", "roundResult"]
    private let maxPlayersPerSound = 3

    // Tick synthesis constants
    private enum TickSynthesis {
        static let sampleRate: Double = 44100
        static let duration: Double = 0.05 // 50ms
        static let frequency: Float = 880.0 // Note A5
        static let amplitude: Float = 0.3
        static let fadeFrames = 100
    }

    // Fade constants
    private enum FadeConstants {
        static let steps = 30
        static let defaultDuration: TimeInterval = 0.5
    }

    // Timer tick constants
    private enum TickTiming {
        static let doubleTickDelay = 300 // milliseconds
        static let criticalLoopInterval = 250 // milliseconds
    }

    // MARK: - Initialization & Cleanup

    private init() {
        setupAudioSession()
        preloadSounds()  // Charge les sons et attache les nodes AVANT de start l'engine
        setupAudioEngine()  // Démarre l'engine APRÈS avoir attaché les nodes
        setupAudioSessionObservers()
    }

    deinit {
        // Cancel tasks - these can be called from any context
        fadeTask?.cancel()
        criticalTickTask?.cancel()
        interruptionTask?.cancel()
        routeChangeTask?.cancel()

        // Stop audio engine - this is thread-safe
        audioEngine.stop()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            // Use .playback for games (not .ambient) to allow full audio control
            // .mixWithOthers allows playing with other apps if desired
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            errorHandler.logInfo("Audio session configured (iOS 26)", context: "AudioManager.setupAudioSession")
        } catch {
            errorHandler.handle(
                .audioManager(.audioSessionSetupFailed(reason: error.localizedDescription)),
                context: "AudioManager.setupAudioSession"
            )
        }
    }

    private func setupAudioEngine() {
        // Prépare l'engine mais ne le démarre que s'il y a des nodes attachés
        if !audioEngine.attachedNodes.isEmpty {
            do {
                try audioEngine.start()
                errorHandler.logInfo("Audio engine started with \(audioEngine.attachedNodes.count) nodes", context: "AudioManager.setupAudioEngine")
            } catch {
                errorHandler.handle(
                    .audioManager(.backgroundMusicFailed(reason: error.localizedDescription)),
                    context: "AudioManager.setupAudioEngine"
                )
            }
        } else {
            // L'engine sera démarré lazy lors du premier son joué
            errorHandler.logInfo("Audio engine prepared (will start on first sound)", context: "AudioManager.setupAudioEngine")
        }
    }

    // MARK: - Audio Session Observers (Modern iOS 26)

    private func setupAudioSessionObservers() {
        let center = NotificationCenter.default

        // Handle interruptions (calls, Siri, etc.)
        interruptionTask = Task { [weak self] in
            for await notification in center.notifications(named: AVAudioSession.interruptionNotification) {
                await self?.handleInterruption(notification)
            }
        }

        // Handle route changes (headphones plugged/unplugged)
        routeChangeTask = Task { [weak self] in
            for await notification in center.notifications(named: AVAudioSession.routeChangeNotification) {
                await self?.handleRouteChange(notification)
            }
        }
    }

    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Pause all audio
            musicPlayerNode?.pause()
            isMusicPlaying = false
            criticalTickTask?.cancel()

        case .ended:
            // Resume if needed
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

            if options.contains(.shouldResume) {
                musicPlayerNode?.play()
                isMusicPlaying = true
            }

        @unknown default:
            break
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .oldDeviceUnavailable:
            // Headphones unplugged - pause music
            musicPlayerNode?.pause()
            isMusicPlaying = false

        default:
            break
        }
    }

    // MARK: - Sound Preloading

    private func preloadSounds() {
        var loadedSounds = 0
        var failedSounds: [String] = []

        for soundName in gameAudioSounds {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                failedSounds.append(soundName)
                errorHandler.handle(
                    .audioManager(.soundFileNotFound(soundName: soundName)),
                    context: "AudioManager.preloadSounds"
                )
                continue
            }

            do {
                let pool = try SoundPlayerPool(
                    url: url,
                    poolSize: maxPlayersPerSound,
                    audioEngine: audioEngine
                )
                soundPlayers[soundName] = pool
                loadedSounds += 1
            } catch {
                failedSounds.append(soundName)
                errorHandler.handle(
                    .audioManager(.audioPlayerCreationFailed(soundName: soundName, reason: error.localizedDescription)),
                    context: "AudioManager.preloadSounds"
                )
            }
        }

        errorHandler.logInfo("\(loadedSounds) sounds preloaded", context: "AudioManager.preloadSounds")

        if !failedSounds.isEmpty {
            errorHandler.logWarning(
                "Failed to preload: \(failedSounds.joined(separator: ", "))",
                context: "AudioManager.preloadSounds"
            )
        }

        // Preload tick sound for timer
        preloadTickSound()
    }

    private func preloadTickSound() {
        let frameCount = AVAudioFrameCount(TickSynthesis.sampleRate * TickSynthesis.duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: TickSynthesis.sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            errorHandler.logWarning("Failed to create tick buffer", context: "AudioManager.preloadTickSound")
            return
        }

        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else { return }

        for frame in 0..<Int(frameCount) {
            let sineWave = sin(2.0 * .pi * TickSynthesis.frequency * Float(frame) / Float(TickSynthesis.sampleRate))
            let envelope = calculateEnvelope(for: frame, total: Int(frameCount))
            channelData[frame] = sineWave * TickSynthesis.amplitude * envelope
        }

        tickBuffer = buffer

        // Crée le player node pour les ticks
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        tickPlayerNode = playerNode

        errorHandler.logInfo("Tick sound synthesized", context: "AudioManager.preloadTickSound")
    }

    private func calculateEnvelope(for frame: Int, total: Int) -> Float {
        let fadeFrames = TickSynthesis.fadeFrames

        if frame < fadeFrames {
            return Float(frame) / Float(fadeFrames)
        } else if frame > total - fadeFrames {
            return Float(total - frame) / Float(fadeFrames)
        } else {
            return 1.0
        }
    }

    // MARK: - Game Sound Effects

    func playSound(_ soundName: String, volume: Float = 1.0) {
        guard let pool = soundPlayers[soundName] else {
            errorHandler.logWarning(
                "Sound not preloaded: \(soundName)",
                context: "AudioManager.playSound"
            )
            return
        }

        // Démarre l'engine si pas encore fait
        ensureEngineStarted()

        pool.play(volume: volume)
    }

    private func ensureEngineStarted() {
        guard !audioEngine.isRunning else { return }

        do {
            try audioEngine.start()
            errorHandler.logInfo("Audio engine started on demand", context: "AudioManager.ensureEngineStarted")
        } catch {
            errorHandler.logWarning("Failed to start audio engine: \(error.localizedDescription)", context: "AudioManager.ensureEngineStarted")
        }
    }

    func playValidateCardSound() {
        playSound("validateCard", volume: 0.8)
    }

    func playPassCardSound() {
        playSound("passCard", volume: 0.8)
    }

    func playEndTimer() {
        playSound("endTimer", volume: 1.0)
    }

    func playRoundResultSound() {
        playSound("roundResult", volume: 1.0)
    }

    // MARK: - Background Music

    func playBackgroundMusic(_ musicName: String = "gameMusic") {
        if isMusicPlaying {
            return
        }

        guard let url = Bundle.main.url(forResource: musicName, withExtension: "mp3") else {
            errorHandler.handle(
                .audioManager(.soundFileNotFound(soundName: musicName)),
                context: "AudioManager.playBackgroundMusic"
            )
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)

            // Réutilise le node existant ou en crée un nouveau
            let playerNode: AVAudioPlayerNode
            if let existingNode = musicPlayerNode {
                playerNode = existingNode
                playerNode.stop()
            } else {
                playerNode = AVAudioPlayerNode()
                audioEngine.attach(playerNode)
                audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: file.processingFormat)
            }

            // Démarre l'engine si pas encore fait
            ensureEngineStarted()

            // Schedule le fichier en boucle
            scheduleBackgroundMusicLoop(playerNode: playerNode, file: file)

            playerNode.volume = 0.2
            playerNode.play()

            musicPlayerNode = playerNode
            musicAudioFile = file
            isMusicPlaying = true

            errorHandler.logInfo("Background music started: \(musicName)", context: "AudioManager.playBackgroundMusic")

        } catch {
            errorHandler.handle(
                .audioManager(.backgroundMusicFailed(reason: error.localizedDescription)),
                context: "AudioManager.playBackgroundMusic"
            )
        }
    }

    private func scheduleBackgroundMusicLoop(playerNode: AVAudioPlayerNode, file: AVAudioFile) {
        playerNode.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { [weak self, weak playerNode] _ in
            guard let self = self, let playerNode = playerNode else { return }

            Task { @MainActor in
                if self.isMusicPlaying && playerNode.isPlaying {
                    self.scheduleBackgroundMusicLoop(playerNode: playerNode, file: file)
                }
            }
        }
    }

    func stopBackgroundMusic() {
        musicPlayerNode?.stop()

        if let node = musicPlayerNode {
            audioEngine.detach(node)
        }

        musicPlayerNode = nil
        musicAudioFile = nil
        isMusicPlaying = false
    }

    func fadeOutBackgroundMusic(duration: TimeInterval = FadeConstants.defaultDuration) async {
        guard let playerNode = musicPlayerNode, isMusicPlaying else {
            return
        }

        // Mettre isMusicPlaying à false IMMÉDIATEMENT pour empêcher le rescheduling
        isMusicPlaying = false

        fadeTask?.cancel()

        fadeTask = Task {
            let initialVolume = playerNode.volume
            let stepDuration = duration / Double(FadeConstants.steps)

            for step in 1...FadeConstants.steps {
                guard !Task.isCancelled else { break }

                let progress = Float(step) / Float(FadeConstants.steps)
                playerNode.volume = clampVolume(initialVolume * (1.0 - progress))

                try? await Task.sleep(for: .seconds(stepDuration))
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.stopBackgroundMusic()
            }
        }

        await fadeTask?.value
    }

    func pauseBackgroundMusic() {
        musicPlayerNode?.pause()
        isMusicPlaying = false
    }

    func resumeBackgroundMusic() {
        musicPlayerNode?.play()
        isMusicPlaying = true
    }

    func setBackgroundMusicVolume(_ volume: Float) {
        musicPlayerNode?.volume = clampVolume(volume)
    }

    // MARK: - Helper Methods

    private func clampVolume(_ volume: Float) -> Float {
        max(0.0, min(1.0, volume))
    }

    // MARK: - Timer Tick Sounds

    func playTimerTick(intensity: Float = 1.0) {
        playSystemTick(volume: intensity)
    }

    func playDoubleTimerTick(intensity: Float = 1.0) {
        playSystemTick(volume: intensity)

        Task {
            try? await Task.sleep(for: .milliseconds(TickTiming.doubleTickDelay))
            await playSystemTick(volume: intensity)
        }
    }

    func startCriticalTickLoop(intensity: Float = 1.0) async {
        stopCriticalTickLoop()

        criticalTickTask = Task {
            while !Task.isCancelled {
                await playSystemTick(volume: intensity)
                try? await Task.sleep(for: .milliseconds(TickTiming.criticalLoopInterval))
            }
        }
    }

    func stopCriticalTickLoop() {
        criticalTickTask?.cancel()
        criticalTickTask = nil
    }

    private func playSystemTick(volume: Float) {
        playHapticFeedback(intensity: volume)
        playSynthesizedTick(volume: volume)
    }

    private func playHapticFeedback(intensity: Float) {
        let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = intensity > 0.8 ? .medium : .light
        let impact = UIImpactFeedbackGenerator(style: hapticStyle)
        impact.impactOccurred(intensity: CGFloat(intensity))
    }

    private func playSynthesizedTick(volume: Float) {
        guard let tickPlayer = tickPlayerNode, let buffer = tickBuffer else {
            AudioServicesPlaySystemSound(1103) // Fallback
            return
        }

        ensureEngineStarted()

        if tickPlayer.isPlaying {
            tickPlayer.stop()
        }

        tickPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        tickPlayer.volume = clampVolume(volume)

        if !tickPlayer.isPlaying {
            tickPlayer.play()
        }
    }

    // MARK: - Timer Tick Utilities

    func getTimerTickType(timeRemaining: Int) -> TimerTickType {
        switch timeRemaining {
        case ...0:
            return .normal
        case 1...5:
            return .critical
        case 6...10:
            return .urgent
        default:
            return .normal
        }
    }

    func calculateTickIntensity(timeRemaining: Int, totalTime: Int) -> Float {
        switch timeRemaining {
        case ...0:
            return 0.0
        case 1...5:
            return 1.0
        case 6...10:
            return 0.7
        default:
            return 0.4
        }
    }

    enum TimerTickType {
        case normal   // > 10 seconds
        case urgent   // 6-10 seconds
        case critical // 1-5 seconds
    }
}

// MARK: - Sound Player Pool

/// Modern sound player pool using AVAudioPlayerNode
private final class SoundPlayerPool {
    private let players: [AVAudioPlayerNode]
    private let audioFile: AVAudioFile
    private let audioEngine: AVAudioEngine
    private var currentPlayerIndex = 0

    init(url: URL, poolSize: Int, audioEngine: AVAudioEngine) throws {
        self.audioFile = try AVAudioFile(forReading: url)
        self.audioEngine = audioEngine

        var players: [AVAudioPlayerNode] = []

        for _ in 0..<poolSize {
            let player = AVAudioPlayerNode()
            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
            players.append(player)
        }

        self.players = players
    }

    func play(volume: Float) {
        let player = players[currentPlayerIndex]
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count

        // Stop if currently playing
        if player.isPlaying {
            player.stop()
        }

        player.scheduleFile(audioFile, at: nil)
        player.volume = max(0.0, min(1.0, volume))
        player.play()
    }
}
