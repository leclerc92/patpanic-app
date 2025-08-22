//
//  PlayerInstructionViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import Foundation

import SwiftUI
  import Combine

  @MainActor
  class PlayerInstructionViewModel: ObservableObject {
      // MARK: - Published Properties
      @Published var playerName: String = ""
      @Published var playerIcon: String = ""
      @Published var remainingTurns: Int = 0
      @Published var currentRoundScore: Int = 0
      @Published var totalScore: Int = 0
      @Published var roundTitle: String = ""
      @Published var roundIcon: String = ""
      @Published var roundNumber: Int = 1
      @Published var missionCard: MissionCard?
      @Published var showRules = false

      // MARK: - Dependencies
      private let gameManager: GameManager
      private let onCancel: () -> Void
      private let onContinue: () -> Void

      // MARK: - Initialization
      init(gameManager: GameManager, onCancel: @escaping () -> Void, onContinue: @escaping () -> Void) {
          self.gameManager = gameManager
          self.onCancel = onCancel
          self.onContinue = onContinue
          setupData()
      }

      // MARK: - Setup
      private func setupData() {
          let player = gameManager.currentPlayer()
          let roundConfig = gameManager.getCurrentRoundConfig()

          // Mise à jour des propriétés du player
          playerName = player.name
          playerIcon = player.icon
          remainingTurns = player.remainingTurn
          currentRoundScore = player.currentRoundScore
          totalScore = player.score

          // Mise à jour des propriétés du round
          roundTitle = roundConfig.title
          roundIcon = roundConfig.icon
          roundNumber = gameManager.currentRound.rawValue

          // Création de la mission card (logique déplacée ici)
          missionCard = createMissionCard(for: gameManager.currentRound, config: roundConfig)
      }

      // MARK: - Actions
      func cancelButton() {
          onCancel()
      }

      func continuerButton() {
          onContinue()
      }

      func showRulesPressed() {
          showRules = true
      }

      // MARK: - Private Methods
      private func createMissionCard(for round: Round, config: RoundConfig) -> MissionCard? {
          switch round.rawValue {
          case 1:
              return MissionCard.speedChallenge(timeLimit: config.timer)
          case 2:
              let responseCount = gameManager.logic.getNbResponses()
              return MissionCard.giveWords(count: responseCount)
          case 3:
              return MissionCard.eliminate()
          default:
              return nil
          }
      }
  }
