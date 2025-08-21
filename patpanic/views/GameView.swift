//
//  GameView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject var gameManager: GameManager
    @State private var isCardEjecting = false
    @State private var isPaused = false
    
    var currentPlayer: Player {
        gameManager.currentPlayer()
    }
    
    var roundConst: RoundConfig {
        gameManager.logic.roundConst
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
            
            
            VStack {
                
                HStack {
                    Spacer()
                    CancelButton(action: gameManager.resetGame)
                }.padding()
                
                VStack {
                    
                    HStack {
                        
                        GameTitle(
                            icon: nil,
                            title: "MANCHE \(gameManager.currentRound.rawValue)",
                            subtitle: nil
                        ).padding(.horizontal, 10)
                        
                        GameTimer(timeRemaining: gameManager.getTimeRemaining(), totalTime: roundConst.timer, onTimeUp: {})
                            .scaleEffect(1.3)
                    }
                    
                }
                .padding(.bottom)
                
                Spacer()
                
                PlayerName(playerName: currentPlayer.name, icon: currentPlayer.icon)
                    .padding(.bottom,20)
                
                if let currentCard = gameManager.getCurrentCard() {
                    GameCard(
                        theme: currentCard.theme,
                        size: .large,
                        isEjecting: isCardEjecting,
                        onPause: {
                            isPaused.toggle()
                            print(isPaused ? "Jeu en pause" : "Jeu repris")
                        }
                    )
                } else {
                    Text("Plus de cartes disponibles")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                }
                   
            
                Spacer()
                
                ScoreDisplay(score: currentPlayer.currentTurnScore)
                    .padding(.top)
                Spacer()
                
                HStack{
                    RoundButton.validateButton(action: validateCard)
                        .padding(.horizontal,50)
                    RoundButton.skipButton(action: passCard)
                        .padding(.horizontal,50)

                }.padding()
                
            }.padding()
            
        }
    }
    
    private func validateCard() {
        // Animation d'éjection de carte
        withAnimation {
            isCardEjecting = true
        }
        
        // Appeler la logique de validation
        gameManager.logic.validateCard()
        
        // Réinitialiser l'animation après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isCardEjecting = false
        }
    }
    
    private func passCard() {
        // Animation d'éjection de carte
        withAnimation {
            isCardEjecting = true
        }
        
        // Appeler la logique de passage
        gameManager.logic.passCard()
        
        // Réinitialiser l'animation après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isCardEjecting = false
        }
    }
}

#Preview {
    
    let gameManager: GameManager = GameManager()
    gameManager.addPlayer(name: "Jean-Michel welbeck")
    gameManager.generateCardsForCurrentRound()
    _ = gameManager.getNextCard()
    
    return GameView(gameManager: gameManager)
}
