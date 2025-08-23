import SwiftUI
import UIKit

struct PlayerSetupView: View {
    @StateObject private var viewModel: PlayerSetupViewModel
    
    let configuration: BlurReplaceTransition.Configuration = .downUp
    
    init(gameManager: GameManager) {
        self._viewModel = StateObject(
            wrappedValue: PlayerSetupViewModel(
                gameManager: gameManager,
            )
        )
    }

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
                        icon: viewModel.gameIcon,
                        title: viewModel.gameTitle,
                        subtitle: "Configuration des joueurs"
                    )
                    .padding(.top)
                    .fixedSize(horizontal: false, vertical: true)

                    // Section ajout de joueur fixe
                    GameInput.addPlayer(
                        content: $viewModel.newPlayerName,
                        action: viewModel.addPlayer
                    )
                    
                    // Section titre de la liste
                    HStack {
                        Text("👥")
                            .font(.title2)
                        Text("Joueurs inscrits (\(viewModel.playersCount))")
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
                if viewModel.isEmpty {
                    // État vide avec style
                    VStack(spacing: 12) {
                        Text("🎯")
                            .font(.system(size: 40))
                            .opacity(0.6)
                        
                        Text("Aucun joueur inscrit")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("Ajoutez au moins \(viewModel.minPlayers) joueurs pour commencer")
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
                            ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                                PlayerRowView(
                                    name: player.name,
                                    icon: player.icon,
                                    index: index + 1,
                                    theme: player.personalCard?.theme.category,
                                    onConfig: {
                                        viewModel.configurePlayer(at: index)
                                    },
                                    onDelete: {
                                        viewModel.removePlayer(at: index)
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
                        action: viewModel.startGame,
                        title:  "COMMENCER LA PARTIE",
                        subtitle: "Que le meilleur gagne !",
                        icon: "play.fill",
                        colors: viewModel.startButtonColors
                    )
                    .disabled(!viewModel.canStartGame)
                    .scaleEffect(viewModel.startButtonScale)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background(Color(.systemBackground))
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .alert("Attention", isPresented: $viewModel.showingAlert) {
            Button("OK") { viewModel.dismissAlert() }
        } message: {
            Text(viewModel.alertMessage)
        }
        .sheet(item: $viewModel.selectedPlayer) { player in
            PlayerConfigView(
                player: player,
                gameManager: viewModel.gameManager,
                onSave: { updatedPlayer in
                    viewModel.updatePlayer(updatedPlayer, originalPlayer: player)
                },
                onClose: {
                    viewModel.closePlayerConfig()
                }
            )
        }
        .onAppear(){
            
            
            viewModel.gameManager.addPlayer(name: "C")
            viewModel.gameManager.addPlayer(name: "V")
            let cardc = Card(theme: Theme(category: "alimentation", title: "c", colorName: "blue", excludedRounds: []))
            let cardv = Card(theme: Theme(category: "alimentation", title: "v", colorName: "blue", excludedRounds: []))
            viewModel.gameManager.players[0].personalCard = cardc
            viewModel.gameManager.players[1].personalCard = cardv
             
             
        }
    }
    
}

#Preview {
    let config = GameManager()
    return PlayerSetupView(gameManager: config)
}
