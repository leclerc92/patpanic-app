//
//  GameViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isCardEjecting: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentPlayerName: String = ""
    @Published var currentPlayerIcon: String = ""
    @Published var currentPlayerScore: Int = 0
    @Published var roundTitle: String = ""
    @Published var timeRemaining: Int = 0
    @Published var totalTime: Int = 0
    @Published var currentCard: Card?
    @Published var showNoCardsMessage: Bool = false
    
    // MARK: - Dependencies
    private let gameManager: GameManager
    private let timeManager: TimeManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.timeManager = gameManager.timeManager
        setupBindings()
        updateCurrentPlayer()
        updateRoundInfo()
        updateTimer()
        updateCurrentCard()
    }
    
    // MARK: - Cleanup
    deinit {
        // Nettoie le timer pour éviter les fuites mémoire
        let timer = timeManager
        Task { @MainActor in
            timer.cleanup()
        }
        cancellables.removeAll()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Observer les changements du player courant
        gameManager.$currentPlayerIndex
            .sink { [weak self] _ in
                self?.updateCurrentPlayer()
            }
            .store(in: &cancellables)
        
        // Observer le round courant
        gameManager.$currentRound
            .sink { [weak self] _ in
                self?.updateRoundInfo()
            }
            .store(in: &cancellables)
        
        // Observer le timer
        timeManager.$timeRemaining
            .assign(to: \.timeRemaining, on: self)
            .store(in: &cancellables)
        
        // Observer la carte courante
        gameManager.cardManager.$currentCard
            .sink { [weak self] card in
                self?.currentCard = card
                self?.showNoCardsMessage = card == nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func validateCard() {
        guard !isCardEjecting else { return }
        
        // 1. Animation d'abord (bloque les clics)
        animateCardEjection {
            // 2. Logique métier pendant l'animation
            self.gameManager.logic.validateCard()
            self.updateCurrentPlayer()
        }
    }
    
    func passCard() {
        guard !isCardEjecting else { return }
        
        // 1. Animation d'abord (bloque les clics)
        animateCardEjection {
            // 2. Logique métier pendant l'animation
            self.gameManager.logic.passCard()
        }
    }
    
    func resetGame() {
        gameManager.resetGame()
    }
    
    func togglePause() {
        isPaused.toggle()
        print(isPaused ? "Jeu en pause" : "Jeu repris")
        
        // Gestion de la pause du timer
        if isPaused {
            timeManager.pauseTimer()
        } else {
            timeManager.resumeTimer()
        }
    }
    
    func viewWillDisappear() {
        // Appelé quand la vue va disparaître - nettoie le timer
        timeManager.stopTimer()
    }
    
    func viewDidAppear() {
        self.gameManager.logic.startTurn()
        updateTimer()
    }
    
    
    // MARK: - Private Methods
    private func updateCurrentPlayer() {
        let player = gameManager.currentPlayer()
        currentPlayerName = player.name
        currentPlayerIcon = player.icon
        currentPlayerScore = player.currentTurnScore
    }
    
    private func updateRoundInfo() {
        roundTitle = "MANCHE \(gameManager.currentRound.rawValue)"
        
        // Mettre à jour le timer total si nécessaire
        let roundConfig = gameManager.logic.roundConst
        totalTime = roundConfig.timer
    }
    
    private func updateTimer() {
        let roundConfig = gameManager.logic.roundConst
        totalTime = roundConfig.timer
    }
    
    private func updateCurrentCard() {
        currentCard = gameManager.getCurrentCard()
        showNoCardsMessage = currentCard == nil
    }
    
    private func animateCardEjection(completion: @escaping () -> Void) {
        withAnimation {
            isCardEjecting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                self.isCardEjecting = false
                completion()
            }
        }
    }
}
