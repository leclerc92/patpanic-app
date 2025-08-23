//
//  PlayerConfigViewModel.swift
//  patpanic
//
//  Created by clement leclerc on 22/08/2025.
//

import SwiftUI
import Combine

@MainActor
class PlayerConfigViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedIcon: String = "🕺"
    @Published var selectedCategory: String = ""
    @Published var showThemeEmptyError: Bool = false
    @Published var availableCategories: [String] = []
    @Published var hasPersonalCard: Bool = false
    @Published var playerName: String = ""
    
    // MARK: - Dependencies
    private var player: Player
    private let gameManager: GameManager
    private let onSave: (Player) -> Void
    private let onClose: () -> Void
    
    // MARK: - Constants
    let playerIcons = ["🕺", "💃", "🧑‍🎤", "🤵", "👸", "🧙‍♂️", "🧙‍♀️", "🦸‍♂️", "🦸‍♀️", "🤴", "👑", "🎭", "🎨", "🎯", "🚀", "⭐", "🔥", "💎", "🌟", "⚡"]
    
    // MARK: - Initialization
    init(player: Player, gameManager: GameManager, onSave: @escaping (Player) -> Void, onClose: @escaping () -> Void) {
        self.player = player
        self.gameManager = gameManager
        self.onSave = onSave
        self.onClose = onClose
        setupInitialData()
    }
    
    // MARK: - Setup
    private func setupInitialData() {
        selectedIcon = player.icon
        playerName = player.name
        hasPersonalCard = player.personalCard != nil
        availableCategories = gameManager.getAvailableCategories()
        
        // Configuration initiale de la catégorie
        if let personalCard = player.personalCard,
           availableCategories.contains(personalCard.theme.category) {
            selectedCategory = personalCard.theme.category
        } else if !availableCategories.isEmpty {
            selectedCategory = availableCategories.first ?? ""
        }
    }
    
    // MARK: - Actions
    func selectIcon(_ icon: String) {
        selectedIcon = icon
    }
    
    func selectCategory(_ category: String) {
        guard !hasPersonalCard else { return }
        selectedCategory = category
        if showThemeEmptyError {
            showThemeEmptyError = false
        }
    }
    
    func shuffleCategory() {
        guard !hasPersonalCard && !availableCategories.isEmpty else { return }
        
        // Sélectionne une catégorie aléatoire différente de l'actuelle si possible
        let otherCategories = availableCategories.filter { $0 != selectedCategory }
        let categoriesToChooseFrom = otherCategories.isEmpty ? availableCategories : otherCategories
        
        if let randomCategory = categoriesToChooseFrom.randomElement() {
            selectedCategory = randomCategory
        }
    }
    
    func saveConfiguration() {
        guard validateConfiguration() else { return }
        
        showThemeEmptyError = false
        player.icon = selectedIcon
        
        // Si le joueur a déjà une carte, on ne fait que sauvegarder l'icône
        if hasPersonalCard {
            onSave(player)
            onClose()
            return
        }
        
        // Génère la carte personnelle basée sur la catégorie sélectionnée
        if let personalCard = gameManager.generatePlayerCard(for: selectedCategory) {
            player.personalCard = personalCard
            onSave(player)
            onClose()
        } else {
            // Gestion d'erreur si aucune carte ne peut être générée
            print("❌ Impossible de générer une carte pour \(selectedCategory)")
            showThemeEmptyError = true
        }
    }
    
    func cancel() {
        onClose()
    }
    
    // MARK: - Helper Methods
    func colorForCategory(_ category: String) -> Color {
        let colorName = gameManager.getCategoryColor(for: category)
        
        switch colorName.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .gray
        }
    }
    
    func isIconSelected(_ icon: String) -> Bool {
        selectedIcon == icon
    }
    
    func isCategorySelected(_ category: String) -> Bool {
        selectedCategory == category
    }
    
    // MARK: - Computed Properties
    var categoryDisplayText: String {
        selectedCategory.isEmpty ? "Sélectionne une catégorie" : selectedCategory.capitalized
    }
    
    var categoryPreviewText: String {
        if hasPersonalCard {
            return "Ta carte secrète de \"\(selectedCategory.capitalized)\" est réservée pour la 3ème manche !"
        } else {
            return "Tu joueras avec les thèmes de \"\(selectedCategory.capitalized)\""
        }
    }
    
    var categoryLockText: String {
        hasPersonalCard ? "Ta catégorie est déjà définie !" : "Choisis ta spécialité pour la 3ème manche !"
    }
    
    var categoryLockColor: Color {
        hasPersonalCard ? .orange : .secondary
    }
    
    var previewTitleText: String {
        hasPersonalCard ? "Carte réservée" : "Aperçu"
    }
    
    var previewTextColor: Color {
        hasPersonalCard ? .orange : .secondary
    }
    
    // MARK: - Private Methods
    private func validateConfiguration() -> Bool {
        if selectedCategory.isEmpty {
            showThemeEmptyError = true
            return false
        }
        return true
    }
}
