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
        
        animateCardEjection {
            self.gameManager.logic.validateCard()
        }
    }
    
    func passCard() {
        guard !isCardEjecting else { return }
        
        animateCardEjection {
            self.gameManager.logic.passCard()
        }
    }
    
    func resetGame() {
        gameManager.resetGame()
    }
    
    func togglePause() {
        isPaused.toggle()
        print(isPaused ? "Jeu en pause" : "Jeu repris")
        // Ici vous pouvez ajouter la logique de pause du timer si nécessaire
        // timeManager.pause() / timeManager.resume()
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
        
        completion()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                self.isCardEjecting = false
            }
        }
    }
}