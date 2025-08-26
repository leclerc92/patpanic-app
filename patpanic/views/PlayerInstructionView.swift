//
//  PlayerInstructionView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct PlayerInstructionView: View {
      @StateObject private var viewModel: PlayerInstructionViewModel

      init(gameManager: GameManager) {
          self._viewModel = StateObject(
              wrappedValue: PlayerInstructionViewModel(
                  gameManager: gameManager,
              )
          )
      }

      var body: some View {
          ZStack {
              backgroundGradient

              VStack(spacing: 0) {
                  headerSection
                  playerSection
                  titleSection
                  statsSection
                  missionSection
                  Spacer()
                  rulesButton
                  startButton
              }
          }

      }

      // MARK: - View Components
      private var backgroundGradient: some View {
          LinearGradient(
              colors: [
                  Color.blue.opacity(0.15),
                  Color.purple.opacity(0.15),
                  Color.pink.opacity(0.15)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
          )
          .ignoresSafeArea()
      }

      private var headerSection: some View {
          HStack {
              Spacer()
              CancelButton(action: viewModel.cancelButton)
          }
          .padding()
      }

      private var playerSection: some View {
          PlayerName(
              playerName: viewModel.playerName,
              icon: viewModel.playerIcon
          )
      }

      private var titleSection: some View {
          GameTitle(
              icon: viewModel.roundIcon,
              title: viewModel.roundTitle,
              subtitle: "Are you radis ?"
          )
          .padding()
      }

      private var statsSection: some View {
          HStack {
              StatCard.roundScore(
                  score: viewModel.currentRoundScore,
                  roundNumber: viewModel.roundNumber,
                  size: .compact
              )
              StatCard.turnsRemaining(
                  count: viewModel.remainingTurns,
              )
              StatCard.totalScore(
                  score: viewModel.totalScore,
                  size: .compact
              )
          }
          .padding()
      }

      private var missionSection: some View {
          Group {
              if let missionCard = viewModel.missionCard {
                  missionCard.padding()
              }
          }
      }

      private var rulesButton: some View {
          ButtonMenu(
              action: viewModel.showRulesPressed,
              title: "Petite mémoire ?",
              subtitle: "Afficher les règles",
              icon: "line.3.horizontal.button.angledtop.vertical.right",
              colors: [Color.gray, Color.secondary]
          )
          .padding()
      }

      private var startButton: some View {
          ButtonMenu.primaryButton(
              title: "Okaay let's gow !",
              subtitle: "Detends toi la nouille ça commence vraiment !",
              icon: "play.fill"
          ) {
              viewModel.continuerButton()
          }
          .padding()
      }
  }

#Preview {
    
    let gameManager:GameManager = GameManager()
    _ = gameManager.addPlayer(name: "Michel")

    
     return PlayerInstructionView(
        gameManager: gameManager
    )
}
