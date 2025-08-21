//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI

protocol RoundLogicProtocol: ObservableObject {
    
    var roundConst: RoundConfig { get }
    
    func validateCard()
    func passCard()

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
    
    
    func validateCard() {
        gameManager.getNextCard()
    }
    
    func passCard() {
        gameManager.getNextCard()
    }
    
    
    
}


