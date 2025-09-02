//
//  ConfigViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 28/08/2025.
//

import Foundation

@MainActor
class ConfigViewModel: ObservableObject {
    
    @Published var timerRound1: Int
    @Published var timerRound2: Int
    @Published var timerRound3: Int
    
    private let gameManager: GameManager

    
    init(gameManager:GameManager) {
        self.timerRound1 = 45
        self.timerRound2 = 30
        self.timerRound3 = 20
        self.gameManager = gameManager
    }
    
    func cancelButton() {
       
    }
    
    
    
}


