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

    
    init(gameManager:GameManager) {
        self.timerRound1 = 45
        self.timerRound2 = 30
        self.timerRound3 = 20
        self.gameManager = gameManager
        setupCategories()
    }
    
    private func setupCategories() {
        availableCategories = gameManager.getAvailableCategories()
        selectedCategories = Set(availableCategories)
    }
    
    func cancelButton() {
       
    }
    
    func validateButton() {
        
    }
    
    func discardButton() {
        
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


