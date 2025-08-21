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
    
    
    override func getNbResponses() -> Int {
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
