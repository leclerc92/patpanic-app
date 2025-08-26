//
//  AudioManager.swift
//  patpanic
//
//  Created by Claude Code on 24/08/2025.
//

@preconcurrency import AVFoundation
import AudioToolbox

@MainActor
class AudioManager: ObservableObject {
    
    private let errorHandler = ErrorHandler.shared
    private var audioPlayerPools: [String: [AVAudioPlayer]] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    @Published var isMusicPlaying: Bool = false
    private var fadeTimer: Timer?
    private var criticalTickTimer: Timer?
    
    private let gameAudioSounds = ["validateCard", "passCard", "endTimer", "roundResult"]
    private let maxPlayersPerSound = 3
    
    deinit {
        fadeTimer?.invalidate()
        criticalTickTimer?.invalidate()
        backgroundMusicPlayer?.stop()
        audioPlayerPools.removeAll()
    }
    
    init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            errorHandler.logInfo("Session audio configurée avec succès", context: "AudioManager.setupAudioSession")
        } catch {
            errorHandler.handle(.audioManager(.audioSessionSetupFailed(reason: error.localizedDescription)), context: "AudioManager.setupAudioSession")
        }
    }
    
    private func preloadSounds() {
        var loadedSounds = 0
        var failedSounds: [String] = []
        
        for soundName in gameAudioSounds {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                failedSounds.append(soundName)
                errorHandler.handle(.audioManager(.soundFileNotFound(soundName: soundName)), context: "AudioManager.preloadSounds")
                continue
            }
            
            var players: [AVAudioPlayer] = []
            for _ in 0..<maxPlayersPerSound {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    players.append(player)
                } catch {
                    errorHandler.handle(.audioManager(.audioPlayerCreationFailed(soundName: soundName, reason: error.localizedDescription)), context: "AudioManager.preloadSounds")
                    break
                }
            }
            
            if !players.isEmpty {
                audioPlayerPools[soundName] = players
                loadedSounds += 1
            } else {
                failedSounds.append(soundName)
            }
        }
        
        errorHandler.logInfo("\(loadedSounds) sons préchargés avec succès", context: "AudioManager.preloadSounds")
        
        if !failedSounds.isEmpty {
            errorHandler.logWarning("Échec de préchargement des sons: \(failedSounds.joined(separator: ", "))", context: "AudioManager.preloadSounds")
        }
    }
    
    func playSound(_ soundName: String, volume: Float = 1.0) {
        guard let players = audioPlayerPools[soundName] else {
            errorHandler.logWarning("Tentative de lecture d'un son non chargé: \(soundName)", context: "AudioManager.playSound")
            return
        }
        
        // Cherche un player disponible
        for player in players {
            if !player.isPlaying {
                player.volume = max(0.0, min(1.0, volume))
                player.currentTime = 0
                player.play()
                return
            }
        }
        
        // Si aucun player disponible, utilise le premier (interrompt le son en cours)
        if let firstPlayer = players.first {
            firstPlayer.volume = max(0.0, min(1.0, volume))
            firstPlayer.currentTime = 0
            firstPlayer.play()
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
        if backgroundMusicPlayer != nil && isMusicPlaying {
            return
        }
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: "mp3") else {
            errorHandler.handle(.audioManager(.soundFileNotFound(soundName: musicName)), context: "AudioManager.playBackgroundMusic")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = 0.2
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            isMusicPlaying = true
            errorHandler.logInfo("Musique de fond démarrée: \(musicName)", context: "AudioManager.playBackgroundMusic")
        } catch {
            errorHandler.handle(.audioManager(.backgroundMusicFailed(reason: error.localizedDescription)), context: "AudioManager.playBackgroundMusic")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        isMusicPlaying = false
    }
    
    func fadeOutBackgroundMusic(duration: TimeInterval = 0.5) {
        guard let player = backgroundMusicPlayer, player.isPlaying else { return }
        
        let initialVolume = player.volume
        let fadeSteps = 20
        let stepDuration = duration / Double(fadeSteps)
        let volumeStep = initialVolume / Float(fadeSteps)
        
        var currentStep = 0
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            currentStep += 1
            
            let newVolume = initialVolume - (volumeStep * Float(currentStep))
            player.volume = max(newVolume, 0.0)
            
            if currentStep >= fadeSteps || newVolume <= 0 {
                timer.invalidate()
                
                Task { @MainActor [weak self] in
                    self?.fadeTimer = nil
                    self?.backgroundMusicPlayer?.stop()
                    self?.backgroundMusicPlayer = nil
                    self?.isMusicPlaying = false
                }
            }
        }
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        isMusicPlaying = false
    }
    
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
        isMusicPlaying = true
    }
    
    func setBackgroundMusicVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = volume
    }
    
    // MARK: - Timer Tick Sound
    func playTimerTick(intensity: Float = 1.0) {
        // Jouer un son de tic-tac système avec une intensité variable
        playSystemTick(volume: intensity)
    }
    
    func playDoubleTimerTick(intensity: Float = 1.0) {
        // Jouer deux tic-tacs système rapides pour la zone urgente (orange)
        playSystemTick(volume: intensity)
        
        // Deuxième tic après 0.3 secondes
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            self?.playSystemTick(volume: intensity)
        }
    }
    
    func startCriticalTickLoop(intensity: Float = 1.0) {
        // Arrêter toute boucle en cours
        stopCriticalTickLoop()
        
        // Démarrer une boucle de tic-tacs système rapides pour la zone critique (rouge)
        criticalTickTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.playSystemTick(volume: intensity)
            }
        }
    }
    
    func stopCriticalTickLoop() {
        criticalTickTimer?.invalidate()
        criticalTickTimer = nil
    }
    
    private func playTickSound(named soundName: String, volume: Float) {
        // Utiliser directement le son système car nous n'avons pas de fichier tick.mp3
        playSystemTick(volume: volume)
    }
    
    private func playSystemTick(volume: Float) {
        // Son système simple et efficace
        AudioServicesPlaySystemSound(1057) // Son de tick système
    }
    
    func getTimerTickType(timeRemaining: Int) -> TimerTickType {
        if timeRemaining <= 5 && timeRemaining > 0 {
            return .critical  // Rouge : boucle continue
        } else if timeRemaining <= 10 && timeRemaining > 0 {
            return .urgent    // Orange : double tap
        } else {
            return .normal    // Normal : tap simple
        }
    }
    
    func calculateTickIntensity(timeRemaining: Int, totalTime: Int) -> Float {
        if timeRemaining <= 5 && timeRemaining > 0 {
            return 1.0 // Volume maximum pour la zone critique
        } else if timeRemaining <= 10 && timeRemaining > 0 {
            return 0.7 // Volume fort pour la zone urgente
        } else {
            return 0.4 // Volume normal
        }
    }
    
    enum TimerTickType {
        case normal   // > 10 secondes
        case urgent   // 6-10 secondes (orange)
        case critical // 1-5 secondes (rouge)
    }
}
