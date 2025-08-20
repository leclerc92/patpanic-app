//
//  GameManager.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

enum GameState {
    case playersSetup
    case playing
    case roundInstruction
    case playerTurnResult
    case roundResult
    case gameResult
    case paused
}

class GameManager: ObservableObject {
    
    let cardManager: CardManager = CardManager()
    @Published private(set) var players: [Player] = []
    private(set) var currentRound:Int = 1
    private(set) var state:GameState = .playersSetup
    private(set) var currentPlayerIndex:Int = 0
    
    
    // MARK: - PLAYER FUNCTIONS
    
    
    func addPlayer(name: String) {
        guard players.count < 9 else {print("Le nombre de player est > 8"); return}
        let np = Player(name: name)
        players.append(np)
    }
        
    func removePlayer(at index: Int) {
        guard index < players.count else {
            print("Index \(index) invalide pour supprimer un joueur")
            return
        }
        players.remove(at: index)
    }
    
    func getPlayerIndex (player:Player) -> Int? {
        return  players.firstIndex(where: { $0.id == player.id })
    }
    
    func updatePlayer(newPlayer:Player, player:Player) {
        let index = getPlayerIndex(player: player)
        if index != nil {
            players[index!] = newPlayer
        }
    }
    
    func allPlayersHaveCategory() -> Bool {
        return players.allSatisfy { $0.category != nil }
    }
    
    func getPlayersWithoutCategory() -> [String] {
        var names : [String] = []
        let players = players.filter {
            $0.category == nil
        }
        for p in players { names.append(p.name)}
        return names
    }
    
    
    // MARK: -  UTILS FUNCTIONS
    
    func displayGameState(){
        print("Nb joueurs : \(players.count)")
        print("round actuel : \(currentRound)")
        print("Nb cartes : \(cardManager.cards.count)")
        print("Nb cartes utilisées : \(cardManager.usedCards.count)")
        print("Joueur actuel : \(currentPlayerIndex) - \(players[currentPlayerIndex].name)")
    }
    
    
    
    
    
    
}
