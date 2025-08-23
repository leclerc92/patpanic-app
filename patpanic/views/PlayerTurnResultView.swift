//
//  PlayerTurnResult.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct PlayerTurnResultView: View {
      @StateObject private var viewModel: PlayerTurnResultViewModel

      init(gameManager: GameManager) {
          self._viewModel = StateObject(
              wrappedValue: PlayerTurnResultViewModel(
                  gameManager: gameManager,
              )
          )
      }

      var body: some View {
          ZStack {
              backgroundGradient

              VStack(spacing: 0) {
                  headerSection
                  contentSection
                  Spacer()
              }

              bottomButton
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

      private var contentSection: some View {
          ScrollView {
              VStack(spacing: 30) {
                  GameTitle.endTurn()
                      .padding(.top, 20)

                  PlayerName(
                      playerName: viewModel.playerName,
                      icon: viewModel.playerIcon
                  )
                  .scaleEffect(1.5)

                  ScoreCard.forRound(
                      score: viewModel.currentTurnScore,
                      round: viewModel.currentRound,
                      playerIcon: viewModel.playerIcon
                  )

                  Spacer(minLength: 100)
              }
              .padding(.horizontal)
          }
      }

      private var bottomButton: some View {
          VStack {
              Spacer()

              ButtonMenu(
                  action: viewModel.continueButton,
                  title: viewModel.nextButtonTitle,
                  subtitle: viewModel.nextButtonSubtitle,
                  icon: viewModel.nextButtonIcon,
                  colors: [.green, .mint]
              )
              .padding(.horizontal)
              .padding(.bottom, 20)
          }
      }
  }


#Preview {
    let gameManager = GameManager()
    gameManager.addPlayer(name: "Jean-Michel")
    gameManager.currentPlayer().addTurnScore(25)
    
    return PlayerTurnResultView(
        gameManager: gameManager,

    )
}
