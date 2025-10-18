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

    override func prepareCards() {
        // Ne rien faire ici - les cartes seront préparées dans startTurn()
        // car on a besoin que le mainPlayer soit défini d'abord
    }

    override func startTurn() {
        // Pour le round 3, ordre spécifique : définir le mainPlayer d'abord
        gameManager.setCurrentPlayerMain()
        // Charger la carte personnelle du mainPlayer dans le deck
        gameManager.setCurrentPlayerCardToCards()
        // Récupérer la carte et démarrer le timer
        _ = gameManager.getNextCard()
        gameManager.startRoundTimer()
    }

    override func validateCard() {
        gameManager.audioManager.playValidateCardSound()
        gameManager.startRoundTimer()
        gameManager.setToNextPlayerIndex()
    }
    
    override func passCard() {
        gameManager.audioManager.playPassCardSound()
        if let player = gameManager.safeCurrentPlayer() {
            if player.isMainPlayer {
                endPlayerTurn()
            } else {
                eliminatePlayer()
            }
        }
    }
    
    override func timerFinished() {
        if let player = gameManager.safeCurrentPlayer() {
            if player.isMainPlayer {
                endPlayerTurn()
            } else {
                eliminatePlayer()
            }
        }
    }
    
    override func endPlayerTurn() {
        gameManager.audioManager.playEndTimer()
        gameManager.setMainPlayerIsCurrentPlayer()
        if let player = gameManager.safeCurrentPlayer() {
            player.isMainPlayer = false
        }
        gameManager.resetPlayerEliminated()
        gameManager.setState(state: .playerTurnResult)
    }
    
    func eliminatePlayer() {
        if let player = gameManager.safeCurrentPlayer() {
            player.isEliminated = true
        }
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
