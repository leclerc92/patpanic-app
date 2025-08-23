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
    @Published var showPauseOverlay: Bool = false
    @Published var showInstructionsSheet: Bool = false
    @Published var isPlayerNameEjecting: Bool = false
    
    // MARK: - Computed Properties
    var isRound3: Bool {
        return gameManager.currentRound == .round3
    }
    
    // MARK: - Dependencies
    let gameManager: GameManager
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
        // Empêcher les clics pendant l'animation
        guard !isCardEjecting && !isPlayerNameEjecting else { return }
        
        if isRound3 {
            // Round 3 : animer le nom du joueur
            animatePlayerNameEjection {
                self.gameManager.logic.validateCard()
                self.updateCurrentPlayer()
            }
        } else {
            // Autres rounds : animer la carte
            animateCardEjection {
                self.gameManager.logic.validateCard()
                self.updateCurrentPlayer()
            }
        }
    }
    
    func passCard() {
        // Empêcher les clics pendant l'animation
        guard !isCardEjecting && !isPlayerNameEjecting else { return }
        
        if isRound3 {
            // Round 3 : animer le nom du joueur
            animatePlayerNameEjection {
                self.gameManager.logic.passCard()
                self.updateCurrentPlayer()
            }
        } else {
            // Autres rounds : animer la carte
            animateCardEjection {
                self.gameManager.logic.passCard()
                self.updateCurrentPlayer()
            }
        }
    }
    
    func resetGame() {
        gameManager.resetGame()
    }
    
    func togglePause() {
        isPaused.toggle()
        showPauseOverlay = isPaused
        print(isPaused ? "Jeu en pause" : "Jeu repris")
        
        // Gestion de la pause du timer
        if isPaused {
            timeManager.pauseTimer()
        } else {
            timeManager.resumeTimer()
        }
    }
    
    func resumeGame() {
        isPaused = false
        showPauseOverlay = false
        timeManager.resumeTimer()
        print("Jeu repris")
    }
    
    func showInstructions() {
        showInstructionsSheet = true
    }
    
    func exitGame() {

        gameManager.resetGame()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                self.isCardEjecting = false
                completion()
            }
        }
    }
    
    private func animatePlayerNameEjection(completion: @escaping () -> Void) {
        // Phase 1 : Grossissement et fondu
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isPlayerNameEjecting = true
        }
        
        // Phase 2 : Changement de joueur au milieu de l'animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion()
        }
        
        // Phase 3 : Retour à la normale avec rebond
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.isPlayerNameEjecting = false
            }
        }
    }
}
