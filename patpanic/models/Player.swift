//
//  Player.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

class Player: Hashable, Identifiable {
    
    static func == (lhs: Player, rhs: Player) -> Bool {
            return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
    
    let id = UUID()
    let name:String
    var icon:String = "🕺"
    var personalCard: Card? = nil
    private(set) var score:Int = 0
    private(set) var currentRoundScore = 0
    private(set) var currentTurnScore = 0
    var joker:Bool = false
    var isMainPlayer:Bool = false
    var isEliminated:Bool = false
    private(set) var remainingTurn: Int = 0
    
    init(name: String) {
        self.name = name
        self.score = 0
        self.currentRoundScore = 0
        self.currentTurnScore = 0
    }
    
    func addTurnScore (_ points: Int) {
        currentTurnScore += points
    }
    
    func validateTurn () {
        currentRoundScore += currentTurnScore
        score += currentTurnScore
        currentTurnScore = 0
    }
    
    
    func decreaseScore(_ nb:Int) {
        guard score > 0 else {return}
        score -= nb
        
    }
    
    func setRemainingTurn(nb: Int) {
        remainingTurn = nb
    }
    
    func decreaseRemainingTurn() {
        if remainingTurn > 0 {
            remainingTurn -= 1
        }
    }
    
    func resetScore() {
        currentTurnScore = 0
        currentRoundScore = 0
        score = 0
    }
    
    func resetRoundScore() {
        currentTurnScore = 0
        currentRoundScore = 0
    }
    
    func resetTurnScore() {
        currentTurnScore = 0
    }

    
    
    
}
