//
//  LeaderboardViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import SwiftUI
import Combine

@MainActor
class LeaderboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sortedPlayers: [Player] = []
    @Published var winner: Player?
    @Published var titleIcon: String = ""
    @Published var titleText: String = ""
    @Published var titleSubtitle: String = ""
    @Published var showWinnerPodium: Bool = false
    @Published var buttonTitle: String = ""
    @Published var buttonSubtitle: String = ""
    @Published var buttonIcon: String = ""
    @Published var buttonColors: [Color] = []
    
    // MARK: - Dependencies
    private let gameManager: GameManager
    private let isRoundEnd: Bool

    
    // MARK: - Initialization
    init(gameManager: GameManager, isRoundEnd: Bool) {
        self.gameManager = gameManager
        self.isRoundEnd = isRoundEnd
        setupData()
    }
    
    // MARK: - Setup
    private func setupData() {
        updateSortedPlayers()
        updateTitleSection()
        updateButtonSection()
    }
    
    // MARK: - Actions
    func cancelButton() {
    }
    
    func continueButton() {
        
        if isRoundEnd {
            gameManager.goToNextRound()
        } else {
            gameManager.resetGame()
        }
        
    }
    
    // MARK: - Private Methods
    private func updateSortedPlayers() {
        sortedPlayers = gameManager.players.sorted { $0.score > $1.score }
        winner = sortedPlayers.first
    }
    
    private func updateTitleSection() {
        if isRoundEnd {
            titleIcon = "🏁"
            titleText = "FIN DU ROUND \(gameManager.currentRound.rawValue)"
            titleSubtitle = "Classement temporaire"
            showWinnerPodium = false
        } else {
            titleIcon = "🏆"
            titleText = "PARTIE TERMINÉE"
            titleSubtitle = "Classement final"
            showWinnerPodium = true
        }
    }
    
    private func updateButtonSection() {
        if isRoundEnd && !gameManager.isLastRound() {
            // Bouton pour continuer au round suivant
            buttonTitle = "ROUND SUIVANT"
            buttonSubtitle = getNextRoundSubtitle()
            buttonIcon = "arrow.right.circle.fill"
            buttonColors = [.green, .mint]
        } else if isRoundEnd && gameManager.isLastRound() {
            // Bouton pour aller au classement final
            buttonTitle = "CLASSEMENT FINAL"
            buttonSubtitle = "Voir les résultats définitifs"
            buttonIcon = "trophy.fill"
            buttonColors = [.yellow, .orange]
        } else {
            // Fin de partie - Nouvelle partie
            buttonTitle = "NOUVELLE PARTIE"
            buttonSubtitle = "Recommencer avec les mêmes joueurs"
            buttonIcon = "arrow.clockwise.circle.fill"
            buttonColors = [.blue, .purple]
        }
    }
    
    private func getNextRoundSubtitle() -> String {
        let nextRound = gameManager.currentRound.next
        switch nextRound {
        case .round2:
            return "Érudit comme un hibou 🦉"
        case .round3:
            return "Endurant comme une abeille 🐝"
        default:
            return "Prêt pour la suite ?"
        }
    }
    
    // MARK: - Helper Methods
    func isWinner(at index: Int) -> Bool {
        return !isRoundEnd && index == 0
    }
}
