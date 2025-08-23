//
//  GameView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    
    init(gameManager: GameManager) {
        self._viewModel = StateObject(
            wrappedValue: GameViewModel(gameManager: gameManager)
        )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack {
                headerSection
                titleAndTimerSection
                Spacer()
                playerSection
                cardSection
                Spacer()
                scoreSection
                Spacer()
                actionButtonsSection
            }.padding()
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
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
            CancelButton(action: viewModel.resetGame)
        }.padding()
    }
    
    private var titleAndTimerSection: some View {
        VStack {
            HStack {
                GameTitle(
                    icon: nil,
                    title: viewModel.roundTitle,
                    subtitle: nil
                ).padding(.horizontal, 10)
                
                GameTimer(
                    timeRemaining: viewModel.timeRemaining,
                    totalTime: viewModel.totalTime
                )
                .scaleEffect(1.3)
            }
        }
        .padding(.bottom)
    }
    
    private var playerSection: some View {
        PlayerName(
            playerName: viewModel.currentPlayerName,
            icon: viewModel.currentPlayerIcon
        )
        .padding(.bottom, 20)
    }
    
    private var cardSection: some View {
        Group {
            if let currentCard = viewModel.currentCard {
                GameCard(
                    theme: currentCard.theme,
                    size: .large,
                    isEjecting: viewModel.isCardEjecting,
                    onPause: viewModel.togglePause
                )
            } else {
                Text("Plus de cartes disponibles")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private var scoreSection: some View {
        ScoreDisplay(score: viewModel.currentPlayerScore)
            .padding(.top)
    }
    
    private var actionButtonsSection: some View {
        HStack {
            RoundButton.skipButton(action: viewModel.passCard)
                .padding(.horizontal, 50)
            RoundButton.validateButton(action: viewModel.validateCard)
                .padding(.horizontal, 50)
        }.padding()
    }
    
}

#Preview {
    let gameManager: GameManager = GameManager()
    gameManager.addPlayer(name: "Jean-Michel welbeck")
    
    // Créer une carte de test pour le preview
    let testTheme = Theme(category: "Test", title: "Animaux de compagnie", colorName: "blue")
    let testCard = Card(theme: testTheme)
    gameManager.cardManager.currentCard = testCard
    
    gameManager.logic.setupRound()
    
    return GameView(gameManager: gameManager)
}
