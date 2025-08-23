//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI


class ThirdRoundLogic : BaseRoundLogic {
    
    override init(gameManager: GameManager, round: Round) {
        super.init(gameManager: gameManager, round: round)
    }
    
    override func validateCard() {
        gameManager.startRoundTimer()
        gameManager.setToNextPlayerIndex()
    }
    
    override func passCard() {
        if gameManager.currentPlayer().isMainPlayer {
            endPlayerTurn()
        } else {
            eliminatePlayer ()
        }
    }
    
    override func timerFinished() {
        if gameManager.currentPlayer().isMainPlayer {
            endPlayerTurn()
        } else {
            eliminatePlayer()
        }
    }
    
    override func endPlayerTurn() {
        gameManager.setMainPayerIsCurrentPLayer()
        gameManager.currentPlayer().isMainPlayer = false
        gameManager.resetPlayerEliminated()
        gameManager.setState(state: .playerTurnResult)
    }
    
    func eliminatePlayer() {
        gameManager.currentPlayer().isEliminated = true
        gameManager.addPointToMainPlayer(nb: 1)
        checkVictory()
    }
    
    func checkVictory() {
        // Vérifier s'il ne reste qu'un joueur (victoire)
        if gameManager.players.filter({ !$0.isEliminated}).count == 1 {
            gameManager.addPointToMainPlayer(nb: gameManager.players.count * 2)
            endPlayerTurn()
        } else {
            gameManager.setToNextPlayerIndex()
        }
    }
    
}
