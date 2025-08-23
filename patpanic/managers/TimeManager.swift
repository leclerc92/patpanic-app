import SwiftUI
import Combine

// Timer Manager principal pour gérer le décompte
@MainActor
class TimeManager: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    
    private var timer: Timer?
    private var totalTime: Int = 0
    private var onTimeUpCallback: (() -> Void)?
    private var onTickCallback: ((Int) -> Void)?
    
    // MARK: - Initialisation
    init() {}
    
    // MARK: - Cleanup
    deinit {
        // Nettoie le timer pour éviter les fuites mémoire
        timer?.invalidate()
        timer = nil
        onTimeUpCallback = nil
        onTickCallback = nil
    }
    
    // MARK: - Contrôles du timer
    
    /// Démarre un nouveau timer
    func startTimer(duration: Int, onTimeUp: @escaping () -> Void, onTick: ((Int) -> Void)? = nil) {
        stopTimer() // Arrête le timer précédent si il existe
        
        self.totalTime = duration
        self.timeRemaining = duration
        self.onTimeUpCallback = onTimeUp
        self.onTickCallback = onTick
        self.isRunning = true
        self.isPaused = false
        
        startInternalTimer()
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
        guard isRunning else { return }
        
        timer?.invalidate()
        timer = nil
        isPaused = true
    }
    
    /// Reprend le timer
    func resumeTimer() {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        startInternalTimer()
    }
    
    /// Arrête complètement le timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        timeRemaining = 0
    }
    
    /// Nettoie les ressources du timer (à appeler lors des changements de vue)
    func cleanup() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        timeRemaining = 0
        onTimeUpCallback = nil
        onTickCallback = nil
    }
    
    /// Ajoute du temps bonus
    func addBonusTime(_ seconds: Int) {
        timeRemaining += seconds
        totalTime += seconds // Met à jour le total pour le calcul du progress
    }
    
    /// Retire du temps (malus)
    func removePenaltyTime(_ seconds: Int) {
        timeRemaining = max(0, timeRemaining - seconds)
    }
    
    // MARK: - Propriétés calculées
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Méthodes privées
    
    private func startInternalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func tick() {
        if self.timeRemaining > 0 {
            self.timeRemaining -= 1
            self.onTickCallback?(self.timeRemaining)
        } else {
            // Temps écoulé
            self.stopTimer()
            self.onTimeUpCallback?()
        }
    }
}


