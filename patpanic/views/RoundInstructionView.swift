//
//  InstructionView.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import SwiftUI

struct RoundInstructionView: View {
    @StateObject private var viewModel: RoundInstructionViewModel
    
    init(
        onCancel: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        gameManager: GameManager
    ) {
        self._viewModel = StateObject(
            wrappedValue: RoundInstructionViewModel(
                gameManager: gameManager,
                onCancel: onCancel,
                onContinue: onContinue
            )
        )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack {
                headerSection
                Spacer()
                roundTitleSection
                gameInstructionsSection
                Spacer()
                instructionsSection
                continueButton
            }.padding()
        }
    }
    
    // MARK: - View Components
    private var backgroundGradient: some View {
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
    }
    
    private var headerSection: some View {
        HStack {
            CancelButton(action: viewModel.cancelButton)
            Spacer()
        }
    }
    
    private var roundTitleSection: some View {
        GameTitle(
            icon: nil,
            title: viewModel.roundNumber,
            subtitle: nil
        )
    }
    
    private var gameInstructionsSection: some View {
        GameTitle(
            icon: viewModel.roundIcon,
            title: viewModel.roundTitle,
            subtitle: nil
        )
    }
    
    private var instructionsSection: some View {
        InstructionsSection(rules: viewModel.roundRules)
            .padding()
    }
    
    private var continueButton: some View {
        ButtonMenu.primaryButton(
            title: "J'ai compris !",
            subtitle: "Arrete don' le blabla !",
            icon: "play.rectangle"
        ) {
            viewModel.continueButton()
        }
    }
}

#Preview {
    RoundInstructionView(
        onCancel: {
        },
        onContinue: {},
        gameManager: GameManager())
}
