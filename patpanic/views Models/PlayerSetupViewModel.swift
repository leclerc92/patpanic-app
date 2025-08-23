//
//  PlayerSetupViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import SwiftUI
import UIKit
import Combine

@MainActor
class PlayerSetupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var newPlayerName: String = ""
    @Published var showingAlert: Bool = false
    @Published var showingConfigPlayer: Bool = false
    @Published var selectedPlayer: Player?
    @Published var alertMessage: String = ""
    @Published var players: [Player] = []
    @Published var canStartGame: Bool = false
    
    // MARK: - Dependencies
    let gameManager: GameManager  // Expose pour PlayerConfigView
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        setupBindings()
        updateGameState()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Observer les changements de joueurs
        gameManager.$players
            .sink { [weak self] players in
                self?.players = players
                self?.updateGameState()
            }
            .store(in: &cancellables)
    }
    
    private func updateGameState() {
        canStartGame = players.count >= GameConst.MINPLAYERS
    }
    
    // MARK: - Public Methods
    func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard validatePlayerName(trimmedName) else { return }
        
        // Animation d'ajout
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            gameManager.addPlayer(name: trimmedName)
        }
        
        // Réinitialiser le champ
        newPlayerName = ""
        
        // Ouvrir la configuration pour le dernier joueur ajouté
        let lastIndex = players.count - 1
        configurePlayer(at: lastIndex)
    }
    
    func configurePlayer(at index: Int) {
        guard index < players.count else { return }
        selectedPlayer = players[index]
    }
    
    func removePlayer(at index: Int) {
        gameManager.removePlayer(at: index)
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
    
    func dismissAlert() {
        showingAlert = false
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
    private func validatePlayerName(_ name: String) -> Bool {
        guard !name.isEmpty else {
            showError("Le nom du joueur ne peut pas être vide")
            return false
        }
        
        guard players.count < 8 else {
            showError("Maximum 8 joueurs autorisés")
            return false
        }
        
        guard !players.contains(where: { $0.name.lowercased() == name.lowercased() }) else {
            showError("Ce nom de joueur existe déjà")
            return false
        }
        
        return true
    }
    
    private func validateGameStart() -> Bool {
        guard players.count >= GameConst.MINPLAYERS else {
            showError("Il faut au moins 2 joueurs pour commencer")
            return false
        }
        
        guard gameManager.allPlayersHaveCategory() else {
            let playersWithoutCategory = gameManager.getPlayersWithoutCategory()
            let names = playersWithoutCategory.joined(separator: ", ")
            showError("Des joueurs n'ont pas de catégorie : " + names)
            return false
        }
        
        return true
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}
