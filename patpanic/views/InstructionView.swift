//
//  InstructionView.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import SwiftUI

struct InstructionView: View {
    
    let onCancel: () -> Void
    let onContinue: () -> Void
    @ObservedObject var gameManager: GameManager
    let roundConst: RoundConfig
    
    init(
        onCancel: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        gameManager: GameManager
    ) {
        self.onCancel = onCancel
        self.onContinue = onContinue
        self.gameManager = gameManager
        self.roundConst = gameManager.getCurrentRoundConfig()
    }
    
    var body: some View {
        ZStack {
            // Arrière-plan gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                
                HStack {
                    CancelButton(action: onCancel)
                    Spacer()
                }
                
                Spacer()
                
                GameTitle(
                    icon: nil,
                    title: "MANCHE \(gameManager.currentRound.rawValue)",
                    subtitle: nil
                )
                
                GameTitle(
                    icon: roundConst.icon,
                    title: roundConst.title,
                    subtitle: nil
                )
                
                Spacer()
                
                InstructionsSection(rules: roundConst.rules)
                    .padding()
                
                ButtonMenu.primaryButton(
                           title: "J'ai compris ! ",
                           subtitle: "Arrete don' le blabla !",
                           icon: "play.rectangle"
                       ) {
                           onContinue()
                }
                
                
            }.padding()
        }
        
        
    }
}

#Preview {
    InstructionView(
        onCancel: {
        },
        onContinue: {},
        gameManager: GameManager())
}
