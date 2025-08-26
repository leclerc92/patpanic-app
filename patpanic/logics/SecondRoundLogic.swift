//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI


class SecondRoundLogic : BaseRoundLogic {
    
    
    override init(gameManager: GameManager, round: Round) {
        super.init(gameManager: gameManager, round: round)
    }
    
    override func validateCard() {
        gameManager.audioManager.playValidateCardSound()
        gameManager.addPointToCurrentPlayer(nb: gameManager.getTimeRemaining())
        endPlayerTurn()
    }
    
    /// Passer une carte : juste passer à la carte suivante (sans points)
    override func passCard() {
        gameManager.audioManager.playPassCardSound()
        if let player = gameManager.safeCurrentPlayer() {
            player.currentTurnPassedCard += 1
            player.decreaseTurnScore(getNbCardExpectedResponses())
        }
        _ = gameManager.getNextCard()
    }
    
    override func endPlayerTurn() {
        gameManager.audioManager.playEndTimer()
        if let player = gameManager.safeCurrentPlayer() {
            player.decreaseTurnScore(getNbCardExpectedResponses())
            player.decreaseRemainingTurn()
            player.isMainPlayer = false
        }
        gameManager.setState(state: .playerTurnResult)
    }
    
    
    override func getNbCardExpectedResponses() -> Int {
        guard let player = gameManager.safeCurrentPlayer() else {
            return 3 // Valeur par défaut
        }
        
        switch player.remainingTurn {
        case 3:
            return 3
        case 2:
            return 4
        case 1:
            return 5
        default:
            return 3
        }
    }
    
}
