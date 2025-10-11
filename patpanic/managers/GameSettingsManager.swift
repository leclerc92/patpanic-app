//
//  GameSettingsManager.swift
//  patpanic
//
//  Created by clement leclerc on 28/08/2025.
//  Modernized for iOS 26 with @Observable
//

import Foundation
import Observation

struct GameSettings {
    var timerRound1: Int
    var timerRound2: Int
    var timerRound3: Int
    var selectedCategories: Set<String>

    static var `default`: GameSettings {
        GameSettings(
            timerRound1: 45,
            timerRound2: 30,
            timerRound3: 20,
            selectedCategories: []
        )
    }
}

/// Modern game settings manager using @Observable (iOS 26)
@MainActor
@Observable
final class GameSettingsManager {
    static let shared = GameSettingsManager()

    // MARK: - Observable State

    private(set) var currentSettings: GameSettings

    // MARK: - Private Properties

    private let userDefaults = UserDefaults.standard

    // MARK: - Constants

    /// Keys pour UserDefaults (partagées via nonisolated pour GameSettingsHelper)
    nonisolated(unsafe) static let keys = Keys()

    struct Keys {
        let timerRound1 = "game_timer_round1"
        let timerRound2 = "game_timer_round2"
        let timerRound3 = "game_timer_round3"
        let selectedCategories = "game_selected_categories"

        // Valeurs par défaut
        let defaultTimerRound1 = 45
        let defaultTimerRound2 = 30
        let defaultTimerRound3 = 20
    }

    private var keys: Keys { Self.keys }

    // MARK: - Initialization

    private init() {
        self.currentSettings = GameSettings.default
        loadSettings()
    }

    // MARK: - Settings Management
    
    func loadSettings() {
        let timerRound1 = loadTimer(forKey: keys.timerRound1, default: keys.defaultTimerRound1)
        let timerRound2 = loadTimer(forKey: keys.timerRound2, default: keys.defaultTimerRound2)
        let timerRound3 = loadTimer(forKey: keys.timerRound3, default: keys.defaultTimerRound3)

        let categoriesArray = userDefaults.array(forKey: keys.selectedCategories) as? [String] ?? []
        let selectedCategories = Set(categoriesArray)

        currentSettings = GameSettings(
            timerRound1: timerRound1,
            timerRound2: timerRound2,
            timerRound3: timerRound3,
            selectedCategories: selectedCategories
        )
    }

    func saveSettings(_ settings: GameSettings) {
        currentSettings = settings

        userDefaults.set(settings.timerRound1, forKey: keys.timerRound1)
        userDefaults.set(settings.timerRound2, forKey: keys.timerRound2)
        userDefaults.set(settings.timerRound3, forKey: keys.timerRound3)
        userDefaults.set(Array(settings.selectedCategories), forKey: keys.selectedCategories)
    }

    func updateTimers(round1: Int, round2: Int, round3: Int) {
        var newSettings = currentSettings
        newSettings.timerRound1 = round1
        newSettings.timerRound2 = round2
        newSettings.timerRound3 = round3
        saveSettings(newSettings)
    }

    func updateSelectedCategories(_ categories: Set<String>) {
        var newSettings = currentSettings
        newSettings.selectedCategories = categories
        saveSettings(newSettings)
    }

    func getTimerForRound(_ round: Round) -> Int {
        switch round {
        case .round1:
            return currentSettings.timerRound1
        case .round2:
            return currentSettings.timerRound2
        case .round3:
            return currentSettings.timerRound3
        }
    }

    func resetToDefaults() {
        saveSettings(GameSettings.default)
    }

    // MARK: - Private Helpers

    private func loadTimer(forKey key: String, default defaultValue: Int) -> Int {
        return userDefaults.object(forKey: key) as? Int ?? defaultValue
    }
}

// MARK: - Non-Actor Helper

/// Fonctions utilitaires non-actor pour accès synchrone depuis des contextes non-UI
struct GameSettingsHelper {
    private static let keys = GameSettingsManager.keys
    private static let userDefaults = UserDefaults.standard

    static func getTimerForRound(_ round: Round) -> Int {
        switch round {
        case .round1:
            return loadTimer(forKey: keys.timerRound1, default: keys.defaultTimerRound1)
        case .round2:
            return loadTimer(forKey: keys.timerRound2, default: keys.defaultTimerRound2)
        case .round3:
            return loadTimer(forKey: keys.timerRound3, default: keys.defaultTimerRound3)
        }
    }

    static func getSelectedCategories() -> Set<String> {
        let categoriesArray = userDefaults.array(forKey: keys.selectedCategories) as? [String] ?? []
        return Set(categoriesArray)
    }

    private static func loadTimer(forKey key: String, default defaultValue: Int) -> Int {
        return userDefaults.object(forKey: key) as? Int ?? defaultValue
    }
}