import SwiftUI

struct LeaderboardRow: View {
    let player: Player
    let position: Int
    let isWinner: Bool
    
    @State private var animateScore = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Badge de position avec style spécial pour les 3 premiers
            PositionBadge(position: position, isWinner: isWinner)
            
            // Icône du joueur
            Text(player.icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(backgroundColorForPosition.opacity(0.1))
                )
                .shadow(color: backgroundColorForPosition.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Nom du joueur
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(positionText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Score total avec animation
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(player.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [backgroundColorForPosition, backgroundColorForPosition.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(animateScore ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: animateScore)
                
                Text("points")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .onAppear {
                // Animation du score à l'apparition
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(position) * 0.1) {
                    animateScore = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        animateScore = false
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: isWinner ? .yellow.opacity(0.3) : .black.opacity(0.05),
                    radius: isWinner ? 10 : 6,
                    x: 0,
                    y: isWinner ? 5 : 3
                )
        )
        .overlay(
            // Border spécial pour le gagnant
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isWinner ? LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: isWinner ? 2 : 0
                )
        )
        .scaleEffect(isWinner ? 1.02 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isWinner)
    }
    
    private var backgroundColorForPosition: Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color.orange
        default: return .blue
        }
    }
    
    private var positionText: String {
        switch position {
        case 1: return "🏆 Champion"
        case 2: return "🥈 Deuxième"
        case 3: return "🥉 Troisième"
        default: return "\(position)ème place"
        }
    }
}

struct PositionBadge: View {
    let position: Int
    let isWinner: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colorsForPosition,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isWinner ? 40 : 36, height: isWinner ? 40 : 36)
                .rotationEffect(.degrees(isWinner && isAnimating ? 360 : 0))
                .animation(
                    isWinner ? .easeInOut(duration: 2).repeatForever(autoreverses: false) : .none,
                    value: isAnimating
                )
            
            if position <= 3 {
                Text(emojiForPosition)
                    .font(.system(size: isWinner ? 18 : 16))
                    .scaleEffect(isWinner && isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            } else {
                Text("\(position)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .shadow(
            color: colorsForPosition.first?.opacity(0.4) ?? .clear,
            radius: isWinner ? 4 : 2,
            x: 0,
            y: 1
        )
        .onAppear {
            if isWinner {
                isAnimating = true
            }
        }
    }
    
    private var colorsForPosition: [Color] {
        switch position {
        case 1: return [.yellow, .orange]
        case 2: return [.gray, .black.opacity(0.6)]
        case 3: return [.orange, .red.opacity(0.8)]
        default: return [.blue, .purple]
        }
    }
    
    private var emojiForPosition: String {
        switch position {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
}

// Extension pour créer facilement des leaderboards
extension LeaderboardRow {
    
    // Ligne de gagnant avec tous les effets
    static func winner(player: Player) -> LeaderboardRow {
        LeaderboardRow(player: player, position: 1, isWinner: true)
    }
    
    // Ligne standard
    static func standard(player: Player, position: Int) -> LeaderboardRow {
        LeaderboardRow(player: player, position: position, isWinner: false)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
  
            VStack(spacing: 12) {
                LeaderboardRow.winner(
                    player: Player(name: "Champion")
                )
                
                LeaderboardRow.standard(
                    player: Player(name: "Joueur avec nom très long"),
                    position: 4
                )
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
