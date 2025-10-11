import SwiftUI
import Observation

/// Modern timer manager using Swift Concurrency and @Observable (iOS 26)
@MainActor
@Observable
final class TimeManager {

    // MARK: - Observable State

    private(set) var timeRemaining: Int = 0
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false

    // MARK: - Private Properties

    private var totalTime: Int = 0
    private var pausedTimeRemaining: Int = 0

    // Timer task - nonisolated for deinit access
    nonisolated(unsafe) private var timerTask: Task<Void, Never>?

    // Callbacks stored as properties to maintain compatibility
    private var onTimeUpCallback: (() -> Void)?
    private var onTickCallback: ((Int) -> Void)?

    // MARK: - Initialization & Cleanup

    init() {}

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Timer Controls

    /// Démarre un nouveau timer avec async/await
    func startTimer(duration: Int, onTimeUp: @escaping () -> Void, onTick: ((Int) -> Void)? = nil) {
        stopTimer()

        self.totalTime = duration
        self.timeRemaining = duration
        self.onTimeUpCallback = onTimeUp
        self.onTickCallback = onTick
        self.isRunning = true
        self.isPaused = false

        startAsyncTimer(from: duration)
    }

    /// Met en pause ou reprend le timer
    func togglePause() {
        if isPaused {
            resumeTimer()
        } else {
            pauseTimer()
        }
    }

    /// Met en pause le timer
    func pauseTimer() {
        guard isRunning, !isPaused else { return }

        isPaused = true
        pausedTimeRemaining = timeRemaining
        cancelTimerTask()
    }

    /// Reprend le timer depuis l'état pausé
    func resumeTimer() {
        guard isRunning, isPaused else { return }

        isPaused = false
        startAsyncTimer(from: pausedTimeRemaining)
    }

    /// Arrête complètement le timer
    func stopTimer() {
        cancelTimerTask()
        isRunning = false
        isPaused = false
        timeRemaining = 0
        pausedTimeRemaining = 0
    }

    /// Nettoie les ressources
    func cleanup() {
        stopTimer()
        onTimeUpCallback = nil
        onTickCallback = nil
    }

    /// Ajoute du temps bonus
    func addBonusTime(_ seconds: Int) {
        timeRemaining += seconds
        totalTime += seconds
    }

    /// Retire du temps (malus)
    func removePenaltyTime(_ seconds: Int) {
        timeRemaining = max(0, timeRemaining - seconds)
    }

    // MARK: - Computed Properties

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Methods

    private func cancelTimerTask() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func startAsyncTimer(from startTime: Int) {
        cancelTimerTask()

        timerTask = Task { [weak self] in
            guard let self = self else { return }

            for remaining in stride(from: startTime, through: 0, by: -1) {
                guard !Task.isCancelled else { break }

                await MainActor.run {
                    self.timeRemaining = remaining
                }

                // Call tick callback (except for initial value)
                if remaining < startTime {
                    await MainActor.run {
                        self.onTickCallback?(remaining)
                    }
                }

                // Don't sleep after reaching 0
                if remaining > 0 {
                    try? await Task.sleep(for: .seconds(1))
                }
            }

            // Timer finished
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.isRunning = false
                self.isPaused = false
                self.onTimeUpCallback?()
            }
        }
    }
}


