//
//  ContentView.swift
//  patpanic
//
//  Created by clement leclerc on 19/08/2025.
//

import SwiftUI

struct AppView: View {
    
    @StateObject private var gameManager:GameManager = GameManager()
    

    var body: some View {
        switch gameManager.state {
        case .playersSetup:
            PlayerSetupView(
                gameManager: gameManager,
                onContinue:{
                    gameManager.setState(state: .roundInstruction)
                }
            )
            
        case .roundInstruction:
            InstructionView(
                onCancel: {
                    gameManager.setState(state: .playersSetup)
                },
                onContinue: {
                    gameManager.setState(state: .playerInstruction)
                },
                gameManager: gameManager
            )
        case .playerInstruction:
            PlayerInstructionView(
                gameManager: gameManager,
                onCancel: {
                    gameManager.setState(state: .playersSetup)
                },
                onContinue: {
                    gameManager.setState(state: .playing)
                    gameManager.startRoundTimer()
                }
            )
            
        case .playing:
            GameView(gameManager: gameManager,)
            
        case .playerTurnResult:
            PlayerTurnResult(
                gameManager: gameManager,
                onCancel: {
                    gameManager.setState(state: .playersSetup)
                },
                onContinue: {
                    if gameManager.isLastPlayer() {
                        gameManager.setState(state: .roundResult)
                    } else {
                        gameManager.goToNextPlayer()
                        gameManager.setState(state: .playing)
                    }
                }
            )
            
        case .roundResult:
            LeaderboardView.roundEnd(
                gameManager: gameManager,
                onContinue: {
                    if gameManager.isLastRound() {
                        gameManager.setState(state: .gameResult)
                    } else {
                        gameManager.nextRound()
                        gameManager.setState(state: .roundInstruction)
                    }
                },
                onCancel: {
                    gameManager.setState(state: .playersSetup)
                }
            )
            
        case .gameResult:
            LeaderboardView.gameEnd(
                gameManager: gameManager,
                onContinue: {
                    // Nouvelle partie avec les mêmes joueurs
                    gameManager.resetGame()
                    gameManager.setState(state: .roundInstruction)
                },
                onCancel: {
                    gameManager.setState(state: .playersSetup)
                }
            )
        default:
            PlayerSetupView(gameManager: gameManager,onContinue: {})
            
        }
    }
}

#Preview {
    AppView()
}
