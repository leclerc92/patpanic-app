//
//  CardManager.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//  Modernized for iOS 26 with @Observable
//

import Foundation
import Observation

struct CategoryData: Codable {
    let category: String
    let color: String
    let themes: [Theme]
}

/// Modern card manager using @Observable (iOS 26)
@MainActor
@Observable
final class CardManager {

    // MARK: - Observable State

    private(set) var cards: [Card] = []
    private(set) var usedCards: [Card] = []
    var currentCard: Card?

    // MARK: - Private Properties

    private let errorHandler = ErrorHandler.shared
    private var cachedThemes: [Theme] = []
    private var cachedCategories: [CategoryData] = []
    private var isInitialized = false

    // MARK: - Initialization

    init() {
        initializeCategories()
    }

    // MARK: - Card Generation

    func generateGameCards(count: Int, category: String? = nil, round: Int) -> Result<Void, PatPanicError> {
        guard count > 0 else {
            return .failure(.cardManager(.noCardsAvailable))
        }

        cards.removeAll()

        // 1. Charger tous les thèmes
        let allThemes = loadAllThemes()
        guard !allThemes.isEmpty else {
            return .failure(.cardManager(.noCardsAvailable))
        }

        // 2. Filtrer par round
        let availableThemes = allThemes.filter { $0.isAvailableForRound(round) }

        // 3. Filtrer par catégorie si spécifiée
        let filteredThemes: [Theme]
        if let category = category {
            filteredThemes = availableThemes.filter { matchesCategory($0.category, category) }
            if filteredThemes.isEmpty {
                return .failure(.cardManager(.categoryNotFound(category: category)))
            }
        } else {
            // Utiliser les catégories sélectionnées dans les paramètres
            let selectedCategories = GameSettingsHelper.getSelectedCategories()

            if selectedCategories.isEmpty {
                // Si aucune catégorie sélectionnée, utiliser toutes
                filteredThemes = availableThemes
            } else {
                // Filtrer par catégories sélectionnées
                filteredThemes = availableThemes.filter { theme in
                    selectedCategories.contains { matchesCategory(theme.category, $0) }
                }
            }
        }

        // 4. Créer les cartes en excluant les usedCards
        let allPossibleCards = filteredThemes.map { Card(theme: $0) }
        let availableCards = allPossibleCards.filter { !usedCards.contains($0) }

        guard !availableCards.isEmpty else {
            return .failure(.cardManager(.noCardsAvailable))
        }

        // 5. Mélanger et prendre le nombre demandé
        let shuffled = availableCards.shuffled()
        cards = Array(shuffled.prefix(count))

        let actualCount = min(count, availableCards.count)
        errorHandler.logInfo("\(actualCount) cartes générées pour le round \(round)", context: "CardManager.generateGameCards")

        return .success(())
    }

    func setPlayerCard(card: Card) {
        cards.removeAll()
        cards.append(card)
    }

    func generatePlayerCard(for category: String) -> Result<Card, PatPanicError> {
        let categoryThemes = filterThemesByCategory(category)

        guard !categoryThemes.isEmpty else {
            return .failure(.cardManager(.categoryNotFound(category: category)))
        }

        // Thèmes pas exclus du round 3 et qui ne sont pas déjà utilisés
        let availableThemes = categoryThemes.filter { $0.isAvailableForRound(3) }
            .filter { theme in
                !usedCards.contains { $0.theme.title == theme.title }
            }

        guard let randomTheme = availableThemes.randomElement() else {
            return .failure(.cardManager(.noCardsAvailable))
        }

        let personalCard = Card(theme: randomTheme)
        usedCards.append(personalCard)

        errorHandler.logInfo("Carte personnelle générée pour \(category): \(randomTheme.title)", context: "CardManager.generatePlayerCard")
        return .success(personalCard)
    }

    func safeGeneratePlayerCard(for category: String) -> Card? {
        return try? generatePlayerCard(for: category).get()
    }

    // MARK: - Card Management

