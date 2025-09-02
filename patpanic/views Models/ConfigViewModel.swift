//
//  ConfigViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 28/08/2025.
//

import Foundation
import SwiftUI

@MainActor
class ConfigViewModel: ObservableObject {
    
    @Published var timerRound1: Int
    @Published var timerRound2: Int
    @Published var timerRound3: Int
    @Published var selectedCategories: Set<String> = []
    @Published var availableCategories: [String] = []
    @Published var showCategoryDropdown: Bool = false
    
    private let gameManager: GameManager
    private let settingsManager = GameSettingsManager.shared

    
    init(gameManager:GameManager) {
        self.gameManager = gameManager
        
        // Charger les paramètres sauvegardés
        let settings = settingsManager.currentSettings
        self.timerRound1 = settings.timerRound1
        self.timerRound2 = settings.timerRound2
        self.timerRound3 = settings.timerRound3
        
        setupCategories()
        
        // Si aucune catégorie sauvegardée, sélectionner toutes par défaut
        if settings.selectedCategories.isEmpty {
            selectedCategories = Set(availableCategories)
        } else {
            selectedCategories = settings.selectedCategories
        }
    }
    
    private func setupCategories() {
        availableCategories = gameManager.getAvailableCategories()
    }
    
    func cancelButton() {
        // Fonction vide, la fermeture est gérée par dismiss() dans la vue
    }
    
    func validateButton() {
        // Sauvegarder tous les paramètres
        settingsManager.updateTimers(
            round1: timerRound1,
            round2: timerRound2,
            round3: timerRound3
        )
        settingsManager.updateSelectedCategories(selectedCategories)
        
        // La fermeture est gérée par dismiss() dans la vue
    }
    
    func discardButton() {
        // Restaurer les paramètres sauvegardés
        let settings = settingsManager.currentSettings
        timerRound1 = settings.timerRound1
        timerRound2 = settings.timerRound2
        timerRound3 = settings.timerRound3
        
        if settings.selectedCategories.isEmpty {
            selectedCategories = Set(availableCategories)
        } else {
            selectedCategories = settings.selectedCategories
        }
    }
    
    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            // Empêcher de désélectionner si c'est la dernière catégorie
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
            }
        } else {
            selectedCategories.insert(category)
        }
    }
    
    func isCategorySelected(_ category: String) -> Bool {
        return selectedCategories.contains(category)
    }
    
    func selectAllCategories() {
        selectedCategories = Set(availableCategories)
    }
    
    func deselectAllCategories() {
        // Garder au minimum 1 catégorie sélectionnée
        if !availableCategories.isEmpty {
            selectedCategories = Set([availableCategories.first!])
        }
    }
    
    var selectedCategoriesCount: Int {
        return selectedCategories.count
    }
    
    var totalCategoriesCount: Int {
        return availableCategories.count
    }
    
    func colorForCategory(_ category: String) -> Color {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow, .mint, .cyan, .indigo]
        let index = abs(category.hashValue) % colors.count
        return colors[index]
    }
    
    func toggleDropdown() {
        showCategoryDropdown.toggle()
    }
    
    func closeDropdown() {
        showCategoryDropdown = false
    }
    
    func canDeselectCategory(_ category: String) -> Bool {
        return selectedCategories.count > 1 || !selectedCategories.contains(category)
    }
    
}


