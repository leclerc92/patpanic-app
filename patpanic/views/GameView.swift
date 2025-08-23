//
//  GameView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    
    init(gameManager: GameManager) {
        self._viewModel = StateObject(
            wrappedValue: GameViewModel(gameManager: gameManager)
        )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                titleAndTimerSection
                Spacer()
                playerSection
                cardSection
                Spacer()
                scoreSection
                Spacer()
                actionButtonsSection
            }.padding()
            
            // Overlay de pause
            if viewModel.showPauseOverlay {
                pauseOverlay
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onDisappear {
            viewModel.viewWillDisappear()
        }
        .sheet(isPresented: $viewModel.showInstructionsSheet) {
            RoundInstructionView(
                gameManager: viewModel.gameManager,
                needSetupRound: false,
                isDisplayedInSheet: true,
                onSheetDismiss: {
                    viewModel.showInstructionsSheet = false
                }
            )
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
    

    
    private var titleAndTimerSection: some View {
        VStack {
            HStack {
                GameTitle(
                    icon: nil,
                    title: viewModel.roundTitle,
                    subtitle: nil
                ).padding(.horizontal, 10)
                
                GameTimer(
                    timeRemaining: viewModel.timeRemaining,
                    totalTime: viewModel.totalTime
                )
                .scaleEffect(1.3)
            }
        }
        .padding(.bottom)
    }
    
    private var playerSection: some View {
        ZStack {
            // Effet de pulsation en arrière-plan pour Round 3
            if viewModel.isRound3 && viewModel.isPlayerNameEjecting {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .scaleEffect(viewModel.isPlayerNameEjecting ? 2.5 : 0.3)
                    .opacity(viewModel.isPlayerNameEjecting ? 0.8 : 0)
                    .animation(.interpolatingSpring(stiffness: 300, damping: 25), value: viewModel.isPlayerNameEjecting)
            }
            
            // Nom du joueur
            PlayerName(
                playerName: viewModel.currentPlayerName,
                icon: viewModel.currentPlayerIcon
            )
            .scaleEffect(
                viewModel.isRound3 ? 
                (viewModel.isPlayerNameEjecting ? 1.4 : 1.2) : 
                (viewModel.isPlayerNameEjecting ? 0.9 : 1.0)
            )
            .opacity(viewModel.isPlayerNameEjecting ? 0.3 : 1.0)
            .rotationEffect(.degrees(viewModel.isPlayerNameEjecting && viewModel.isRound3 ? 5 : 0))
            .blur(radius: viewModel.isPlayerNameEjecting && viewModel.isRound3 ? 2 : 0)
            .shadow(
                color: viewModel.isRound3 && viewModel.isPlayerNameEjecting ? .blue.opacity(0.8) : .clear,
                radius: viewModel.isPlayerNameEjecting ? 20 : 0,
                x: 0,
                y: 0
            )
        }
        .padding(.bottom, viewModel.isRound3 ? 35 : 20)
        .animation(.interpolatingSpring(stiffness: 400, damping: 30), value: viewModel.isPlayerNameEjecting)
    }
    
    private var cardSection: some View {
        Group {
            if let currentCard = viewModel.currentCard {
                GameCard(
                    theme: currentCard.theme,
                    size: viewModel.isRound3 ? .medium : .large,
                    isEjecting: viewModel.isRound3 ? false : viewModel.isCardEjecting,
                    onPause: viewModel.togglePause
                )
            } else {
                Text("Plus de cartes disponibles")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private var scoreSection: some View {
        ScoreDisplay(score: viewModel.currentPlayerScore)
            .padding(.top)
    }
    
    private var actionButtonsSection: some View {
        HStack {
            RoundButton.skipButton(action: viewModel.passCard)
                .padding(.horizontal, 50)
            RoundButton.validateButton(action: viewModel.validateCard)
                .padding(.horizontal, 50)
        }.padding()
    }
    
    private var pauseOverlay: some View {
        ZStack {
            // Fond semi-transparent
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {

                
                Spacer()
                
                // Phrase marrante
                Text("Alors on a besoin de débattre ?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Boutons d'action
                VStack(spacing: 20) {
                    
                    ButtonMenu.warningButton(
                        title: "Quitter le jeu",
                        subtitle: "Oh ba non pourquoi ?",
                        icon: "return"
                    ) {
                        viewModel.exitGame()
                    }.padding()
                    
                    // Bouton pour les instructions
                    ButtonMenu.secondaryButton(
                        title: "Instructions",
                        subtitle: "Rappel des règles",
                        icon: "book.fill"
                    ) {
                        viewModel.showInstructions()
                    }.padding()
                    
                    // Bouton pour reprendre
                    ButtonMenu.primaryButton(
                        title: "Reprendre",
                        subtitle: "Continuer la partie",
                        icon: "play.fill"
                    ) {
                        viewModel.resumeGame()
                    }.padding()
                    
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.8)), removal: .opacity.combined(with: .scale(scale: 1.1))))
        .animation(.interpolatingSpring(stiffness: 500, damping: 35), value: viewModel.showPauseOverlay)
    }
    
}

#Preview {
    let gameManager: GameManager = GameManager()
    gameManager.addPlayer(name: "Jean-Michel welbeck")
    
    // Créer une carte de test pour le preview
    let testTheme = Theme(category: "Test", title: "Animaux de compagnie", colorName: "blue")
    let testCard = Card(theme: testTheme)
    gameManager.cardManager.currentCard = testCard
    
    
    gameManager.logic.setupRound()
    
    return GameView(gameManager: gameManager)
}
