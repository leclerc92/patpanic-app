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
    
    private let errorHandler = ErrorHandler.shared
    
    @Published var cardManager: CardManager = CardManager()
    @Published var timeManager: TimeManager = TimeManager()
    @Published var audioManager: AudioManager = AudioManager()
    @Published var gameState: GameState = .playersSetup
    
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound:Round = .round1
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
        guard let player = safeCurrentPlayer() else {
            errorHandler.handle(.gameManager(.noPlayersFound), context: "GameManager.continueWithNextPlayer")
            return
        }
        
        player.validateTurn()
        setToNextPlayerIndex()
        goToPlayerInstructionView()
        logGameState()
    }
    
    func continueWithNextRound() {
        resetPlayersMainState()
        resetPlayerEliminated()
        resetPlayerCardPassed()
        
        let result = nextRound()
        if case .failure(let error) = result {
            errorHandler.handle(error, context: "GameManager.continueWithNextRound")
            return
        }
        
        currentPlayerIndex = 0
        goToRoundInstructionView(needSetupRound: true)
        logGameState()
    }
    
    func goToRoundInstructionView(needSetupRound:Bool) {
        gameState = .roundInstruction(needSetupRound: needSetupRound)
        logGameState()
    }
    
    func goToPlayerInstructionView() {
        gameState = .playerInstruction
        logGameState()
    }
    
    func goToPlayerResultView() {
        gameState = .playerTurnResult
        logGameState()
    }
    
    func goToRoundResult() {
        audioManager.playRoundResultSound()
        
        guard let player = safeCurrentPlayer() else {
            errorHandler.handle(.gameManager(.noPlayersFound), context: "GameManager.goToRoundResult")
            return
        }
        
        player.validateTurn()
        gameState = .roundResult
        logGameState()
    }
    
    func goToGameResult() {
        audioManager.playRoundResultSound()
        
        guard let player = safeCurrentPlayer() else {
            errorHandler.handle(.gameManager(.noPlayersFound), context: "GameManager.goToGameResult")
            return
        }
        
        player.validateTurn()
        gameState = .gameResult
        logGameState()
    }
        
    func endPlayerTurn () {
        logic.endPlayerTurn()
    }
    
    func setupRound() {
        logic.setupRound()
    }
    
    // MARK: - PLAYER FUNCTIONS
    
    
    func addPlayer(name: String) -> Result<Void, PatPanicError> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation du nom
        if trimmedName.isEmpty {
            return .failure(.playerValidation(.emptyName))
        }
        
        if trimmedName.count > 20 {
            return .failure(.playerValidation(.nameTooLong(maxLength: 20)))
        }
        
        if players.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            return .failure(.playerValidation(.duplicateName(name: trimmedName)))
        }
        
        if players.count >= 9 {
            return .failure(.playerValidation(.maxPlayersReached(maxPlayers: 9)))
        }
        
        let newPlayer = Player(name: trimmedName)
        players.append(newPlayer)
        errorHandler.logInfo("Joueur ajouté: \(trimmedName)", context: "GameManager.addPlayer")
        return .success(())
    }
    
    func removePlayer(at index: Int) -> Result<Void, PatPanicError> {
        guard index >= 0 && index < players.count else {
            return .failure(.gameManager(.invalidPlayerIndex(index: index, maxIndex: players.count - 1)))
        }
        
        let removedPlayer = players[index]
        players.remove(at: index)
        
        // Ajuster currentPlayerIndex si nécessaire
        if currentPlayerIndex >= players.count {
            currentPlayerIndex = max(0, players.count - 1)
        }
        
        errorHandler.logInfo("Joueur supprimé: \(removedPlayer.name)", context: "GameManager.removePlayer")
        return .success(())
    }
    
    func currentPlayer() -> Result<Player, PatPanicError> {
        guard !players.isEmpty else {
            return .failure(.gameManager(.noPlayersFound))
        }
        
        guard currentPlayerIndex >= 0 && currentPlayerIndex < players.count else {
            return .failure(.gameManager(.invalidPlayerIndex(index: currentPlayerIndex, maxIndex: players.count - 1)))
        }
        
        return .success(players[currentPlayerIndex])
    }
    
    func safeCurrentPlayer() -> Player? {
        return try? currentPlayer().get()
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
        guard let player = safeCurrentPlayer() else {
            errorHandler.handle(.gameManager(.noPlayersFound), context: "GameManager.addPointToCurrentPlayer")
            return
        }
        player.addTurnScore(nb)
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
        guard let player = safeCurrentPlayer() else {
            errorHandler.handle(.gameManager(.noPlayersFound), context: "GameManager.setCurrentPlayerMain")
            return
        }
        player.isMainPlayer = true
        player.hasBeenMainPlayer = true
    }
    
    func setMainPlayerIsCurrentPlayer() {
        guard let mainPlayer = mainPlayer(),
              let playerIndex = getPlayerIndex(player: mainPlayer) else {
            errorHandler.handle(.gameManager(.noPlayersFound), context: "GameManager.setMainPlayerIsCurrentPlayer")
            return
        }
        currentPlayerIndex = playerIndex
    }
    
    
    
    // MARK: - ROUNDS FUNCTIONS
    
 
    func getCurrentRoundConfig() -> RoundConfig {
        currentRound.config
    }
        
    func nextRound() -> Result<Void, PatPanicError> {
        guard let next = currentRound.next else {
            return .failure(.gameManager(.roundInitializationFailed(round: "Aucun round suivant disponible")))
        }
        
        currentRound = next
        let updateResult = updateLogicForCurrentRound()
        if case .failure(let error) = updateResult {
            return .failure(error)
        }
        
        errorHandler.logInfo("Passage au round \(currentRound.rawValue)", context: "GameManager.nextRound")
        return .success(())
    }
    
    private func updateLogicForCurrentRound() -> Result<Void, PatPanicError> {
        do {
            logic = RoundLogicFactory.createLogic(for: currentRound, gameManager: self)
            return .success(())
        } catch {
            return .failure(.gameManager(.roundInitializationFailed(round: String(currentRound.rawValue))))
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

        let result = cardManager.generateGameCards(
            count: cardsNeeded,
            category: nil, // Toutes les catégories
            round: roundNumber
        )
        
        result.handle(context: "GameManager.generateCardsForCurrentRound")
    }
    
    func generateCardsForCategory(_ category: String) {
        let roundNumber = getRoundNumber()
        let cardsNeeded = GameConst.CARDPERPLAYER * players.count
    
        let result = cardManager.generateGameCards(
            count: cardsNeeded,
            category: category,
            round: roundNumber
        )
        
        result.handle(context: "GameManager.generateCardsForCategory")
    }
    
    func getNextCard() -> Card? {
        return cardManager.safeNextCard()
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
        return cardManager.safeGeneratePlayerCard(for: category)
    }
    
    func setCurrentPlayerCardToCards() {
        if let card = safeCurrentPlayer()?.personalCard {
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

    private func logGameState() {
        let currentPlayerName = safeCurrentPlayer()?.name ?? "Aucun"
        let mainPlayerName = mainPlayer()?.name ?? "Aucun"
        
        let gameStateInfo = """
        État du jeu: \(gameState)
        Nombre de joueurs: \(players.count)
        Joueurs ont thème: \(allPlayersHaveCategory())
        Round actuel: \(currentRound)
        Cartes disponibles: \(cardManager.cards.count)
        Cartes utilisées: \(cardManager.usedCards.count)
        Joueur actuel: \(currentPlayerIndex) - \(currentPlayerName)
        Thèmes des joueurs: \(players.map {$0.personalCard?.theme.category ?? "aucun"})
        Joueur main: \(mainPlayerName)
        Dernier joueur du round: \(isLastPlayer())
        """
        
        errorHandler.logInfo(gameStateInfo, context: "GameManager.gameState")
    }
    
    
    
    
    
    
}
