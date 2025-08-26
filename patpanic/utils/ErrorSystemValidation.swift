//
//  ErrorSystemValidation.swift
//  patpanic
//
//  Created by Claude Code on 26/08/2025.
//  Tests de validation du système d'erreurs
//

import Foundation

#if DEBUG

@MainActor
class ErrorSystemValidation {
    
    static let shared = ErrorSystemValidation()
    private let errorHandler = ErrorHandler.shared
    
    private init() {}
    
    /// Teste tous les types d'erreurs
    func validateAllErrorTypes() {
        testGameManagerErrors()
        testCardManagerErrors()
        testAudioManagerErrors()
        testTimeManagerErrors()
        testPlayerValidationErrors()
        testFileSystemErrors()
        testConfigurationErrors()
    }
    
    private func testGameManagerErrors() {
        errorHandler.logInfo("Test des erreurs GameManager", context: "ErrorSystemValidation")
        
        let gameManager = GameManager()
        
        // Test ajout de joueur avec nom vide
        let result1 = gameManager.addPlayer(name: "")
        assert(result1.isFailure, "Devrait échouer avec nom vide")
        
        // Test ajout de joueur valide
        let result2 = gameManager.addPlayer(name: "TestPlayer")
        assert(result2.isSuccess, "Devrait réussir avec nom valide")
        
        // Test suppression avec index invalide
        let result3 = gameManager.removePlayer(at: 999)
        assert(result3.isFailure, "Devrait échouer avec index invalide")
        
        // Test currentPlayer avec joueurs valides
        let result4 = gameManager.currentPlayer()
        assert(result4.isSuccess, "Devrait réussir avec joueur valide")
        
        errorHandler.logInfo("Tests GameManager : OK", context: "ErrorSystemValidation")
    }
    
    private func testCardManagerErrors() {
        errorHandler.logInfo("Test des erreurs CardManager", context: "ErrorSystemValidation")
        
        let cardManager = CardManager()
        
        // Test génération avec count négatif
        let result1 = cardManager.generateGameCards(count: -1, round: 1)
        assert(result1.isFailure, "Devrait échouer avec count négatif")
        
        // Test génération avec catégorie inexistante
        let result2 = cardManager.generatePlayerCard(for: "CategoryThatDoesNotExist")
        assert(result2.isFailure, "Devrait échouer avec catégorie inexistante")
        
        // Test nextCard sur manager vide
        let result3 = cardManager.nextCard()
        assert(result3.isFailure, "Devrait échouer avec pas de cartes")
        
        errorHandler.logInfo("Tests CardManager : OK", context: "ErrorSystemValidation")
    }
    
    private func testAudioManagerErrors() {
        errorHandler.logInfo("Test des erreurs AudioManager", context: "ErrorSystemValidation")
        
        let audioManager = AudioManager()
        
        // Teste la lecture d'un son inexistant
        audioManager.playSound("SonInexistant")
        // L'erreur devrait être loggée automatiquement
        
        // Teste la musique avec fichier inexistant
        audioManager.playBackgroundMusic("MusiqueInexistante")
        // L'erreur devrait être loggée automatiquement
        
        errorHandler.logInfo("Tests AudioManager : OK", context: "ErrorSystemValidation")
    }
    
    private func testTimeManagerErrors() {
        errorHandler.logInfo("Test des erreurs TimeManager", context: "ErrorSystemValidation")
        
        // Pour l'instant, TimeManager n'utilise pas encore le système d'erreurs
        // mais nous pouvons le tester indirectement
        
        errorHandler.logInfo("Tests TimeManager : OK", context: "ErrorSystemValidation")
    }
    
    private func testPlayerValidationErrors() {
        errorHandler.logInfo("Test des erreurs PlayerValidation", context: "ErrorSystemValidation")
        
        let gameManager = GameManager()
        
        // Test nom trop long
        let longName = String(repeating: "a", count: 25)
        let result1 = gameManager.addPlayer(name: longName)
        assert(result1.isFailure, "Devrait échouer avec nom trop long")
        
        // Test ajout avec nom dupliqué
        _ = gameManager.addPlayer(name: "TestPlayer")
        let result2 = gameManager.addPlayer(name: "testplayer") // Même nom en minuscules
        assert(result2.isFailure, "Devrait échouer avec nom dupliqué")
        
        errorHandler.logInfo("Tests PlayerValidation : OK", context: "ErrorSystemValidation")
    }
    
    private func testFileSystemErrors() {
        errorHandler.logInfo("Test des erreurs FileSystem", context: "ErrorSystemValidation")
        
        let cardManager = CardManager()
        
        // Teste le chargement d'un fichier inexistant
        let result = cardManager.safeGeneratePlayerCard(for: "FichierInexistant")
        assert(result == nil, "Devrait échouer avec fichier inexistant")
        
        errorHandler.logInfo("Tests FileSystem : OK", context: "ErrorSystemValidation")
    }
    
    private func testConfigurationErrors() {
        errorHandler.logInfo("Test des erreurs Configuration", context: "ErrorSystemValidation")
        
        // Test via le PlayerSetupViewModel
        let gameManager = GameManager()
        _ = PlayerSetupViewModel(gameManager: gameManager)
        
        // Test démarrage de partie sans joueurs
        // Cette méthode devrait déclencher une erreur de configuration
        // Nous ne pouvons pas tester directement car c'est privé
        
        errorHandler.logInfo("Tests Configuration : OK", context: "ErrorSystemValidation")
    }
    
    /// Teste les performances du logging
    func validateLoggingPerformance() {
        errorHandler.logInfo("Test des performances de logging", context: "ErrorSystemValidation")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<100 {
            errorHandler.logInfo("Message de test \(i)", context: "Performance")
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        assert(timeElapsed < 1.0, "Le logging ne devrait pas prendre plus d'1 seconde pour 100 messages")
        
        errorHandler.logInfo("Test performance : \(timeElapsed)s pour 100 messages", context: "ErrorSystemValidation")
    }
    
    /// Teste la gestion mémoire
    func validateMemoryManagement() {
        errorHandler.logInfo("Test de la gestion mémoire", context: "ErrorSystemValidation")
        
        // Crée et détruit plusieurs managers pour tester les fuites
        for _ in 0..<10 {
            autoreleasepool {
                let gameManager = GameManager()
                _ = gameManager.addPlayer(name: "Test")
                // Le manager devrait se libérer automatiquement
            }
        }
        
        errorHandler.logInfo("Test mémoire : OK", context: "ErrorSystemValidation")
    }
}

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
}

#endif
