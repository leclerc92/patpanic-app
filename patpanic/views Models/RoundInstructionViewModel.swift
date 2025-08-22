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
    private let onCancel: () -> Void
    private let onContinue: () -> Void
    
    // MARK: - Initialization
    init(gameManager: GameManager, onCancel: @escaping () -> Void, onContinue: @escaping () -> Void) {
        self.gameManager = gameManager
        self.onCancel = onCancel
        self.onContinue = onContinue
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
        onCancel()
    }
    
    func continueButton() {
        onContinue()
    }
}