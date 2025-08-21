//
//  CardManager.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

struct CategoryData: Codable {
    let category: String
    let color: String
    let themes: [Theme]
}

class CardManager: ObservableObject {
    
    @Published private(set) var cards: [Card] = []
    @Published private(set) var usedCards: [Card] = []
    @Published var currentCard: Card?
    private var cachedThemes: [Theme] = []
    private var cachedCategories: [CategoryData] = []
    private var isInitialized = false
    
    init() {
        initializeCategories()
    }
    
    func generateGameCards(count: Int, category: String? = nil, round: Int) {
            cards.removeAll()
            
            // 1. Charger tous les thèmes
            let allThemes = loadAllThemes()
            
            // 2. Filtrer par round
            let availableThemes = allThemes.filter { $0.isAvailableForRound(round) }
            
            // 3. Filtrer par catégorie si spécifiée
            let filteredThemes: [Theme]
            if let category = category {
                filteredThemes = availableThemes.filter { $0.category == category }
            } else {
                filteredThemes = availableThemes
            }
            
            // 4. Créer les cartes en excluant les usedCards
            let allPossibleCards = filteredThemes.map { Card(theme: $0) }
            let availableCards = allPossibleCards.filter { !usedCards.contains($0) }
            
            // 5. Mélanger et prendre le nombre demandé
            let shuffled = availableCards.shuffled()
            cards = Array(shuffled.prefix(count))
        }
    
    private func initializeCategories() {
        guard !isInitialized else { return }
        
        print("🔄 Initialisation des catégories...")
        let knownCategories = [
            "alimentation", "animaux", "divertissement", "festivals", "geographie",
            "intime", "langues", "litterature", "marques", "metiers", "mode",
            "musique", "mythologie", "nature", "nombres", "objets", 
            "personnages", "politique", "sport"
        ]
        
        for categoryName in knownCategories {
            if let categoryData = loadCategoryData(filename: "\(categoryName).json") {
                cachedCategories.append(categoryData)
                cachedThemes.append(contentsOf: categoryData.themes)
            }
        }
        
        isInitialized = true
    }
    
    private func loadAllThemes() -> [Theme] {
        return cachedThemes
    }
        
    
    func nextCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        
        let card = cards.removeFirst()
        currentCard = card
        usedCards.append(card)
        return card
    }
    
    func resetUsedCards() {
            usedCards.removeAll()
    }
        
    func resetAll() {
            cards.removeAll()
            usedCards.removeAll()
            currentCard = nil
    }
    
    func reloadThemes() {
        cachedThemes.removeAll()
        cachedCategories.removeAll()
        isInitialized = false
        initializeCategories()
    }
    
    func getAvailableCategories() -> [String] {
        return cachedCategories.map { $0.category }
    }
    
    func getCategoryColor(for category: String) -> String {
        return cachedCategories.first { $0.category.lowercased() == category.lowercased() }?.color ?? "gray"
    }
    
    // Génère une carte personnelle pour un joueur basée sur une catégorie
    func generatePlayerCard(for category: String) -> Card? {
        // Trouve les thèmes de cette catégorie
        let categoryThemes = cachedThemes.filter { 
            $0.category.lowercased() == category.lowercased() 
        }
        
        // Filtre les thèmes qui ne sont pas déjà utilisés
        let availableThemes = categoryThemes.filter { theme in
            !usedCards.contains { $0.theme.title == theme.title }
        }
        
        guard let randomTheme = availableThemes.randomElement() else {
            print("❌ Aucun thème disponible pour la catégorie \(category)")
            return nil
        }
        
        // Crée la carte personnelle
        let personalCard = Card(theme: randomTheme)
        
        // L'ajoute immédiatement aux cartes utilisées
        usedCards.append(personalCard)
        
        print("✅ Carte personnelle générée: '\(personalCard.theme.title)' (\(category))")
        return personalCard
    }
    
    
    private func loadCategoryData(filename: String) -> CategoryData? {
        let resourceName = filename.replacingOccurrences(of: ".json", with: "")
        
        // Essayons d'abord avec le subdirectory
        var url = Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: "Resources/Categories")
        
        // Si pas trouvé, essayons sans subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: resourceName, withExtension: "json")
        }
        
        guard let finalURL = url else {
            print("❌ Impossible de trouver \(resourceName).json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: finalURL)
            let categoryData = try JSONDecoder().decode(CategoryData.self, from: data)
            return categoryData
        } catch {
            print("❌ Erreur décodage \(filename): \(error)")
            return nil
        }
    }
    
    
}
