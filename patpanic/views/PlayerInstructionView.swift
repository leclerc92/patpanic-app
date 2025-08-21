//
//  PlayerInstructionView.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct PlayerInstructionView: View {
    
    @ObservedObject var gameManager: GameManager
    let roundConst: RoundConfig
    let onCancel: () -> Void
    let onContinue: () -> Void
    let player: Player

    init(gameManager: GameManager, onCancel: @escaping () -> Void, onContinue: @escaping () -> Void) {
        self.gameManager = gameManager
        self.onCancel = onCancel
        self.onContinue = onContinue
        self.player = gameManager.currentPlayer()
        self.roundConst = gameManager.getCurrentRoundConfig()
    }
    
    var body: some View {
        ZStack {
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
                }
                .padding()
                
                PlayerName(playerName: player.name, icon: player.icon)
                
                GameTitle(icon: roundConst.icon, title: roundConst.title, subtitle: "Are you radis ? ")
                    .padding()
                
                
                HStack {
                    StatCard.turnsRemaining(count: player.remainingTurn,size: .compact)
                    //StatCard.roundScore(score: player.currentRoundScore, roundNumber: gameManager.currentRound.rawValue, size: .normal)
                    //StatCard.totalScore(score: player.score, size: .compact)
                   
                    StatCard.roundScore(score: 7, roundNumber: 2)
                    StatCard.totalScore(score: 30, size: .compact)
                }
                .padding()
                
                if let missionCard = missionCard {
                    missionCard.padding()
                }
                
                Spacer()
                
                ButtonMenu(
                    action: { },
                    title: "Petite mémoire ?",
                    subtitle: "Afficher les règles",
                    icon: "line.3.horizontal.button.angledtop.vertical.right",
                    colors: [Color.gray, Color.secondary]
                )
                .padding()
                
                ButtonMenu.primaryButton(
                           title: "Okaay let's gow !",
                           subtitle: "Detends toi la nouille ça commence vraiment ! ",
                           icon: "play.fill"
                       ) {
                           print("Nouvelle partie")
                       }.padding()
            }
            
            
        }
    }
    
    private var missionCard: MissionCard? {
        
        switch(gameManager.currentRound.rawValue) {
            case 1:
                return MissionCard.speedChallenge(timeLimit: roundConst.timer)
                
            case 2:
                let nb = gameManager.logic.getNbResponses()
                return MissionCard.giveWords(count: nb)
                
            case 3:
                return MissionCard.eliminate()
                
            default:
            return nil
        }
    }
    
}

#Preview {
    
    let gameManager:GameManager = GameManager()
    gameManager.addPlayer(name: "Michel")
    gameManager.nextRound()

    
     return PlayerInstructionView(
        gameManager: gameManager,
        onCancel: {},
        onContinue: {},
    )
}
