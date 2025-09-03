//
//  GameSettingsManager.swift
//  patpanic
//
//  Created by clement leclerc on 28/08/2025.
//

import Foundation

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

@MainActor
class GameSettingsManager: ObservableObject {
    static let shared = GameSettingsManager()
    
    @Published private(set) var currentSettings: GameSettings
    
    private let userDefaults = UserDefaults.standard
    
    // Keys pour UserDefaults
    private enum Keys {
        static let timerRound1 = "game_timer_round1"
        static let timerRound2 = "game_timer_round2"
        static let timerRound3 = "game_timer_round3"
        static let selectedCategories = "game_selected_categories"
    }
    
    private init() {
        self.currentSettings = GameSettings.default
        loadSettings()
    }
    
    func loadSettings() {
        let timerRound1 = userDefaults.object(forKey: Keys.timerRound1) as? Int ?? 45
        let timerRound2 = userDefaults.object(forKey: Keys.timerRound2) as? Int ?? 30
        let timerRound3 = userDefaults.object(forKey: Keys.timerRound3) as? Int ?? 20
        
        let categoriesArray = userDefaults.array(forKey: Keys.selectedCategories) as? [String] ?? []
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
        
        userDefaults.set(settings.timerRound1, forKey: Keys.timerRound1)
        userDefaults.set(settings.timerRound2, forKey: Keys.timerRound2)
        userDefaults.set(settings.timerRound3, forKey: Keys.timerRound3)
        userDefaults.set(Array(settings.selectedCategories), forKey: Keys.selectedCategories)
        
        userDefaults.synchronize()
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
}

// Fonctions utilitaires non-actor pour accès synchrone depuis des contextes non-UI
struct GameSettingsHelper {
    static func getTimerForRound(_ round: Round) -> Int {
        let userDefaults = UserDefaults.standard
        
        switch round {
        case .round1:
            return userDefaults.object(forKey: "game_timer_round1") as? Int ?? 45
        case .round2:
            return userDefaults.object(forKey: "game_timer_round2") as? Int ?? 30
        case .round3:
            return userDefaults.object(forKey: "game_timer_round3") as? Int ?? 20
        }
    }
    
    static func getSelectedCategories() -> Set<String> {
        let userDefaults = UserDefaults.standard
        let categoriesArray = userDefaults.array(forKey: "game_selected_categories") as? [String] ?? []
        return Set(categoriesArray)
    }
}