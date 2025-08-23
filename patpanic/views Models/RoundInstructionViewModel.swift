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
    @Published var needSetupRound: Bool
    @Published var isDisplayedInSheet: Bool
    
    // MARK: - Dependencies
    private let gameManager: GameManager
    private let onSheetDismiss: (() -> Void)?

    
    // MARK: - Initialization
    init(gameManager: GameManager, needSetupRound: Bool, isDisplayedInSheet: Bool = false, onSheetDismiss: (() -> Void)? = nil) {
        self.gameManager = gameManager
        self.needSetupRound = needSetupRound
        self.isDisplayedInSheet = isDisplayedInSheet
        self.onSheetDismiss = onSheetDismiss
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
        if isDisplayedInSheet {
            onSheetDismiss?()
        } else {
            gameManager.resetGame()
        }
    }
    
    func continueButton() {
        if isDisplayedInSheet {
            // Si affiché en sheet, fermer le sheet
            onSheetDismiss?()
        } else {
            // Comportement normal : aller vers playerInstruction
            gameManager.goToPlayerInstructionView()
        }
    }
    
    func viewDidAppear () {
        if needSetupRound {
            gameManager.setupRound()
        }
    }
}
