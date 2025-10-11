//
//  GameViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//  Modernized for iOS 26 with @Observable
//

import SwiftUI
import Observation

@MainActor
@Observable
final class GameViewModel {
    // MARK: - State Properties

    var isCardEjecting: Bool = false
    var isPaused: Bool = false
    var currentPlayerName: String = ""
    var currentPlayerIcon: String = ""
    var currentPlayerScore: Int = 0
    var roundTitle: String = ""
    var showPauseOverlay: Bool = false
    var showInstructionsSheet: Bool = false
    var isPlayerNameEjecting: Bool = false

    // MARK: - Computed Properties

    var isRound3: Bool {
        gameManager.currentRound == .round3
    }

    var timeRemaining: Int {
        timeManager.timeRemaining
    }

    var totalTime: Int {
        gameManager.logic.roundConst.timer
    }

    var currentCard: Card? {
        gameManager.cardManager.currentCard
    }

    var showNoCardsMessage: Bool {
        currentCard == nil
    }

    // MARK: - Dependencies

    let gameManager: GameManager
    private let timeManager: TimeManager

    // MARK: - Initialization

    init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.timeManager = gameManager.timeManager
        updateCurrentPlayer()
        updateRoundInfo()
    }

    // MARK: - Actions

    func validateCard() {
        performCardAction {
            self.gameManager.logic.validateCard()
        }
    }

    func passCard() {
        performCardAction {
            self.gameManager.logic.passCard()
        }
    }
    
    func resetGame() {
        gameManager.resetGame()
    }
    
    func togglePause() {
        isPaused.toggle()
        updatePauseState()
    }

    func resumeGame() {
        isPaused = false
        updatePauseState()
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
        // La musique est maintenant gérée automatiquement par le GameManager
        gameManager.logic.startTurn()
    }

    // MARK: - Private Methods

    private func performCardAction(action: @escaping () -> Void) {
        // Empêcher les clics pendant l'animation
        guard !isCardEjecting && !isPlayerNameEjecting else { return }

        let animationCompletion = {
            action()
            self.updateCurrentPlayer()
        }

        if isRound3 {
            // Round 3 : animer le nom du joueur
            animatePlayerNameEjection(completion: animationCompletion)
        } else {
            // Autres rounds : animer la carte
            animateCardEjection(completion: animationCompletion)
        }
    }

    private func updatePauseState() {
        showPauseOverlay = isPaused

        if isPaused {
            timeManager.pauseTimer()
        } else {
            timeManager.resumeTimer()
        }
    }

    private func updateCurrentPlayer() {
        guard let player = gameManager.safeCurrentPlayer() else {
            currentPlayerName = "Aucun"
            currentPlayerIcon = "person.fill"
            currentPlayerScore = 0
            return
        }
        currentPlayerName = player.name
        currentPlayerIcon = player.icon
        currentPlayerScore = player.currentTurnScore
    }
    
    private func updateRoundInfo() {
        roundTitle = "MANCHE \(gameManager.currentRound.rawValue)"
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
