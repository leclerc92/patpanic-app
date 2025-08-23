import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let colors: [Color]
    let size: StatSize
    
    @State private var animateValue = false
    
    enum StatSize {
        case compact, normal, large
        
        var iconSize: CGFloat {
            switch self {
            case .compact: return 16
            case .normal: return 20
            case .large: return 24
            }
        }
        
        var titleSize: CGFloat {
            switch self {
            case .compact: return 11
            case .normal: return 13
            case .large: return 15
            }
        }
        
        var valueSize: CGFloat {
            switch self {
            case .compact: return 20
            case .normal: return 24
            case .large: return 32
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .compact: return 12
            case .normal: return 16
            case .large: return 20
            }
        }
    }
    
    init(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        colors: [Color] = [.blue, .cyan],
        size: StatSize = .normal
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.colors = colors
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: size == .compact ? 6 : 8) {
            // Icône
            HStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: size.iconSize))
                
                Text(title.uppercased())
                    .font(.system(size: size.titleSize, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            // Valeur principale
            Text(value)
                .font(.system(size: size.valueSize, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: colors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(animateValue ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animateValue)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Sous-titre optionnel
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: size.titleSize - 1, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(size.padding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: colors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: colors.first?.opacity(0.2) ?? .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            // Animation d'apparition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateValue = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animateValue = false
                }
            }
        }
    }
}

// MARK: - Extensions pour layouts spécifiques

extension StatCard {
    
    // Extensions optimisées pour HStack horizontal
    static func forHorizontalLayout() -> StatCardHorizontalBuilder {
        return StatCardHorizontalBuilder()
    }
}

struct StatCardHorizontalBuilder {
    
    func turnsRemaining(count: Int) -> StatCard {
        StatCard(
            icon: "🔄",
            title: "Tours restants",
            value: "\(count)",
            subtitle: nil,
            colors: count <= 1 ? [.red, .orange] : [.blue, .cyan],
            size: .compact
        )
    }
    
    func totalScore(score: Int) -> StatCard {
        StatCard(
            icon: "🏆",
            title: "Total",
            value: "\(score)",
            subtitle: nil,
            colors: [.red, .orange],
            size: .compact
        )
    }
    
    func roundScore(score: Int, roundNumber: Int) -> StatCard {
        StatCard(
            icon: "🎯",
            title: "Manche\(roundNumber)",
            value: "\(score)",
            subtitle: nil,
            colors: [.blue, .cyan],
            size: .normal  // Plus gros car au centre
        )
    }
    
}
// MARK: - Extensions pour différents types de stats

extension StatCard {
    
    // Tours restants
    static func turnsRemaining(
        count: Int,
        size: StatSize = .normal
    ) -> StatCard {
        StatCard(
            icon: "🔄",
            title:  "Tours" ,
            value: "\(count)",
            subtitle: count == 1 ? (size == .compact ? "dernier" : "dernier tour") : "restants",
            colors: count <= 1 ? [.red, .orange] : [.blue, .cyan],
            size: size
        )
    }
    
    // Score global
    static func totalScore(
        score: Int,
        size: StatSize = .normal
    ) -> StatCard {
        StatCard(
            icon: "🏆",
            title: size == .compact ? "Total" : "Score total",
            value: "\(score)",
            subtitle: size == .compact ? "pts" : "points",
            colors: [.purple, .indigo],
            size: size
        )
    }
    
    // Score de round
    static func roundScore(
        score: Int,
        roundNumber: Int,
        size: StatSize = .normal
    ) -> StatCard {
        StatCard(
            icon: "🎯",
            title: "Manche \(roundNumber)",
            value: "\(score)",
            subtitle: "pts",
            colors: [.blue, .cyan],
            size: size
        )
    }
    
 
    
    // Temps de jeu
    static func gameTime(
        minutes: Int,
        seconds: Int,
        size: StatSize = .normal
    ) -> StatCard {
        StatCard(
            icon: "⏱️",
            title: "Temps de jeu",
            value: String(format: "%d:%02d", minutes, seconds),
            subtitle: "écoulé",
            colors: [.purple, .indigo],
            size: size
        )
    }
    
    // Mots trouvés
    static func wordsFound(
        count: Int,
        size: StatSize = .normal
    ) -> StatCard {
        StatCard(
            icon: "💭",
            title: "Mots trouvés",
            value: "\(count)",
            subtitle: count == 1 ? "mot" : "mots",
            colors: [.green, .mint],
            size: size
        )
    }
    
    // Streak/série
    static func streak(
        count: Int,
        size: StatSize = .normal
    ) -> StatCard {
        StatCard(
            icon: "🔥",
            title: "Série",
            value: "\(count)",
            subtitle: "d'affilée",
            colors: count > 5 ? [.orange, .red] : [.yellow, .orange],
            size: size
        )
    }
    
}

// MARK: - Container pour plusieurs stats

struct StatsRow: View {
    let stats: [StatCard]
    let spacing: CGFloat
    
    init(stats: [StatCard], spacing: CGFloat = 12) {
        self.stats = stats
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<stats.count, id: \.self) { index in
                stats[index]
            }
        }
    }
}

struct StatsGrid: View {
    let stats: [StatCard]
    let columns: Int
    let spacing: CGFloat
    
    init(stats: [StatCard], columns: Int = 2, spacing: CGFloat = 12) {
        self.stats = stats
        self.columns = columns
        self.spacing = spacing
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: spacing) {
            ForEach(0..<stats.count, id: \.self) { index in
                stats[index]
            }
        }
    }
}




#Preview {
 
    VStack(spacing: 30) {
        // Titre
        GameTitle(
            icon: "📊",
            title: "STAT CARDS",
            subtitle: "Composants de statistiques"
        )
        
        // Stats individuelles
        VStack(spacing: 20) {
            Text("Stats individuelles")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard.totalScore(score: 156)
                StatCard.roundScore(score: 23, roundNumber: 3)
                StatCard.turnsRemaining(count: 2)
                StatCard.wordsFound(count: 12)
                StatCard.streak(count: 7)
            }
        }
    }
}
