//
//  LeaderboardView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct LeaderboardView: View {
    
    @ObservedObject var gameManager: GameManager
    let isRoundEnd: Bool
    let onContinue: () -> Void
    let onCancel: () -> Void
        
    private var sortedPlayers: [Player] {
        // Tri par score total décroissant
        gameManager.players.sorted { $0.score > $1.score }
    }
    
    private var winner: Player? {
        sortedPlayers.first
    }
    
    var body: some View {
        ZStack {
            // Background gradient
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
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    CancelButton(action: onCancel)
                }.padding()
            
            
                // Header avec titre
                VStack(spacing: 20) {
                    if isRoundEnd {
                        GameTitle(
                            icon: "🏁",
                            title: "FIN DU ROUND \(gameManager.currentRound.rawValue)",
                            subtitle: "Classement temporaire"
                        )
                    } else {
                        GameTitle(
                            icon: "🏆",
                            title: "PARTIE TERMINÉE",
                            subtitle: "Classement final"
                        )
                    }
                    
                    // Podium spécial pour le gagnant si fin de partie
                    if !isRoundEnd, let winner = winner {
                        WinnerPodium(winner: winner)

                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Liste des joueurs classés
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                            LeaderboardRow(
                                player: player,
                                position: index + 1,
                                isWinner: !isRoundEnd && index == 0
                            )

                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                }
                
                Spacer()
                
                // Boutons d'action
                VStack(spacing: 16) {
                    if isRoundEnd && !gameManager.isLastRound() {
                        // Bouton pour continuer au round suivant
                        ButtonMenu(
                            action: onContinue,
                            title: "ROUND SUIVANT",
                            subtitle: nextRoundSubtitle,
                            icon: "arrow.right.circle.fill",
                            colors: [.green, .mint]
                        )
  
                        
                    } else if isRoundEnd && gameManager.isLastRound() {
                        // Bouton pour aller au classement final
                        ButtonMenu(
                            action: onContinue,
                            title: "CLASSEMENT FINAL",
                            subtitle: "Voir les résultats définitifs",
                            icon: "trophy.fill",
                            colors: [.yellow, .orange]
                        )
           
                        
                    } else {
                        // Fin de partie - Nouvelle partie
                        ButtonMenu(
                            action: onContinue,
                            title: "NOUVELLE PARTIE",
                            subtitle: "Recommencer avec les mêmes joueurs",
                            icon: "arrow.clockwise.circle.fill",
                            colors: [.blue, .purple]
                        )

                        
                    }
                
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        
    }
    
    private var nextRoundSubtitle: String {
        let nextRound = gameManager.currentRound.next
        switch nextRound {
        case .round2:
            return "Érudit comme un hibou 🦉"
        case .round3:
            return "Endurant comme une abeille 🐝"
        default:
            return "Prêt pour la suite ?"
        }
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
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> LeaderboardView {
        LeaderboardView(
            gameManager: gameManager,
            isRoundEnd: true,
            onContinue: onContinue,
            onCancel: onCancel
        )
    }
    
    // Vue pour fin de partie
    static func gameEnd(
        gameManager: GameManager,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> LeaderboardView {
        LeaderboardView(
            gameManager: gameManager,
            isRoundEnd: false,
            onContinue: onContinue,
            onCancel: onCancel
        )
    }
}

#Preview {
    // Création d'un GameManager de test
    let gameManager = GameManager()
    
    // Ajout de joueurs avec des scores
    gameManager.addPlayer(name: "Alice")
    gameManager.players[0].icon = "👩‍🔬"
    // Simulation de scores (normalement fait via les méthodes du Player)
    gameManager.players[0].validateTurn()
    gameManager.players[0].addTurnScore(45)
    gameManager.players[0].validateRound()
    
    gameManager.addPlayer(name: "Bob")
    gameManager.players[1].icon = "🧑‍🎨"
    gameManager.players[1].addTurnScore(38)
    gameManager.players[1].validateRound()
    
    gameManager.addPlayer(name: "Charlie")
    gameManager.players[2].icon = "👨‍🚀"
    gameManager.players[2].addTurnScore(52)
    gameManager.players[2].validateRound()
    
    gameManager.addPlayer(name: "Diana")
    gameManager.players[3].icon = "👩‍🎤"
    gameManager.players[3].addTurnScore(23)
    gameManager.players[3].validateRound()
    
     return VStack {
        LeaderboardView.gameEnd(
            gameManager: gameManager,
            onContinue: { print("Nouvelle partie") },
            onCancel: { print("Retour menu") }
        )
    }
}
