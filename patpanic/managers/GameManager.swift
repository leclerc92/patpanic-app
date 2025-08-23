//
//  GameManager.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

enum GameState {
    case playersSetup
    case roundInstruction
    case playerInstruction
    case playing
    case playerTurnResult
    case roundResult
    case gameResult
}

@MainActor
class GameManager: ObservableObject {
    
    @Published var cardManager: CardManager = CardManager()
    @Published var timeManager: TimeManager = TimeManager()
    @Published var gameState: GameState = .playersSetup
    
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound:Round = .round2
    @Published private(set) var currentPlayerIndex:Int = 0
    @Published private(set) var logic: BaseRoundLogic!
    
    init() {
        self.logic = RoundLogicFactory.createLogic(for: currentRound, gameManager: self)
    }
    
    //MARK: - GAME STATE MANAGEMENT
    
    func setState(state: GameState) {
        gameState = state
    }
    
    func startGame() {
        guard !players.isEmpty, allPlayersHaveCategory() else {
            print("❌ Impossible de démarrer: joueurs manquants ou catégories non assignées")
            return
        }
        gameState = .roundInstruction
    }
    
    func resetGame() {
        for player in players {
            player.resetScore()
            player.personalCard = nil
        }
        gameState = .playersSetup
    }
    
    func startPlayerTurn () {
        let nbCard = GameConst.CARDPERPLAYER - cardManager.cards.count
        cardManager.generateGameCards(count: nbCard, round: currentRound.rawValue)
        logic.startTurn()
        gameState = .playing
    }
    
    func endPlayerTurn () {
        logic.endPlayerTurn()
    }
    
    func setupRound() {
        logic.setupRound()
    }
    
    func goToNextRound () {
        nextRound()
        resetPlayersRoundScore()
        goToNextPlayer()
        setState(state: .roundInstruction)
    }
        
    func goToNextPlayerTurn() {
        logic.validatePlayerTurn()
        setState(state: .playerInstruction)
    }
    
    func goToEndOfRound() {
        logic.validatePlayerTurn()
        setState(state: .roundResult)
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
    
    func addPointToCurrentPlayer(nb: Int) {
        currentPlayer().addTurnScore(nb)
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
    
    func resetPlayersScore() {
        for player in players {
            player.resetScore()
        }
    }
    
    func resetPlayersRoundScore() {
        for player in players {
            player.resetRoundScore()
        }
    }
    
    func setPlayersRemainingTurn (nb: Int) {
        for player in players {
            player.setRemainingTurn(nb: nb)
        }
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
        // Appeler setupRound après la création de la logique
        DispatchQueue.main.async {
            self.logic.setupRound()
        }
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
        print("-----------------------------")
        print("state du jeu : \(gameState)")
        print("Nb joueurs : \(players.count)")
        print("joueurs theme : \(allPlayersHaveCategory())")
        print("round actuel : \(currentRound)")
        print("Nb cartes : \(cardManager.cards.count)")
        print("Nb cartes utilisées : \(cardManager.usedCards.count)")
        print("Joueur actuel : \(currentPlayerIndex) - \(players[currentPlayerIndex].name)")
        print("dernier joueur du round : \(isLastPlayer())")
        print("-----------------------------")

    }
    
    
    
    
    
    
}
