//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI

@MainActor
protocol RoundLogicProtocol: ObservableObject {
    
    var roundConst: RoundConfig { get }
    
    func setupRound()
    func prepareCards()
    func startTurn()
    func validateCard()
    func passCard()
    func timerFinished()
    func getNbCardExpectedResponses() -> Int

}

@MainActor
class RoundLogicFactory {
    
    static func createLogic(for round: Round, gameManager: GameManager) -> BaseRoundLogic {
        switch round {
        case .round1:
            return FirstRoundLogic(gameManager: gameManager, round: round)
        case .round2:
            return SecondRoundLogic(gameManager: gameManager, round: round)
        case .round3:
            return ThirdRoundLogic(gameManager: gameManager, round: round)
        }
    }
}

@MainActor
class BaseRoundLogic: ObservableObject, RoundLogicProtocol {
    
    let gameManager: GameManager
    let roundConst: RoundConfig
    
    init(gameManager: GameManager, round: Round) {
        self.gameManager = gameManager
        self.roundConst = round.config
    }
    
    func setupRound () {
        gameManager.setPlayersRemainingTurn(nb: roundConst.nbTurns)
        gameManager.resetPlayersForRound()
        // Préparer les cartes UNE SEULE FOIS au début du round
        prepareCards()
    }

    func prepareCards() {
        // Implémentation par défaut : générer des cartes normalement
        gameManager.generateCardsForCurrentRound()
    }
    
    func startTurn() {
        _ = gameManager.getNextCard()
        gameManager.setCurrentPlayerMain()
        gameManager.startRoundTimer()
    }
    
    func validateCard() {
        _ = gameManager.getNextCard()
        gameManager.audioManager.playValidateCardSound()

    }
    
    func passCard() {
        _ = gameManager.getNextCard()
        if let player = gameManager.safeCurrentPlayer() {
            player.currentTurnPassedCard += 1
        }
        gameManager.audioManager.playPassCardSound()
    }
    
    func timerFinished() {
        endPlayerTurn()
    }
        
    func endPlayerTurn() {
        gameManager.audioManager.playEndTimer()
        if let player = gameManager.safeCurrentPlayer() {
            player.decreaseRemainingTurn()
            player.isMainPlayer = false
        }
        gameManager.setState(state: .playerTurnResult)
    }
    
    func validatePlayerTurn () {
        gameManager.safeCurrentPlayer()?.validateTurn()
    }
    
    func getNbCardExpectedResponses() -> Int {
        return 2
    }
    
    
    
}


