import SwiftUI

struct MissionCard: View {
    let icon: String
    let mission: String
    let details: String?
    let colors: [Color]
    let style: MissionStyle
    
    @State private var pulseAnimation = false
    @State private var shimmerOffset: CGFloat = -200
    
    enum MissionStyle {
        case normal, urgent, bonus, challenge
        
        var borderWidth: CGFloat {
            switch self {
            case .normal: return 0
            case .urgent: return 2
            case .bonus: return 2
            case .challenge: return 2
            }
        }
        
        var shouldPulse: Bool {
            switch self {
            case .normal: return false
            case .urgent: return true
            case .bonus: return true
            case .challenge: return false
            }
        }
    }
    
    init(
        icon: String,
        mission: String,
        details: String? = nil,
        colors: [Color] = [.blue, .cyan],
        style: MissionStyle = .normal
    ) {
        self.icon = icon
        self.mission = mission
        self.details = details
        self.colors = colors
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // En-tête avec icône
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 20))
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Text("MISSION")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                Spacer()
            }
            
            // Texte principal de la mission
            VStack(spacing: 4) {
                Text(mission)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let details = details {
                    Text(details)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Fond principal
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                
                // Effet shimmer pour style bonus
                if style == .bonus {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .clipped()
                }
                
                // Bordure selon le style
                if style.borderWidth > 0 {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: style.borderWidth
                        )
                }
            }
        )
        .shadow(color: colors.first?.opacity(0.2) ?? .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .scaleEffect(pulseAnimation && style.shouldPulse ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
        .onAppear {
            if style.shouldPulse {
                pulseAnimation = true
            }
            
            if style == .bonus {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                    shimmerOffset = 200
                }
            }
        }
    }
}

// MARK: - Extensions pour différents types de missions

extension MissionCard {
    
    // Mission standard - donner des mots
    static func giveWords(
        count: Int,
    ) -> MissionCard {
        MissionCard(
            icon: "💭",
            mission: "Donne \(count) réponses pour la carte affichée !",
            details: "Passer la carte te fais perdre tous tes points..",
            colors: [.blue, .cyan],
            style: .normal
        )
    }
    
    // Mission d'élimination
    static func eliminate(
        target: String = "le plus d'adversaires"
    ) -> MissionCard {
        MissionCard(
            icon: "⚔️",
            mission: "Élimine \(target) !",
            details: "Sois le plus rapide et précis",
            colors: [.red, .orange],
            style: .challenge
        )
    }
    
    // Mission de rapidité
    static func speedChallenge(
        timeLimit: Int
    ) -> MissionCard {
        MissionCard(
            icon: "⚡",
            mission: "Donne deux réponses par carte !",
            details: "Chaque seconde compte, tu as \(timeLimit) secondes !",
            colors: [.yellow, .orange],
            style: .urgent
        )
    }
    
    // Mission bonus
    static func bonusRound(
        reward: String
    ) -> MissionCard {
        MissionCard(
            icon: "⭐",
            mission: "ROUND BONUS !",
            details: reward,
            colors: [.purple, .pink],
            style: .bonus
        )
    }
    
    // Mission de précision
    static func precision(
        requirement: String
    ) -> MissionCard {
        MissionCard(
            icon: "🎯",
            mission: "Sois précis !",
            details: requirement,
            colors: [.green, .mint],
            style: .normal
        )
    }
    
    // Mission de défense
    static func defend() -> MissionCard {
        MissionCard(
            icon: "🛡️",
            mission: "Défends ta position !",
            details: "Ne laisse personne te dépasser",
            colors: [.indigo, .blue],
            style: .challenge
        )
    }
    
    // Mission de rattrapage
    static func catchUp() -> MissionCard {
        MissionCard(
            icon: "🚀",
            mission: "C'est le moment de remonter !",
            details: "Donne tout ce que tu as",
            colors: [.orange, .red],
            style: .urgent
        )
    }
    
    // Mission de découverte
    static func discovery(
        theme: String
    ) -> MissionCard {
        MissionCard(
            icon: "🔍",
            mission: "Explore le thème \"\(theme)\"",
            details: "Sois créatif et original",
            colors: [.teal, .cyan],
            style: .normal
        )
    }
    
    // Mission finale
    static func finalRound() -> MissionCard {
        MissionCard(
            icon: "🏁",
            mission: "DERNIÈRE CHANCE !",
            details: "Tout se joue maintenant",
            colors: [.red, .pink],
            style: .urgent
        )
    }
    
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {

            
            // Différents types de missions
            VStack(spacing: 15) {
                MissionCard.giveWords(count: 4)
                
                MissionCard.eliminate(target: "tes adversaires")
                
                MissionCard.speedChallenge(timeLimit: 30)
                
                MissionCard.bonusRound(reward: "Double tes points !")
                
                MissionCard.precision(requirement: "Seulement des mots de 5 lettres")
                
                MissionCard.defend()
                
                MissionCard.catchUp()
                
                MissionCard.discovery(theme: "Cuisine française")
                
                MissionCard.finalRound()
            }
  
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
