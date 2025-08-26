//
//  ErrorSystem.swift
//  patpanic
//
//  Created by Claude Code on 26/08/2025.
//

import Foundation
import os

// MARK: - Error Types

enum PatPanicError: LocalizedError {
    case gameManager(GameManagerError)
    case cardManager(CardManagerError)
    case audioManager(AudioManagerError)
    case timeManager(TimeManagerError)
    case playerValidation(PlayerValidationError)
    case fileSystem(FileSystemError)
    case configuration(ConfigurationError)
    
    var errorDescription: String? {
        switch self {
        case .gameManager(let error):
            return "Erreur de jeu: \(error.localizedDescription)"
        case .cardManager(let error):
            return "Erreur de cartes: \(error.localizedDescription)"
        case .audioManager(let error):
            return "Erreur audio: \(error.localizedDescription)"
        case .timeManager(let error):
            return "Erreur de timer: \(error.localizedDescription)"
        case .playerValidation(let error):
            return "Erreur de joueur: \(error.localizedDescription)"
        case .fileSystem(let error):
            return "Erreur fichier: \(error.localizedDescription)"
        case .configuration(let error):
            return "Erreur configuration: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .gameManager(let error):
            return error.recoverySuggestion
        case .cardManager(let error):
            return error.recoverySuggestion
        case .audioManager(let error):
            return error.recoverySuggestion
        case .timeManager(let error):
            return error.recoverySuggestion
        case .playerValidation(let error):
            return error.recoverySuggestion
        case .fileSystem(let error):
            return error.recoverySuggestion
        case .configuration(let error):
            return error.recoverySuggestion
        }
    }
}

// MARK: - Specific Error Types

enum GameManagerError: LocalizedError {
    case invalidPlayerIndex(index: Int, maxIndex: Int)
    case noPlayersFound
    case gameStateTransitionError(from: String, to: String)
    case roundInitializationFailed(round: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidPlayerIndex(let index, let maxIndex):
            return "Index de joueur invalide (\(index)). Index maximum autorisé: \(maxIndex)"
        case .noPlayersFound:
            return "Aucun joueur trouvé dans la partie"
        case .gameStateTransitionError(let from, let to):
            return "Transition d'état impossible: \(from) → \(to)"
        case .roundInitializationFailed(let round):
            return "Échec d'initialisation du round \(round)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidPlayerIndex:
            return "Vérifiez que les joueurs sont correctement initialisés"
        case .noPlayersFound:
            return "Ajoutez au moins un joueur avant de commencer"
        case .gameStateTransitionError:
            return "Redémarrez la partie ou contactez le support"
        case .roundInitializationFailed:
            return "Redémarrez le round ou la partie"
        }
    }
}

enum CardManagerError: LocalizedError {
    case categoryNotFound(category: String)
    case noCardsAvailable
    case fileLoadingFailed(filename: String)
    case jsonDecodingFailed(filename: String, reason: String)
    
    var errorDescription: String? {
        switch self {
        case .categoryNotFound(let category):
            return "Catégorie '\(category)' introuvable"
        case .noCardsAvailable:
            return "Aucune carte disponible"
        case .fileLoadingFailed(let filename):
            return "Impossible de charger le fichier '\(filename)'"
        case .jsonDecodingFailed(let filename, let reason):
            return "Erreur de décodage JSON pour '\(filename)': \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .categoryNotFound:
            return "Vérifiez les catégories disponibles ou réinitialisez"
        case .noCardsAvailable:
            return "Rechargez les cartes ou changez de catégorie"
        case .fileLoadingFailed:
            return "Vérifiez que le fichier existe dans le bundle"
        case .jsonDecodingFailed:
            return "Vérifiez le format du fichier JSON"
        }
    }
}

enum AudioManagerError: LocalizedError {
    case audioSessionSetupFailed(reason: String)
    case soundFileNotFound(soundName: String)
    case audioPlayerCreationFailed(soundName: String, reason: String)
    case backgroundMusicFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .audioSessionSetupFailed(let reason):
            return "Échec configuration audio: \(reason)"
        case .soundFileNotFound(let soundName):
            return "Fichier son '\(soundName)' introuvable"
        case .audioPlayerCreationFailed(let soundName, let reason):
            return "Impossible de créer le lecteur pour '\(soundName)': \(reason)"
        case .backgroundMusicFailed(let reason):
            return "Échec musique de fond: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .audioSessionSetupFailed:
            return "Redémarrez l'app ou vérifiez les permissions audio"
        case .soundFileNotFound:
            return "Vérifiez que le fichier son existe dans le bundle"
        case .audioPlayerCreationFailed:
            return "Le fichier audio est peut-être corrompu"
        case .backgroundMusicFailed:
            return "Continuez sans musique ou redémarrez l'app"
        }
    }
}

