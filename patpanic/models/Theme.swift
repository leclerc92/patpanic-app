//
//  Theme.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation
import SwiftUICore

class Theme {
    
    let category: String
    let title: String
    let color: Color
    let excludedRounds: [Int]
    
    init(category: String, title: String, color: Color, excludedRounds: [Int]) {
        self.category = category
        self.title = title
        self.color = color
        self.excludedRounds = excludedRounds
    }
    
    func isAvailableForRound(_ round: Int) -> Bool {
            return !excludedRounds.contains(round)
    }
}
