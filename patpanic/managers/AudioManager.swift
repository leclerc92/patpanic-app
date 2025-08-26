//
//  AudioManager.swift
//  patpanic
//
//  Created by Claude Code on 24/08/2025.
//

import AVFoundation
import AudioToolbox

class AudioManager: ObservableObject {
    private var audioPlayerPools: [String: [AVAudioPlayer]] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    @Published var isMusicPlaying: Bool = false
    private var fadeTimer: Timer?
    private var criticalTickTimer: Timer?
    
    private let gameAudioSounds = ["validateCard", "passCard", "endTimer", "tick", "roundResult"]
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
        } catch {
        }
    }
    
    private func preloadSounds() {
        for soundName in gameAudioSounds {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                continue
            }
            
            var players: [AVAudioPlayer] = []
            for _ in 0..<maxPlayersPerSound {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    players.append(player)
                } catch {
                    break
                }
            }
            audioPlayerPools[soundName] = players
        }
    }
    
    func playSound(_ soundName: String, volume: Float = 1.0) {
        guard let players = audioPlayerPools[soundName] else {
            return
        }
        
        for player in players {
            if !player.isPlaying {
                player.volume = volume
                player.currentTime = 0
                player.play()
                return
            }
        }
        
        if let firstPlayer = players.first {
            firstPlayer.volume = volume
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
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = 0.2
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            isMusicPlaying = true
        } catch {
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
                self?.fadeTimer = nil
                
                player.stop()
                self?.backgroundMusicPlayer = nil
                self?.isMusicPlaying = false
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
        // Jouer un son de tic-tac avec une intensité variable
        playTickSound(named: "tick", volume: intensity)
    }
    
    func playDoubleTimerTick(intensity: Float = 1.0) {
        // Jouer deux tic-tacs rapides pour la zone urgente (orange)
        playTickSound(named: "tick", volume: intensity)
        
        // Deuxième tic après 0.3 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.playTickSound(named: "tick", volume: intensity)
        }
    }
    
    func startCriticalTickLoop(intensity: Float = 1.0) {
        // Arrêter toute boucle en cours
        stopCriticalTickLoop()
        
        // Démarrer une boucle de tic-tacs rapides pour la zone critique (rouge)
        criticalTickTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.playTickSound(named: "tick", volume: intensity)
        }
    }
    
    func stopCriticalTickLoop() {
        criticalTickTimer?.invalidate()
        criticalTickTimer = nil
    }
    
    private func playTickSound(named soundName: String, volume: Float) {
        guard let players = audioPlayerPools[soundName] else {
            playSystemTick(volume: volume)
            return
        }
        
        for player in players {
            if !player.isPlaying {
                player.volume = volume
                player.currentTime = 0
                player.play()
                return
            }
        }
        
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