    func nextCard() -> Result<Card, PatPanicError> {
        // Si plus de cartes, recycle les cartes utilisées
        if cards.isEmpty {
            recycleUsedCards()
        }

        guard !cards.isEmpty else {
            return .failure(.cardManager(.noCardsAvailable))
        }

        let card = cards.removeFirst()
        currentCard = card
        usedCards.append(card)
        return .success(card)
    }

    func safeNextCard() -> Card? {
        return try? nextCard().get()
    }

    func resetUsedCards() {
        usedCards.removeAll()
    }

    func resetAll() {
        cards.removeAll()
        usedCards.removeAll()
        currentCard = nil
    }

    // MARK: - Category Management

    func getAvailableCategories() -> [String] {
        return cachedCategories.map { $0.category }
    }

    func getCategoryColor(for category: String) -> String {
        return cachedCategories.first { matchesCategory($0.category, category) }?.color ?? "gray"
    }

    func reloadThemes() {
        cachedThemes.removeAll()
        cachedCategories.removeAll()
        isInitialized = false
        initializeCategories()
    }

    // MARK: - Private Initialization

    private func initializeCategories() {
        guard !isInitialized else { return }

        let knownCategories = [
            "alimentation", "animaux", "divertissement", "geographie",
            "intime", "langues", "litterature", "marques", "metiers", "mode",
            "musique", "mythologie", "nature", "nombres", "objets",
            "personnages", "politique", "sport", "religion", "four-tout", "petit et grand écran", "art", "automne"
        ]

        var loadedCategories = 0
        var failedCategories: [String] = []

        for categoryName in knownCategories {
            switch loadCategoryData(filename: "\(categoryName).json") {
            case .success(let categoryData):
                cachedCategories.append(categoryData)
                cachedThemes.append(contentsOf: categoryData.themes)
                loadedCategories += 1
            case .failure:
                failedCategories.append(categoryName)
            }
        }

        if !failedCategories.isEmpty {
            errorHandler.logWarning("Échec de chargement des catégories: \(failedCategories.joined(separator: ", "))", context: "CardManager.initializeCategories")
        }

        errorHandler.logInfo("\(loadedCategories) catégories chargées avec succès", context: "CardManager.initializeCategories")
        isInitialized = true
    }

    private func loadCategoryData(filename: String) -> Result<CategoryData, PatPanicError> {
        let resourceName = filename.replacingOccurrences(of: ".json", with: "")

        // Essayons d'abord avec le subdirectory
        var url = Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: "Resources/Categories")

        // Si pas trouvé, essayons sans subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: resourceName, withExtension: "json")
        }

        guard let finalURL = url else {
            return .failure(.cardManager(.fileLoadingFailed(filename: filename)))
        }

        do {
            let data = try Data(contentsOf: finalURL)
            let categoryData = try JSONDecoder().decode(CategoryData.self, from: data)
            return .success(categoryData)
        } catch let decodingError as DecodingError {
            return .failure(.cardManager(.jsonDecodingFailed(filename: filename, reason: decodingError.localizedDescription)))
        } catch {
            return .failure(.fileSystem(.fileNotReadable(path: finalURL.path)))
        }
    }

    // MARK: - Private Helpers

    private func loadAllThemes() -> [Theme] {
        return cachedThemes
    }

    private func recycleUsedCards() {
        guard usedCards.count > 1 else { return }

        // Garde la dernière carte jouée pour éviter de retomber dessus immédiatement
        let lastPlayedCard = usedCards.last!

        // Remet toutes les cartes sauf la dernière, mélangées
        cards = usedCards.dropLast().shuffled()
        usedCards = [lastPlayedCard]

        errorHandler.logInfo("Cartes recyclées: \(cards.count) cartes remises en jeu (dernière carte exclue)", context: "CardManager.recycleUsedCards")
    }

    /// Compare deux catégories de manière insensible à la casse (DRY helper)
    private func matchesCategory(_ category1: String, _ category2: String) -> Bool {
        return category1.lowercased() == category2.lowercased()
    }

    /// Filtre les thèmes par catégorie (DRY helper)
    private func filterThemesByCategory(_ category: String) -> [Theme] {
        return cachedThemes.filter { matchesCategory($0.category, category) }
    }
}
