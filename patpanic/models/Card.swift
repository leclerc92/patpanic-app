//
//  Card.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import Foundation

class Card: Equatable {
    
    let theme: Theme
    
    init(theme: Theme) {
        self.theme = theme
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.theme.title == rhs.theme.title
        }
}
