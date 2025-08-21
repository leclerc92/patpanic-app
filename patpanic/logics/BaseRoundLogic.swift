//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI

protocol RoundLogicProtocol: ObservableObject {
    
    var roundConst: RoundConfig { get }
    
    func setupRound()
    func validateCard()
    func passCard()
    func timerFinished()
    func getNbResponses() -> Int

}

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

class BaseRoundLogic: ObservableObject, RoundLogicProtocol {
    
    let gameManager: GameManager
    let roundConst: RoundConfig
    
    init(gameManager: GameManager, round: Round) {
        self.gameManager = gameManager
        self.roundConst = round.config
    }
    
    func setupRound () {
        gameManager.setPlayersRemainingTurn(nb: roundConst.nbTurns)
        gameManager.startRoundTimer()
    }
    
    
    func validateCard() {
        _ = gameManager.getNextCard()
    }
    
    func passCard() {
        _ = gameManager.getNextCard()
    }
    
    func timerFinished() {
        print("timer finished")
    }
    
    
    func getNbResponses() -> Int {
        return 2
    }
    
    
    
}


