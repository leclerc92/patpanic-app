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
    
        switch gameManager.gameState {
        case .playersSetup:
            PlayerSetupView(
                gameManager: gameManager
            )
            
        case .roundInstruction:
            RoundInstructionView(
                gameManager: gameManager
            )
        case .playerInstruction:
            PlayerInstructionView(
                gameManager: gameManager,
            )
            
        case .playing:
            GameView(gameManager: gameManager)
            
        case .playerTurnResult:
            PlayerTurnResultView(
                gameManager: gameManager,
            )
            
        case .roundResult:
            LeaderboardView.roundEnd(
                gameManager: gameManager,
            )
            
        case .gameResult:
            LeaderboardView.gameEnd(
                gameManager: gameManager
            )
            }
    }
}

#Preview {
    AppView()
}
