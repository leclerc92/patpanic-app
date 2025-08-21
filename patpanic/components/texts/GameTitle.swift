import SwiftUI

struct GameTitle: View {
    
    let icon: String?
    let title: String
    let subtitle: String?
    
    @State private var animateGradient = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: 40))
                        .fontWidth(.expanded)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                }
    
                Text(title)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: animateGradient ?
                                [.pink, .blue, .purple] :
                                [.blue, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(2)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

// Extensions pour différents styles de titres
extension GameTitle {
    
    // Titre principal du jeu
    static func main(subtitle: String? = nil) -> GameTitle {
        GameTitle(
            icon: "🎲",
            title: "PAT'PANIC",
            subtitle: subtitle
        )
    }
    
    // Titre de victoire
    static func victory() -> GameTitle {
        GameTitle(
            icon: "🏆",
            title: "VICTOIRE!",
            subtitle: "Félicitations !"
        )
    }
    
    // Titre de défaite
    static func endTurn() -> GameTitle {
        GameTitle(
            icon: "⏱️",
            title: "FIN DU TOUR",
            subtitle: "kéksadi ?"
        )
    }
    
    // Titre de nouvelle partie
    static func newGame() -> GameTitle {
        GameTitle(
            icon: "🚀",
            title: "NOUVELLE PARTIE",
            subtitle: "C'est parti !"
        )
    }
    
    // Titre des scores
    static func highScores() -> GameTitle {
        GameTitle(
            icon: "📊",
            title: "MEILLEURS SCORES",
            subtitle: "Hall of Fame"
        )
    }
    
    // Titre des paramètres
    static func settings() -> GameTitle {
        GameTitle(
            icon: "⚙️",
            title: "PARAMÈTRES",
            subtitle: "Configuration"
        )
    }
}

// Version avec animation de pulsation pour les moments importants
struct AnimatedGameTitle: View {
    let gameTitle: GameTitle
    @State private var isPulsing = false
    
    var body: some View {
        gameTitle
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

#Preview {
    VStack(spacing: 40) {
        // Titre principal
        GameTitle.main(subtitle: "Interdit aux paniqueurs !")
        
        Divider()
        
        // Autres exemples
        GameTitle.victory()
        
        GameTitle.newGame()
        
        GameTitle.highScores()
        
        // Version animée
        AnimatedGameTitle(
            gameTitle: GameTitle.main(subtitle: "Version animée")
        )
        
        // Titre personnalisé
        GameTitle(
            icon: "🎯",
            title: "DÉFI RAPIDE",
            subtitle: "60 secondes !"
        )
        
        // Test avec un titre très long
        GameTitle(
            icon: "📱",
            title: "TITRE TRÈS TRÈS LONG POUR TESTER",
            subtitle: "Sous-titre également très long pour vérifier l'adaptation"
        )
        
        Spacer()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
