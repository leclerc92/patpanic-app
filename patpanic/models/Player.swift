//
//  Player.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

class Player {
    
    let name:String
    var icon:String = "🕺"
    var categorie:String? = nil
    private(set) var score:Int = 0
    private(set) var currentRoundScore = 0
    private(set) var currentTurnScore = 0
    var joker:Bool = false
    var isMainPlayer:Bool = false
    var isEliminated:Bool = false
    
    init(name: String, score: Int, currentRoundScore: Int = 0, currentTurnScore: Int = 0) {
        self.name = name
        self.score = score
        self.currentRoundScore = currentRoundScore
        self.currentTurnScore = currentTurnScore
    }
    
    func addTurnScore (_ points: Int) {
        currentTurnScore += points
    }
    
    func validateTurn () {
        currentRoundScore += currentTurnScore
    }
    
    func validateRound() {
        score += currentRoundScore
    }
    
    func decreaseScore(_ nb:Int) {
        guard score > 0 else {return}
        score -= nb
    }
    
    func resetScore() {
        currentTurnScore = 0
        currentRoundScore = 0
        score = 0
    }

    
    
    
}
