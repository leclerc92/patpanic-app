//
//  BaseRoundLogic.swift
//  panicpas-app
//
//  Created by clement leclerc on 15/08/2025.
//

import SwiftUI

protocol RoundLogicProtocol: ObservableObject {
    
    var roundConst: RoundConfig { get }
    
   
    
  
}

class BaseRoundLogic: ObservableObject, RoundLogicProtocol {
    
    let gameManager: GameManager
    let roundConst: RoundConfig
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.roundConst = Round.round1.config
    }
    
    
}
