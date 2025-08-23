import SwiftUI
  import Combine

  @MainActor
  class PlayerTurnResultViewModel: ObservableObject {
      // MARK: - Published Properties
      @Published var playerName: String = ""
      @Published var playerIcon: String = ""
      @Published var currentTurnScore: Int = 0
      @Published var currentRound: Round = .round1
      @Published var nextButtonTitle: String = ""
      @Published var nextButtonSubtitle: String = ""
      @Published var nextButtonIcon: String = ""
      @Published var isLastPlayer: Bool = false
      @Published var allPlayerMain: Bool = false
      @Published var currentTurnPassedCard: Int = 0

      // MARK: - Dependencies
      private let gameManager: GameManager


      // MARK: - Initialization
      init(gameManager: GameManager) {
          self.gameManager = gameManager

          setupData()
      }

      // MARK: - Setup
      private func setupData() {
          let player = gameManager.currentPlayer()

          // Mise à jour des propriétés du player
          playerName = player.name
          playerIcon = player.icon
          currentTurnScore = player.currentTurnScore
          currentTurnPassedCard = player.currentTurnPassedCard
          currentRound = gameManager.currentRound
          
          // Mise à jour des propriétés du bouton
          updateButtonState()
      }

      // MARK: - Actions
      func cancelButton() {
          gameManager.resetGame()
      }

      func continueButton() {
          if isLastPlayer {
              gameManager.goToRoundResult()
          } else {
              gameManager.continueWithNextPlayer()
          }
      }

      // MARK: - Private Methods
      private func updateButtonState() {
          isLastPlayer = gameManager.isLastPlayer()

          if isLastPlayer  {
              nextButtonTitle = "TERMINER LA MANCHE"
              nextButtonSubtitle = "Voir les résultats du round"
              nextButtonIcon = "checkmark.circle.fill"
          } else {
              nextButtonTitle = "JOUEUR SUIVANT"
              nextButtonIcon = "arrow.right.circle.fill"

              if let nextPlayer = gameManager.getNextPlayer() {
                  nextButtonSubtitle = "Au tour de \(nextPlayer.name)"
              } else {
                  nextButtonSubtitle = "Prochain joueur"
              }
          }
      }
  }
