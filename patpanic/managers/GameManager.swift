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
    case playerInstruction
}

class GameManager: ObservableObject {
    
    @Published var cardManager: CardManager = CardManager()
    @Published var timeManager: TimeManager = TimeManager()
    
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound:Round = .round1
    @Published private(set) var state:GameState = .playersSetup
    @Published private(set) var currentPlayerIndex:Int = 0
    @Published private(set) var logic: BaseRoundLogic!
    
    init() {
        self.logic = RoundLogicFactory.createLogic(for: currentRound, gameManager: self)
    }
    
    //MARK: - GAME LOOP
    
    func startGame() {
        guard !players.isEmpty, allPlayersHaveCategory() else {
            print("❌ Impossible de démarrer: joueurs manquants ou catégories non assignées")
            return
        }
               
    }
    
    func resetGame() {
    
    }
    
    
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
    
    func currentPlayer() -> Player {
        guard currentPlayerIndex < players.count else {
            fatalError("Index de joueur invalide: \(currentPlayerIndex)")
        }
        return players[currentPlayerIndex]
    }
    
    func getPlayerIndex(player: Player) -> Int? {
        return players.firstIndex(where: { $0.id == player.id })
    }
    
    func updatePlayer(newPlayer: Player, player: Player) {
        guard let index = getPlayerIndex(player: player) else { return }
        players[index] = newPlayer
    }
    
    func allPlayersHaveCategory() -> Bool {
        return players.allSatisfy { $0.personalCard != nil }
    }
    
    func allPlayersPlayed() -> Bool {
        return players.allSatisfy { $0.remainingTurn == 0 }
    }
    
    func getPlayersWithoutCategory() -> [String] {
        return players
            .filter { $0.personalCard == nil }
            .map { $0.name }
    }

    
    func getNextPlayer() -> Player? {
        guard !allPlayersPlayed() else { return nil }
        
        var nextIndex = currentPlayerIndex
        let startIndex = currentPlayerIndex
        
        repeat {
            nextIndex = (nextIndex + 1) % players.count
            let candidate = players[nextIndex]
            
            if !candidate.isEliminated && candidate.remainingTurn > 0 {
                return candidate
            }
            
        } while nextIndex != startIndex
        
        return nil
    }
    
    func goToNextPlayer() {
        guard let nextPlayer = getNextPlayer(),
              let nextIndex = getPlayerIndex(player: nextPlayer) else { return }
        
        currentPlayerIndex = nextIndex
    }
    
    func isLastPlayer() -> Bool {
        return getNextPlayer() == nil
    }
    
    func resetCurrentRoundPoint() {
        for player in players {
            player.resetScore()
        }
    }
    
    func setPlayersRemainingTurn (nb: Int) {
      _ = players.map { $0.setRemainingTurn(nb: nb)}
    }
    
    // MARK: - STATE FUNCTIONS
    
    func setState(state:GameState) {
        self.state = state
    }
    
    
    // MARK: - ROUNDS FUNCTIONS
    
    func getCurrentRoundConfig() -> RoundConfig {
        currentRound.config
    }
        
    func nextRound() {
        if let next = currentRound.next {
            currentRound = next
            updateLogicForCurrentRound()
        }
    }
    
    private func updateLogicForCurrentRound() {
        logic = RoundLogicFactory.createLogic(for: currentRound, gameManager: self)
    }
    
    func isLastRound() -> Bool {
        return currentRound.isLastRound
    }
    
    //MARK: - TIME FUNCTION
    
    func getTimeRemaining() -> Int {
        return timeManager.timeRemaining
    }
    
    func startRoundTimer () {
        timeManager.startTimer(duration: currentRound.config.timer, onTimeUp: logic.timerFinished)
    }
    
    
    // MARK: - CARD FUNCTIONS
    
    func generateCardsForCurrentRound() {
        let roundNumber = getRoundNumber()
        let cardsNeeded = GameConst.CARDPERPLAYER * players.count

        cardManager.generateGameCards(
            count: cardsNeeded,
            category: nil, // Toutes les catégories
            round: roundNumber
        )
        
    }
    
    func generateCardsForCategory(_ category: String) {
        let roundNumber = getRoundNumber()
        let cardsNeeded = GameConst.CARDPERPLAYER * players.count
    
        cardManager.generateGameCards(
            count: cardsNeeded,
            category: category,
            round: roundNumber
        )
    }
    
    func getNextCard() -> Card? {
        return cardManager.nextCard()
    }
    
    func getCurrentCard() -> Card? {
        return cardManager.currentCard
    }
    
    func getAvailableCategories() -> [String] {
        return cardManager.getAvailableCategories()
    }
    
    func getCategoryColor(for category: String) -> String {
        return cardManager.getCategoryColor(for: category)
    }
    
    func generatePlayerCard(for category: String) -> Card? {
        return cardManager.generatePlayerCard(for: category)
    }
    
    private func getRoundNumber() -> Int {
        switch currentRound {
        case .round1: return 1
        case .round2: return 2
        case .round3: return 3
        }
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
