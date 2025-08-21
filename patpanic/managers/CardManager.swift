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
    private var cachedThemes: [Theme]?
    private var cachedCategories: [CategoryData] = []
    
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
    
    private func loadAllThemes() -> [Theme] {
        if let cached = cachedThemes {
            return cached
        }
        
        var allThemes: [Theme] = []
        let categoryFiles = getAllCategoryFiles()
        
        for categoryFile in categoryFiles {
            if let themes = loadThemesFromCategory(filename: categoryFile) {
                allThemes.append(contentsOf: themes)
            }
        }
        
        cachedThemes = allThemes
        return allThemes
    }
        
    private func loadThemesFromCategory(filename: String) -> [Theme]? {
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json", subdirectory: "Categories"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Impossible de charger \(filename) dans Categories/")
            return nil
        }
        
        do {
            let categoryData = try JSONDecoder().decode(CategoryData.self, from: data)
            return categoryData.themes
        } catch {
            print("❌ Erreur décodage \(filename): \(error)")
            return nil
        }
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
        cachedThemes = nil
        cachedCategories.removeAll()
    }
    
    func getAvailableCategories() -> [String] {
        loadAllCategories()
        return cachedCategories.map { $0.category }
    }
    
    func getCategoryColor(for category: String) -> String {
        loadAllCategories()
        return cachedCategories.first { $0.category == category }?.color ?? "gray"
    }
    
    private func getAllCategoryFiles() -> [String] {
        guard let resourcePath = Bundle.main.resourcePath,
              let categoriesPath = Bundle.main.path(forResource: "Categories", ofType: nil) else {
            print("❌ Dossier Categories introuvable")
            return []
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: categoriesPath)
            return files.filter { $0.hasSuffix(".json") }
        } catch {
            print("❌ Erreur lecture dossier Categories: \(error)")
            return []
        }
    }
    
    private func loadAllCategories() {
        guard cachedCategories.isEmpty else { return }
        
        let categoryFiles = getAllCategoryFiles()
        
        for categoryFile in categoryFiles {
            if let categoryData = loadCategoryData(filename: categoryFile) {
                cachedCategories.append(categoryData)
            }
        }
    }
    
    private func loadCategoryData(filename: String) -> CategoryData? {
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json", subdirectory: "Categories"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Impossible de charger \(filename) dans Categories/")
            return nil
        }
        
        do {
            let categoryData = try JSONDecoder().decode(CategoryData.self, from: data)
            return categoryData
        } catch {
            print("❌ Erreur décodage \(filename): \(error)")
            return nil
        }
    }
    
    
}
