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
        gameManager.addPointToCurrentPlayer(nb: gameManager.getTimeRemaining())
        endPlayerTurn()
    }
    
    /// Passer une carte : juste passer à la carte suivante (sans points)
    override func passCard() {
        _ = gameManager.getNextCard()
        gameManager.currentPlayer().decreaseTurnScore(getNbCardExpectedResponses())
        print(gameManager.cardManager.cards.count)
    }
    
    
    override func getNbCardExpectedResponses() -> Int {
        switch (gameManager.currentPlayer().remainingTurn) {
        case 3 :
            return 3
        case 2:
            return 4
        case 1 :
            return 5
        default :
            return 3
        }
    }
    
}
