//
//  ScoreCard.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

struct ScoreCard: View {
    
    let icon: String
    let primaryMessage: String
    let secondaryMessage: String?
    let score: Int
    let colors: [Color]
    let shadowColor: Color
    
    @State private var animateScore = false
    @State private var animateIcon = false
    
    init(
        icon: String,
        primaryMessage: String,
        secondaryMessage: String? = nil,
        score: Int,
        colors: [Color] = [.blue, .purple],
        shadowColor: Color = .purple
    ) {
        self.icon = icon
        self.primaryMessage = primaryMessage
        self.secondaryMessage = secondaryMessage
        self.score = score
        self.colors = colors
        self.shadowColor = shadowColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icône de performance
            PerformanceIcon(
                icon: icon,
                colors: colors
            )
            .scaleEffect(animateIcon ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateIcon)
            
            // Score principal
            VStack(spacing: 8) {
                Text(score >= 0 ? "+\(score)" : "\(score)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(animateScore ? 1.1 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateScore)
                
                Text("points")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            // Messages
            VStack(spacing: 4) {
                Text(primaryMessage)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                if let secondaryMessage = secondaryMessage {
                    Text(secondaryMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: shadowColor.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            // Démarrer les animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateScore = true
                animateIcon = true
            }
        }
    }
}



// MARK: - Extensions avec thèmes prédéfinis

extension ScoreCard {
    
    // Performance excellente (score élevé)
    static func excellent(
        score: Int,
        primaryMessage: String = "Excellent !",
        secondaryMessage: String? = "Performance remarquable !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "🔥",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.green, .mint],
            shadowColor: .green
        )
    }
    
    // Performance très bonne
    static func great(
        score: Int,
        primaryMessage: String = "Très bien !",
        secondaryMessage: String? = "Continue comme ça !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "😎",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.blue, .cyan],
            shadowColor: .blue
        )
    }
    
    // Performance correcte
    static func good(
        score: Int,
        primaryMessage: String = "Bien joué !",
        secondaryMessage: String? = "Pas mal du tout !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "👍",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.orange, .yellow],
            shadowColor: .orange
        )
    }
    
    // Performance moyenne
    static func average(
        score: Int,
        primaryMessage: String = "Pas mal !",
        secondaryMessage: String? = "Tu peux faire mieux !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "🙂",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.purple, .indigo],
            shadowColor: .purple
        )
    }
    
    // Performance faible
    static func poor(
        score: Int,
        primaryMessage: String = "Allez !",
        secondaryMessage: String? = "La prochaine sera meilleure !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "😅",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.gray, .secondary],
            shadowColor: .gray
        )
    }
    
    // Score négatif (malus)
    static func penalty(
        score: Int,
        primaryMessage: String = "Oups !",
        secondaryMessage: String? = "Attention la prochaine fois !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "😬",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.red, .pink],
            shadowColor: .red
        )
    }
    
    // Bonus spécial
    static func bonus(
        score: Int,
        primaryMessage: String = "BONUS !",
        secondaryMessage: String? = "Fantastique !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "⭐",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.yellow, .orange],
            shadowColor: .yellow
        )
    }
    
    // Combo/Série
    static func combo(
        score: Int,
        comboCount: Int,
        primaryMessage: String? = nil,
        secondaryMessage: String? = nil
    ) -> ScoreCard {
        ScoreCard(
            icon: "🚀",
            primaryMessage: primaryMessage ?? "COMBO x\(comboCount) !",
            secondaryMessage: secondaryMessage ?? "Tu es en feu !",
            score: score,
            colors: [.pink, .purple],
            shadowColor: .pink
        )
    }
    
    // Score final
    static func final(
        score: Int,
        primaryMessage: String = "Score final",
        secondaryMessage: String? = "Partie terminée !"
    ) -> ScoreCard {
        ScoreCard(
            icon: "🏆",
            primaryMessage: primaryMessage,
            secondaryMessage: secondaryMessage,
            score: score,
            colors: [.yellow, .orange],
            shadowColor: .yellow
        )
    }
}

// MARK: - Extensions spécialisées par round

extension ScoreCard {
    
