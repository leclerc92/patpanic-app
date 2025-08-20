//
//  CardManager.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

class CardManager {
    
    private(set) var cards: [Card] = []
    private(set) var usedCards: [Card] = []
    var currentCard:Card?
    private var cachedThemes: [Theme]?
    
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
            for categoryFile in ["voyage", "alimentation", "sport", "musique"] {
                if let themes = loadThemes(from: "\(categoryFile).json") {
                    allThemes.append(contentsOf: themes)
                }
            }
            
            cachedThemes = allThemes  // ✨ Mise en cache
            return allThemes
    }
        
    private func loadThemes(from filename: String) -> [Theme]? {
            guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                print("❌ Impossible de charger \(filename)")
                return nil
            }
            
            do {
                let themes = try JSONDecoder().decode([Theme].self, from: data)
                return themes
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
    }
    
    
}
