//
//  ContentView.swift
//  patpanic
//
//  Created by clement leclerc on 19/08/2025.
//

import SwiftUI

struct AppView: View {
    
    @StateObject private var gameManager = GameManager()

    var body: some View {
        switch ( gameManager.state) {
        case .playersSetup :
            PlayerSetupView(gameManager: gameManager)
        case .roundInstruction:
            InstructionView(onCancel: {}, onContinue: {}, gameManager: gameManager)
        default :
            PlayerSetupView(gameManager: gameManager)
        }
    }
}

#Preview {
    AppView()
}
