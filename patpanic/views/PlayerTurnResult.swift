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
            // Arrière-plan gradient
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
                // Header fixe
                HStack {
                    Spacer()
                    CancelButton(action: onCancel)
                }
                .padding()
                
                // Contenu principal
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // Titre de fin de tour
                        GameTitle.endTurn()
                            .padding(.top, 20)
                        
                        // Nom du joueur avec style
                        PlayerName(
                            playerName: player.name,
                            icon: player.icon
                        )
                        .scaleEffect(1.5)
                        
                        // Carte de score
                        ScoreCard.forRound(
                            score: player.currentTurnScore,
                            round: gameManager.currentRound,
                            playerIcon: player.icon
                        )
                        
                        // Espace pour le bouton fixe
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            
            // Bouton fixe en bas
            VStack {
                Spacer()
                
                // Bouton adaptatif selon le contexte
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




// MARK: - Composant StatCard

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title2)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
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