enum TimeManagerError: LocalizedError {
    case timerCreationFailed
    case invalidDuration(duration: Int)
    case timerAlreadyRunning
    
    var errorDescription: String? {
        switch self {
        case .timerCreationFailed:
            return "Impossible de créer le timer"
        case .invalidDuration(let duration):
            return "Durée invalide: \(duration) secondes"
        case .timerAlreadyRunning:
            return "Un timer est déjà en cours d'exécution"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .timerCreationFailed:
            return "Redémarrez la partie"
        case .invalidDuration:
            return "Utilisez une durée positive"
        case .timerAlreadyRunning:
            return "Arrêtez le timer actuel avant d'en démarrer un nouveau"
        }
    }
}

enum PlayerValidationError: LocalizedError {
    case emptyName
    case nameTooLong(maxLength: Int)
    case duplicateName(name: String)
    case maxPlayersReached(maxPlayers: Int)
    case invalidPlayerConfiguration
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Le nom du joueur ne peut pas être vide"
        case .nameTooLong(let maxLength):
            return "Le nom du joueur ne peut pas dépasser \(maxLength) caractères"
        case .duplicateName(let name):
            return "Le nom '\(name)' est déjà utilisé"
        case .maxPlayersReached(let maxPlayers):
            return "Nombre maximum de joueurs atteint (\(maxPlayers))"
        case .invalidPlayerConfiguration:
            return "Configuration du joueur invalide"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .emptyName:
            return "Saisissez un nom pour le joueur"
        case .nameTooLong:
            return "Raccourcissez le nom du joueur"
        case .duplicateName:
            return "Choisissez un nom différent"
        case .maxPlayersReached:
            return "Supprimez un joueur existant pour en ajouter un nouveau"
        case .invalidPlayerConfiguration:
            return "Vérifiez les paramètres du joueur"
        }
    }
}

enum FileSystemError: LocalizedError {
    case fileNotFound(path: String)
    case fileNotReadable(path: String)
    case invalidFileFormat(path: String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Fichier introuvable: \(path)"
        case .fileNotReadable(let path):
            return "Fichier illisible: \(path)"
        case .invalidFileFormat(let path):
            return "Format de fichier invalide: \(path)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Vérifiez que le fichier existe dans l'app"
        case .fileNotReadable:
            return "Vérifiez les permissions du fichier"
        case .invalidFileFormat:
            return "Utilisez un fichier au bon format"
        }
    }
}

enum ConfigurationError: LocalizedError {
    case invalidConfiguration(key: String)
    case missingConfiguration(key: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let key):
            return "Configuration invalide pour la clé: \(key)"
        case .missingConfiguration(let key):
            return "Configuration manquante pour la clé: \(key)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidConfiguration:
            return "Vérifiez la valeur de configuration"
        case .missingConfiguration:
            return "Ajoutez la configuration manquante"
        }
    }
}

// MARK: - Error Handler

@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    private let logger = Logger(subsystem: "com.patpanic.app", category: "ErrorHandler")
    
    @Published var currentError: PatPanicError?
    @Published var showErrorAlert = false
    
    private init() {}
    
    func handle(_ error: PatPanicError, context: String = "") {
        logger.error("🚨 \(error.localizedDescription) | Context: \(context)")
        
        Task { @MainActor in
            self.currentError = error
            self.showErrorAlert = true
        }
    }
    
    func handle(_ error: Error, context: String = "") {
        if let patPanicError = error as? PatPanicError {
            handle(patPanicError, context: context)
        } else {
            logger.error("🚨 Erreur système: \(error.localizedDescription) | Context: \(context)")
            
            let wrappedError = PatPanicError.configuration(.invalidConfiguration(key: "SystemError"))
            Task { @MainActor in
                self.currentError = wrappedError
                self.showErrorAlert = true
            }
        }
    }
    
    func logInfo(_ message: String, context: String = "") {
        logger.info("ℹ️ \(message) | Context: \(context)")
    }
    
    func logWarning(_ message: String, context: String = "") {
        logger.warning("⚠️ \(message) | Context: \(context)")
    }
    
    func clearCurrentError() {
        currentError = nil
        showErrorAlert = false
    }
}

// MARK: - Result Extension

extension Result where Failure == PatPanicError {
    @MainActor func handle(context: String = "") {
        switch self {
        case .success:
            break
        case .failure(let error):
            ErrorHandler.shared.handle(error, context: context)
        }
    }
}
