//
//  PlayerSetupViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import SwiftUI
import UIKit

@MainActor
class PlayerSetupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var newPlayerName: String = ""
    @Published var showingAlert: Bool = false
    @Published var showingConfigPlayer: Bool = false
    @Published var selectedPlayer: Player?
    @Published var alertMessage: String = ""
    @Published var showingGameConfig: Bool = false

    // MARK: - Dependencies
    let gameManager: GameManager  // Expose pour PlayerConfigView

    // MARK: - Computed Properties (from GameManager @Observable)
    var players: [Player] {
        gameManager.players
    }

    var canStartGame: Bool {
        players.count >= GameConst.MINPLAYERS
    }

    // MARK: - Initialization
    init(gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    // MARK: - Public Methods
    func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)

        let result = gameManager.addPlayer(name: trimmedName)

        switch result {
        case .success:
            // Animation d'ajout
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                // Le joueur a déjà été ajouté par gameManager.addPlayer
            }

            // Réinitialiser le champ
            newPlayerName = ""

            // Fermer le clavier d'abord
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

            // Attendre que le clavier se ferme avant d'ouvrir la sheet
            // Délai de 300ms pour éviter le conflit keyboard/sheet qui freeze l'UI
            let lastIndex = players.count - 1
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                configurePlayer(at: lastIndex)
            }

        case .failure(_):
            // L'erreur sera automatiquement gérée par l'ErrorHandler
            break
        }
    }
    
    func configurePlayer(at index: Int) {
        guard index < players.count else { return }
        selectedPlayer = players[index]
    }
    
    func removePlayer(at index: Int) {
        let result = gameManager.removePlayer(at: index)
        result.handle(context: "PlayerSetupViewModel.removePlayer")
    }
    
    func updatePlayer(_ updatedPlayer: Player, originalPlayer: Player) {
        gameManager.updatePlayer(newPlayer: updatedPlayer, player: originalPlayer)
    }
    
    func startGame() {
        guard validateGameStart() else { return }
        
        // Vibration de démarrage
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        gameManager.goToRoundInstructionView(needSetupRound: true)
        
    }
    
    func closePlayerConfig() {
        selectedPlayer = nil
    }
    
    func openGameConfig() {
        showingGameConfig = true
    }
    
    func closeGameConfig() {
        showingGameConfig = false
    }
    
    func dismissAlert() {
        showingAlert = false
    }
    
    func viewDidAppear() {
        
        /*gameManager.addPlayer(name: "C")
        gameManager.addPlayer(name: "V")
        let cardc = Card(theme: Theme(category: "alimentation", title: "c", colorName: "blue", excludedRounds: []))
        let cardv = Card(theme: Theme(category: "alimentation", title: "v", colorName: "blue", excludedRounds: []))
        gameManager.players[0].personalCard = cardc
        gameManager.players[1].personalCard = cardv
        */
    }
    
    // MARK: - Computed Properties
    var gameTitle: String {
        GameConst.GAMETITLE
    }
    
    var gameIcon: String {
        GameConst.GAMEICON
    }
    
    var minPlayers: Int {
        GameConst.MINPLAYERS
    }
    
    var playersCount: Int {
        players.count
    }
    
    var isEmpty: Bool {
        players.isEmpty
    }
    
    var startButtonColors: [Color] {
        canStartGame ? [.green, .mint] : [.gray.opacity(0.6), .gray.opacity(0.4)]
    }
    
    var startButtonScale: Double {
        canStartGame ? 1.0 : 0.98
    }
    
    // MARK: - Private Methods
    // Supprimé car la validation est maintenant dans GameManager
    
    private func validateGameStart() -> Bool {
        guard players.count >= GameConst.MINPLAYERS else {
            ErrorHandler.shared.handle(.playerValidation(.invalidPlayerConfiguration), context: "PlayerSetupViewModel.validateGameStart")
            return false
        }
        
        guard gameManager.allPlayersHaveCategory() else {
            let playersWithoutCategory = gameManager.getPlayersWithoutCategory()
            let names = playersWithoutCategory.joined(separator: ", ")
            ErrorHandler.shared.handle(.configuration(.missingConfiguration(key: "Catégories joueurs: \(names)")), context: "PlayerSetupViewModel.validateGameStart")
            return false
        }
        
        return true
    }
    
    // Supprimé car les erreurs sont maintenant gérées par ErrorHandler
}
