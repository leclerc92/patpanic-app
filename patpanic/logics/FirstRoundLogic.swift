//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI


class FirstRoundLogic : BaseRoundLogic {
    
    override init(gameManager: GameManager, round: Round) {
        super.init(gameManager: gameManager, round: round)
    }
    
    // MARK: - Logique spécifique du premier round
    
    /// Valider une carte : +1 point au joueur et passer à la carte suivante
    override func validateCard() {
        gameManager.audioManager.playValidateCardSound()
        gameManager.addPointToCurrentPlayer(nb: 1)
        _ = gameManager.getNextCard()
    }
    
    /// Passer une carte : juste passer à la carte suivante (sans points)
    override func passCard() {
        gameManager.audioManager.playPassCardSound()
        if let player = gameManager.safeCurrentPlayer() {
            player.currentTurnPassedCard += 1
        }
        _ = gameManager.getNextCard()
    }
}
