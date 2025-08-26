//
//  GameManager.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation
import Combine

enum GameState: Equatable {
    case playersSetup
    case roundInstruction(needSetupRound: Bool)
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
    @Published var audioManager: AudioManager = AudioManager()
    @Published var gameState: GameState = .playersSetup
    
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound:Round = .round2
    @Published private(set) var currentPlayerIndex:Int = 0
    @Published private(set) var logic: BaseRoundLogic!
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.logic = RoundLogicFactory.createLogic(for: currentRound, gameManager: self)
        setupBackgroundMusic()
        
        // Démarrer la musique immédiatement puisqu'on commence en playersSetup
        audioManager.playBackgroundMusic()
    }
    
    // MARK: - BACKGROUND MUSIC MANAGEMENT
    private func setupBackgroundMusic() {
        // Observer les changements d'état pour gérer la musique
        $gameState
            .sink { [weak self] newState in
                self?.handleBackgroundMusicForState(newState)
            }
            .store(in: &cancellables)
    }
    
    private func handleBackgroundMusicForState(_ state: GameState) {
        switch state {
        case .playing:
            // Arrêter la musique avec fade out quand on joue
            audioManager.fadeOutBackgroundMusic(duration: 1.0)
        case .playersSetup, .roundInstruction, .playerInstruction, .playerTurnResult, .roundResult, .gameResult:
            // Jouer la musique de fond pour tous les autres états
            if !audioManager.isMusicPlaying {
                audioManager.playBackgroundMusic()
            }
        }
    }
    
    //MARK: - GAME STATE MANAGEMENT
    
    func setState(state: GameState) {
        gameState = state
    }
        
    func resetGame() {
        for player in players {
            player.resetScore()
            player.personalCard = nil
        }
        gameState = .playersSetup
    }
    
    func goToPlayingView() {
        logic.prepareCards()
        logic.startTurn()
        gameState = .playing
    }
    
    func continueWithNextPlayer() {
        currentPlayer().validateTurn()
        setToNextPlayerIndex()
        goToPlayerInstructionView()
        displayGameState()
    }
    
    func continueWithNextRound() {
        resetPlayersMainState()
        resetPlayerEliminated()
        resetPlayerCardPassed()
        nextRound()
        currentPlayerIndex = 0  // Retour au premier joueur pour le nouveau round
        goToRoundInstructionView(needSetupRound: true)
        displayGameState()
    }
    
    func goToRoundInstructionView(needSetupRound:Bool) {
        gameState = .roundInstruction(needSetupRound: needSetupRound)
        displayGameState()
    }
    
    func goToPlayerInstructionView() {
        gameState = .playerInstruction
        displayGameState()
    }
    
    func goToPlayerResultView() {
        gameState = .playerTurnResult
        displayGameState()
    }
    
    func goToRoundResult() {
        audioManager.playRoundResultSound()
        currentPlayer().validateTurn()
        gameState = .roundResult
        displayGameState()
    }
    
    func goToGameResult() {
        audioManager.playRoundResultSound()
        currentPlayer().validateTurn()
        gameState = .gameResult
        displayGameState()
    }
        
    func endPlayerTurn () {
        logic.endPlayerTurn()
    }
    
    func setupRound() {
        logic.setupRound()
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
    
    func mainPlayer() -> Player? {
        return players.first(where: { $0.isMainPlayer })
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
    
    func allPlayersHadBeenMain() -> Bool {
        return players.allSatisfy { $0.hasBeenMainPlayer }
    }
    
    func getPlayersWithoutCategory() -> [String] {
        return players
            .filter { $0.personalCard == nil }
            .map { $0.name }
    }
    
    func addPointToCurrentPlayer(nb: Int) {
        currentPlayer().addTurnScore(nb)
    }
    
    func addPointToMainPlayer(nb: Int) {
        mainPlayer()?.addTurnScore(nb)
    }

    
    func getNextPlayer() -> Player? {
        guard !allPlayersPlayed() else { return nil }
        
        var nextIndex = currentPlayerIndex
        let startIndex = currentPlayerIndex
        
        repeat {
            nextIndex = (nextIndex + 1) % players.count
            let candidate = players[nextIndex]
            
            // Pour le round 3, on cherche le prochain joueur qui n'a pas encore été main
            if currentRound == .round3 {
                // Pendant un tour : ne sélectionner que les joueurs non éliminés
                // Entre les tours : chercher le prochain qui n'a pas été main
                if gameState == .playing {
                    if !candidate.isEliminated && candidate.remainingTurn > 0 {
                        return candidate
                    }
                } else {
                    if !candidate.isEliminated && candidate.remainingTurn > 0 && !candidate.hasBeenMainPlayer {
                        return candidate
                    }
                }
            } else {
                // Pour les autres rounds, logique normale
                if !candidate.isEliminated && candidate.remainingTurn > 0 {
                    return candidate
                }
            }
            
        } while nextIndex != startIndex
        
        return nil
    }
    
    
    func setToNextPlayerIndex() {
        guard let nextPlayer = getNextPlayer(),
              let nextIndex = getPlayerIndex(player: nextPlayer) else { return }
        
        currentPlayerIndex = nextIndex
    }
    
    func isLastPlayer() -> Bool {
        return getNextPlayer() == nil
    }
    
    func resetPlayersForRound() {
        resetPlayersRoundScore()
        resetPlayersMainState()
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
    
    func resetPlayersMainState() {
        for player in players {
            player.isMainPlayer = false
            player.hasBeenMainPlayer = false
        }
    }
    
    func resetPlayerEliminated() {
        for player in players {
            player.isEliminated = false
        }
    }
    
    func resetPlayerCardPassed() {
        for player in players {
            player.currentTurnPassedCard = 0
        }
    }
    
    func setCurrentPlayerMain() {
        currentPlayer().isMainPlayer = true
        currentPlayer().hasBeenMainPlayer = true
    }
    
    func setMainPayerIsCurrentPLayer() {
        let playerIndex = getPlayerIndex(player: mainPlayer()!)
        currentPlayerIndex = playerIndex!
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
        timeManager.startTimer(
            duration: currentRound.config.timer, 
            onTimeUp: { [weak self] in
                self?.stopCriticalTicks() // Arrêter la boucle critique
                self?.logic.timerFinished()
            },
            onTick: { [weak self] timeRemaining in
                self?.playTimerTick(timeRemaining: timeRemaining)
                
                // Arrêter la boucle critique si on sort de la zone rouge
                if timeRemaining == 0 || timeRemaining > 5 {
                    self?.stopCriticalTicks()
                }
            }
        )
    }
    
    private func playTimerTick(timeRemaining: Int) {
        let totalTime = currentRound.config.timer
        let intensity = audioManager.calculateTickIntensity(timeRemaining: timeRemaining, totalTime: totalTime)
        let tickType = audioManager.getTimerTickType(timeRemaining: timeRemaining)
        
        switch tickType {
        case .normal:
            // Tic-tac simple
            audioManager.playTimerTick(intensity: intensity)
            
        case .urgent:
            // Double tic-tac pour zone orange
            audioManager.playDoubleTimerTick(intensity: intensity)
            
        case .critical:
            // Démarrer la boucle continue pour zone rouge (seulement au début)
            if timeRemaining == 5 {
                audioManager.startCriticalTickLoop(intensity: intensity)
            }
        }
    }
    
    // Arrêter la boucle critique quand nécessaire
    func stopCriticalTicks() {
        audioManager.stopCriticalTickLoop()
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
    
    func setCurrentPlayerCardToCards() {
        if let card = currentPlayer().personalCard {
            cardManager.setPlayerCard(card: card)
        }
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
        print("themes des joueurs : \(players.map {$0.personalCard?.theme.category ?? "aucun"})")
        print("Joueur main : \(String(describing: mainPlayer()?.name))" )
        print("dernier joueur du round : \(isLastPlayer())")
        print("-----------------------------")

    }
    
    
    
    
    
    
}
