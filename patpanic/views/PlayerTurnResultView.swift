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
                  bottomButton
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
          .padding(.top)
          .padding(.horizontal)
      }

      private var contentSection: some View {
              VStack(spacing: 30) {
                  GameTitle.endTurn()
                      .padding(.top, 20)

                  PlayerName(
                      playerName: viewModel.playerName,
                      icon: viewModel.playerIcon
                  )
                  

                  ScoreCard.forRound(
                      score: viewModel.currentTurnScore,
                      round: viewModel.currentRound,
                      playerIcon: viewModel.playerIcon,
                      passedCard: viewModel.currentTurnPassedCard
                  )

              }
              .padding(.horizontal)
          
      }

      private var bottomButton: some View {
          VStack {
              VStack(spacing: 10) {
                  Spacer()
                  ButtonMenu(
                      action: viewModel.continueButton,
                      title: viewModel.nextButtonTitle,
                      subtitle: viewModel.nextButtonSubtitle,
                      icon: viewModel.nextButtonIcon,
                      colors: [.green, .mint]
                  )
              }
              
          }.padding()
      }
  }


#Preview {
    let gameManager = GameManager()
    gameManager.addPlayer(name: "Jean_MICHEL DELE")
    gameManager.currentPlayer().addTurnScore(-15)
    
    return PlayerTurnResultView(
        gameManager: gameManager,
    )
}
