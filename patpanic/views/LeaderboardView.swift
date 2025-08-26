//
//  LeaderboardView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel: LeaderboardViewModel
    
    init(gameManager: GameManager, isRoundEnd: Bool) {
        self._viewModel = StateObject(
            wrappedValue: LeaderboardViewModel(
                gameManager: gameManager,
                isRoundEnd: isRoundEnd,
            )
        )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerSection
                titleSection
                leaderboardSection
                Spacer()
                actionButtonSection
            }
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
            Spacer()
            CancelButton(action: viewModel.cancelButton)
        }.padding()
    }
    
    private var titleSection: some View {
        VStack(spacing: 20) {
            GameTitle(
                icon: viewModel.titleIcon,
                title: viewModel.titleText,
                subtitle: viewModel.titleSubtitle
            )
            
            // Podium spécial pour le gagnant si fin de partie
            if viewModel.showWinnerPodium, let winner = viewModel.winner {
                WinnerPodium(winner: winner)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    private var leaderboardSection: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    LeaderboardRow(
                        player: player,
                        position: index + 1,
                        isWinner: viewModel.isWinner(at: index)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 30)
        }
    }
    
    private var actionButtonSection: some View {
        VStack(spacing: 16) {
            ButtonMenu(
                action: viewModel.continueButton,
                title: viewModel.buttonTitle,
                subtitle: viewModel.buttonSubtitle,
                icon: viewModel.buttonIcon,
                colors: viewModel.buttonColors
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
}

// MARK: - Podium du gagnant

struct WinnerPodium: View {
    let winner: Player
    
    var body: some View {
        VStack(spacing: 20) {
            // Confettis animés
            HStack {
                ForEach(0..<5) { _ in
                    Text(["🎉", "🎊", "⭐", "🏆", "👑"].randomElement() ?? "🎉")
                        .font(.title)

                }
            }
            
            // Podium du gagnant
            VStack(spacing: 12) {
                // Couronne
                Text("👑")
                    .font(.system(size: 40))

                
                // Avatar du joueur
                Text(winner.icon)
                    .font(.system(size: 50))
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 15, x: 0, y: 5)
                
                // Nom du gagnant
                VStack(spacing: 4) {
                    Text(winner.name)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("CHAMPION!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(2)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .yellow.opacity(0.3), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
            )
        }
    }
}

// MARK: - Extensions pour faciliter l'utilisation

extension LeaderboardView {
    
    // Vue pour fin de round
    static func roundEnd(
        gameManager: GameManager,

    ) -> LeaderboardView {
        LeaderboardView(
            gameManager: gameManager,
            isRoundEnd: true,

        )
    }
    
    // Vue pour fin de partie
    static func gameEnd(
        gameManager: GameManager,

    ) -> LeaderboardView {
        LeaderboardView(
            gameManager: gameManager,
            isRoundEnd: false,

        )
    }
}

#Preview {
    // Création d'un GameManager de test
    let gameManager = GameManager()
    
    // Ajout de joueurs avec des scores
    _ = gameManager.addPlayer(name: "Alice")
    gameManager.players[0].icon = "👩‍🔬"
    // Simulation de scores (normalement fait via les méthodes du Player)
    gameManager.players[0].addTurnScore(45)
    gameManager.players[0].validateTurn()

    
    _ = gameManager.addPlayer(name: "Bob")
    gameManager.players[1].icon = "🧑‍🎨"
    gameManager.players[1].addTurnScore(38)
    gameManager.players[1].validateTurn()

    _ = gameManager.addPlayer(name: "Charlie")
    gameManager.players[2].icon = "👨‍🚀"
    gameManager.players[2].addTurnScore(52)
    gameManager.players[2].validateTurn()

    _ = gameManager.addPlayer(name: "Diana")
    gameManager.players[3].icon = "👩‍🎤"
    gameManager.players[3].addTurnScore(23)
    gameManager.players[3].validateTurn()

     return VStack {
        LeaderboardView.roundEnd(
            gameManager: gameManager
        )
    }
}
