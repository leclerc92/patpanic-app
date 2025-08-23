//
//  RoundInstructionViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import SwiftUI
import Combine

@MainActor
class RoundInstructionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var roundNumber: String = ""
    @Published var roundIcon: String = ""
    @Published var roundTitle: String = ""
    @Published var roundRules: [String] = []
    
    // MARK: - Dependencies
    private let gameManager: GameManager

    
    // MARK: - Initialization
    init(gameManager: GameManager) {
        self.gameManager = gameManager

        setupData()
    }
    
    // MARK: - Setup
    private func setupData() {
        let roundConfig = gameManager.getCurrentRoundConfig()
        
        // Mise à jour des propriétés du round
        roundNumber = "MANCHE \(gameManager.currentRound.rawValue)"
        roundIcon = roundConfig.icon
        roundTitle = roundConfig.title
        roundRules = roundConfig.rules
    }
    
    // MARK: - Actions
    func cancelButton() {
        gameManager.resetGame()
    }
    
    func continueButton() {
        gameManager.goToPlayerInstructionView()
    }
    
    func viewDidAppear () {
        gameManager.setupRound()
    }
}
