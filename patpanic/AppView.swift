//
//  ContentView.swift
//  patpanic
//
//  Created by clement leclerc on 19/08/2025.
//

import SwiftUI

struct AppView: View {
    
    let gameManager:GameManager = GameManager()
    
    
    var body: some View {
        PlayerSetupView(gameManager: gameManager)
    }
}

#Preview {
    AppView()
}
