//
//  GameView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject var gameManager:GameManager
    var player:Player
    let roundConst: RoundConfig

    init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.player = gameManager.currentPlayer()
        self.roundConst = gameManager.getCurrentRoundConfig()
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
                
                PlayerName(playerName: player.name, icon: player.icon)
                    .padding(.bottom,20)
                
                GameCard(theme: "Les pistaches", size: .large, onPause: {})
                   
            
                Spacer()
                
                ScoreDisplay(score: player.currentTurnScore)
                    .padding(.top)
                Spacer()
                
                HStack{
                    RoundButton.validateButton(action: {})
                        .padding(.horizontal,50)
                    RoundButton.skipButton(action: {})
                        .padding(.horizontal,50)

                }.padding()
                
            }.padding()
            
        }
    }
}

#Preview {
    
    let gameManager: GameManager = GameManager()
    gameManager.addPlayer(name: "Jean-Michel welbeck")
    
    return GameView(gameManager: gameManager)
}
