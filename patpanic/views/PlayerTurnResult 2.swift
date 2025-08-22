//
//  PlayerTurnResult.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct PlayerTurnResult: View {
    
    @ObservedObject var gameManager: GameManager
    let onCancel: () -> Void
    let onContinue: () -> Void
    let player: Player
    
    init(gameManager: GameManager, onCancel: @escaping () -> Void, onContinue: @escaping () -> Void) {
        self.gameManager = gameManager
        self.onCancel = onCancel
        self.onContinue = onContinue
        self.player = gameManager.currentPlayer()
    }
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    CancelButton(action: onCancel)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        GameTitle.endTurn()
                            .padding(.top, 20)
                        
                        PlayerName(
                            playerName: player.name,
                            icon: player.icon
                        )
                        .scaleEffect(1.5)
                        
                        ScoreCard.forRound(
                            score: player.currentTurnScore,
                            round: gameManager.currentRound,
                            playerIcon: player.icon
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                ButtonMenu(
                    action: onContinue,
                    title: nextButtonTitle,
                    subtitle: nextButtonSubtitle,
                    icon: nextButtonIcon,
                    colors: [.green, .mint]
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var nextButtonTitle: String {
        if gameManager.isLastPlayer() {
            return "TERMINER LE ROUND"
        } else {
            return "JOUEUR SUIVANT"
        }
    }
    
    private var nextButtonSubtitle: String {
        if gameManager.isLastPlayer() {
            return "Voir les résultats du round"
        } else {
            let nextPlayer = gameManager.getNextPlayer()
            return "Au tour de \(nextPlayer?.name ?? "...")"
        }
    }
    
    private var nextButtonIcon: String {
        gameManager.isLastPlayer() ? "checkmark.circle.fill" : "arrow.right.circle.fill"
    }
}

#Preview {
    let gameManager = GameManager()
    gameManager.addPlayer(name: "Jean-Michel")
    gameManager.currentPlayer().addTurnScore(25)
    
    return PlayerTurnResult(
        gameManager: gameManager,
        onCancel: { print("Cancel") },
        onContinue: { print("Continue") }
    )
}
