import SwiftUI
import UIKit

struct PlayerSetupView: View {
    
    @ObservedObject var gameManager: GameManager
    @State private var newPlayerName = ""
    @State private var showingAlert = false
    @State private var showingConfigPlayer = false
    @State private var selectedPlayer: Player? = nil
    @State private var alertMessage = ""
    private let gameConst = GameConst()
    
    let configuration: BlurReplaceTransition.Configuration = .downUp

    var body: some View {
        ZStack {
            // Arrière-plan gradient moderne
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Section fixe du haut
                VStack(spacing: 20) {
                    // Titre fixe en haut
                    GameTitle(
                        icon: gameConst.GAMEICON,
                        title: gameConst.GAMETITLE,
                        subtitle: "Configuration des joueurs"
                    )
                    .padding(.top)
                    .fixedSize(horizontal: false, vertical: true)

                    // Section ajout de joueur fixe
                    GameInput.addPlayer(
                        content: $newPlayerName,
                        action: addPlayer
                    )
                    
                    // Section titre de la liste
                    HStack {
                        Text("👥")
                            .font(.title2)
                        Text("Joueurs inscrits (\(gameManager.players.count))")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // Zone scrollable pour la liste des joueurs uniquement
                if gameManager.players.isEmpty {
                    // État vide avec style
                    VStack(spacing: 12) {
                        Text("🎯")
                            .font(.system(size: 40))
                            .opacity(0.6)
                        
                        Text("Aucun joueur inscrit")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("Ajoutez au moins \(gameConst.MINPLAYERS) joueurs pour commencer")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    )
                    .padding(.horizontal)
                    .padding(.top, 10)
                } else {
                    // Liste scrollable des joueurs
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(gameManager.players.enumerated()), id: \.element.id) { index, player in
                                PlayerRowView(
                                    name: player.name,
                                    icon: player.icon,
                                    index: index + 1,
                                    theme: player.category,
                                    onConfig: {
                                        configurePlayer(at: index)
                                    },
                                    onDelete: {
                                        gameManager.removePlayer(at: index)
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                }
                
                // Section fixe du bas
                VStack(spacing: 0) {
                    // Dégradé pour séparer visuellement
                    LinearGradient(
                        colors: [Color.clear, Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)
                    
                    // Bouton commencer avec notre ButtonMenu
                    ButtonMenu(
                        action: startGame,
                        title:  "COMMENCER LA PARTIE",
                        subtitle: "Que le meilleur gagne !",
                        icon: "play.fill",
                        colors: gameManager.players.count >= gameConst.MINPLAYERS ? [.green, .mint] : [.gray.opacity(0.6), .gray.opacity(0.4)]
                    )
                    .disabled(gameManager.players.count < gameConst.MINPLAYERS)
                    .scaleEffect(gameManager.players.count >= gameConst.MINPLAYERS ? 1.0 : 0.98)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background(Color(.systemBackground))
                }
            }
        }
        .alert("Attention", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(item: $selectedPlayer) { player in
            PlayerConfigView(
                player: player, 
                onSave: { updatedPlayer in
                    gameManager.updatePlayer(newPlayer: updatedPlayer, player: player)
                },
                onClose: {
                    selectedPlayer = nil
                }
            )
        }
    }
    
    private func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Le nom du joueur ne peut pas être vide"
            showingAlert = true
            return
        }
        
        guard gameManager.players.count < 8 else {
            alertMessage = "Maximum 8 joueurs autorisés"
            showingAlert = true
            return
        }
        
        guard !gameManager.players.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            alertMessage = "Ce nom de joueur existe déjà"
            showingAlert = true
            return
        }
        
        // Animation d'ajout
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            gameManager.addPlayer(name: trimmedName)
        }
        
        // Réinitialiser le champ
        newPlayerName = ""
        
        // Vibration de succès
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func configurePlayer(at index: Int) {
        guard index < gameManager.players.count else { return }
        selectedPlayer = gameManager.players[index]
    }
    
    private func startGame() {
        guard gameManager.players.count >= gameConst.MINPLAYERS else {
            alertMessage = "Il faut au moins 2 joueurs pour commencer"
            showingAlert = true
            return
        }
        
        guard gameManager.allPlayersHaveCategory() else {
            let players = gameManager.getPlayersWithoutCategory()
            var names = ""
            for p in players {
                names.append(p + ", ")
            }
            let message = "Des joueurs n'ont pas de catégorie : " + names
            alertMessage = message
            showingAlert = true
            return
        }
        
        // Vibration de démarrage
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        gameManager.setState(state: .roundInstruction)
    }
}

#Preview {
    let config = GameManager()
    return PlayerSetupView(gameManager: config)
}
