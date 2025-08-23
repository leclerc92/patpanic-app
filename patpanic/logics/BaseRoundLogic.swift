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
        print("setup round")
        gameManager.setPlayersRemainingTurn(nb: roundConst.nbTurns)
    }
    
    func startTurn() {
        _ = gameManager.getNextCard()
        gameManager.startRoundTimer()
    }
    
    func validateCard() {
        _ = gameManager.getNextCard()
    }
    
    func passCard() {
        _ = gameManager.getNextCard()
    }
    
    func timerFinished() {
        endPlayerTurn()
    }
        
    func endPlayerTurn() {
        gameManager.currentPlayer().decreaseRemainingTurn()
        gameManager.setState(state: .playerTurnResult)
    }
    
    func validatePlayerTurn () {
        gameManager.currentPlayer().validateTurn()
        gameManager.goToNextPlayer()
    }
    
    func getNbCardExpectedResponses() -> Int {
        return 2
    }
    
    
    
}