    // Crée une ScoreCard basée sur le score et le round actuel
    static func forRound(
        score: Int,
        round: Round,
        playerIcon: String
    ) -> ScoreCard {
        let config = round.config
        
        // Messages personnalisés selon le round et le score
        let (primaryMessage, secondaryMessage, cardType): (String, String, ScoreCardType) = {
            switch round {
            case .round1: // Vif comme une anguille 🐍
                if config.seuil1.contains(score) {
                    return ("Tu rampes encore...", "Même les gasteropodes bougent plus vite ! 🐌", .poor)
                } else if config.seuil2.contains(score) {
                    return ("Pas mal, petit lézard !", "Tu commences à prendre le rythme 🦎", .average)
                } else if config.seuil3.contains(score) {
                    return ("Ça glisse bien !", "Tu prends de la vitesse ! ⚡", .good)
                } else if config.seuil4.contains(score) {
                    return ("Rapide comme l'éclair !", "Tu files comme une anguille ! 🐍", .great)
                } else {
                    return ("VITESSE FOUDROYANTE !", "Tu es plus rapide que ton ombre ! ⚡🐍", .excellent)
                }
                
            case .round2: // Érudit comme un hibou 🦉
                if config.seuil1.contains(score) {
                    return ("Hmm... tu réfléchis encore ?", "Même un poussin sait plus de choses ! 🐣", .poor)
                } else if config.seuil2.contains(score) {
                    return ("Pas bête du tout !", "Tu ouvres tes ailes de sagesse 🪶", .average)
                } else if config.seuil3.contains(score) {
                    return ("Bien vu, l'intello !", "Ta savoir commence à briller ✨", .good)
                } else if config.seuil4.contains(score) {
                    return ("Sage comme un hibou !", "Tes connaissances impressionnent ! 🦉", .great)
                } else {
                    return ("GÉNIE NOCTURNE !", "C'est toi l'érudit des bois ! 🦉📚", .excellent)
                }
                
            case .round3: // Endurant comme une abeille 🐝
                if config.seuil1.contains(score) {
                    return ("Tu bourdonne encore ?", "Il serait temps de quitter la ruche ! 🐜", .poor)
                } else if config.seuil2.contains(score) {
                    return ("Ça commence à butiner !", "Tu trouves ton rythme de travail 🌸", .average)
                } else if config.seuil3.contains(score) {
                    return ("Travailleur efficace !", "Tu butines avec ardeur ! 🌻", .good)
                } else if config.seuil4.contains(score) {
                    return ("Infatigable ouvrière !", "Tu travailles comme une abeille ! 🐝", .great)
                } else {
                    return ("REINE DES ABEILLES !", "Ta productivité est légendaire ! 🐝👑", .excellent)
                }
            }
        }()
        
        // Créer la ScoreCard appropriée
        switch cardType {
        case .poor:
            return .poor(score: score, primaryMessage: primaryMessage, secondaryMessage: secondaryMessage)
        case .average:
            return .average(score: score, primaryMessage: primaryMessage, secondaryMessage: secondaryMessage)
        case .good:
            return .good(score: score, primaryMessage: primaryMessage, secondaryMessage: secondaryMessage)
        case .great:
            return .great(score: score, primaryMessage: primaryMessage, secondaryMessage: secondaryMessage)
        case .excellent:
            return .excellent(score: score, primaryMessage: primaryMessage, secondaryMessage: secondaryMessage)
        }
    }
    
    // Enum helper pour les types de cartes
    private enum ScoreCardType {
        case poor, average, good, great, excellent
    }
}

// MARK: - Extensions par plage de score

extension ScoreCard {
    
    // Crée automatiquement le bon thème selon le score
    static func auto(
        score: Int,
        customMessage: String? = nil,
        customSecondary: String? = nil
    ) -> ScoreCard {
        if score < 0 {
            return .penalty(
                score: score,
                primaryMessage: customMessage ?? "Oups !",
                secondaryMessage: customSecondary
            )
        } else if score < 10 {
            return .poor(
                score: score,
                primaryMessage: customMessage ?? "Allez !",
                secondaryMessage: customSecondary
            )
        } else if score < 20 {
            return .average(
                score: score,
                primaryMessage: customMessage ?? "Pas mal !",
                secondaryMessage: customSecondary
            )
        } else if score < 35 {
            return .good(
                score: score,
                primaryMessage: customMessage ?? "Bien joué !",
                secondaryMessage: customSecondary
            )
        } else if score < 50 {
            return .great(
                score: score,
                primaryMessage: customMessage ?? "Très bien !",
                secondaryMessage: customSecondary
            )
        } else {
            return .excellent(
                score: score,
                primaryMessage: customMessage ?? "Excellent !",
                secondaryMessage: customSecondary
            )
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Titre
            GameTitle(
                icon: "🏆",
                title: "SCORE CARDS",
                subtitle: "Différents thèmes"
            )
            
            // Thèmes prédéfinis
            ScrollView {
                
                ScoreCard.excellent(
                    score: 45,
                    primaryMessage: "Parfait !",
                    secondaryMessage: "Tu es un champion !"
                )
                
                ScoreCard.great(
                    score: 30,
                    primaryMessage: "Super !",
                    secondaryMessage: "Excellent travail !"
                )
                
                ScoreCard.good(
                    score: 20,
                    primaryMessage: "Bien !",
                    secondaryMessage: "Continue ainsi !"
                )
                
                ScoreCard.average(
                    score: 15,
                    primaryMessage: "Correct",
                    secondaryMessage: "Tu progresses !"
                )
                
                ScoreCard.poor(
                    score: 5,
                    primaryMessage: "Courage !",
                    secondaryMessage: "N'abandonne pas !"
                )
                
                ScoreCard.penalty(
                    score: -10,
                    primaryMessage: "Aïe !",
                    secondaryMessage: "Fais attention !"
                )
                
                ScoreCard.bonus(
                    score: 25,
                    primaryMessage: "BONUS !",
                    secondaryMessage: "Incroyable !"
                )
                
                ScoreCard.combo(
                    score: 40,
                    comboCount: 5
                )
            }
            
            Divider()
                .padding()
            
            // Auto selon score
            VStack(spacing: 20) {
                Text("Mode automatique")
                    .font(.headline)
                
                HStack(spacing: 15) {
                    ScoreCard.auto(score: 5)
                    ScoreCard.auto(score: 25)
                    ScoreCard.auto(score: 60)
                }
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
