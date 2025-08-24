import SwiftUI

struct GameCard: View {
    let theme:Theme
    let onPause: () -> Void
    let isEjecting: Bool
    let size: CardSize
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var ejectionOffset: CGSize = .zero
    @State private var ejectionRotation: Double = 0
    @State private var ejectionOpacity: Double = 1
    @State private var bounceAnimation = false
    
    enum CardSize {
        case small, medium, large
        
        var width: CGFloat {
            switch self {
            case .small: return 100
            case .medium: return 140
            case .large: return 300
            }
        }
        
        var height: CGFloat {
            switch self {
            case .small: return 150  // Ratio 2:3
            case .medium: return 210 // Ratio 2:3
            case .large: return 390  // Ratio 2:3
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 22
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }
    }
    
    init(
        theme: Theme,
        size: CardSize = .large,
        isEjecting: Bool = false,
        onPause: @escaping () -> Void
    ) {
        self.theme = theme
        self.onPause = onPause
        self.isEjecting = isEjecting
        self.size = size
    }
    
    var body: some View {
        Button(action: {
            // Vibration tactile pour la pause
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            onPause()
        }) {
            ZStack {
                // Fond principal avec gradient
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [theme.color, theme.color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Effet shimmer
                RoundedRectangle(cornerRadius: size.cornerRadius)
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
                
                // Overlay brillant
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Contenu de la carte (style Uno)
                VStack(spacing: 0) {
                    // Section supérieure avec petit texte
                    VStack(spacing: 4) {
                        Text(theme.category.uppercased())
                            .font(.system(size: size.fontSize * 0.6, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    
                    // Section centrale avec gros texte
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text(theme.title.uppercased())
                            .font(.system(size: size.fontSize, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.6)
                            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                        
                        // Indicateur de pause (apparaît au press)
                        if isPressed {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: size.fontSize * 0.8, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    // Section inférieure avec petit texte (inversé style Uno)
                    VStack(spacing: 4) {
                        Text(theme.category.uppercased())
                            .font(.system(size: size.fontSize * 0.6, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .rotationEffect(.degrees(180))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
                
                // Bordure interne style carte
                RoundedRectangle(cornerRadius: size.cornerRadius - 2)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: size.width, height: size.height)
        .scaleEffect(isPressed ? 0.98 : (bounceAnimation ? 1.02 : 1.0))
        .offset(ejectionOffset)
        .rotationEffect(.degrees(ejectionRotation))
        .opacity(ejectionOpacity)
        .shadow(
            color: theme.color.opacity(0.4),
            radius: isPressed ? 8 : 12,
            x: 0,
            y: isPressed ? 4 : 8
        )
        .animation(.interpolatingSpring(stiffness: 600, damping: 35), value: isPressed)
        .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: bounceAnimation)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.interpolatingSpring(stiffness: 700, damping: 40)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            startAnimations()
        }
        .onChange(of: isEjecting) { _, ejecting in
            if ejecting {
                ejectCard()
            } else {
                resetCard()
            }
        }
    }
    
    private func startAnimations() {
        // Animation shimmer
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
            shimmerOffset = 200
        }
        
        // Animation de respiration légère
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            bounceAnimation = true
        }
    }
    
    private func ejectCard() {
        // Animation d'éjection ultra-rapide et fluide avec effet de vitesse
        let randomDirection = Bool.random()
        let exitX: CGFloat = randomDirection ? 500 : -500
        let exitY: CGFloat = CGFloat.random(in: -80...80)
        let rotation = randomDirection ? Double.random(in: 20...35) : Double.random(in: -35...(-20))
        
        withAnimation(.interpolatingSpring(stiffness: 400, damping: 25)) {
            ejectionOffset = CGSize(width: exitX, height: exitY)
            ejectionRotation = rotation
            ejectionOpacity = 0
        }
    }
    
    private func resetCard() {
        // Position initiale depuis l'arrière avec effet de profondeur
        let randomEntry = Bool.random()
        let entryX: CGFloat = randomEntry ? -450 : 450
        let entryY: CGFloat = CGFloat.random(in: -60...60)
        let entryRotation = randomEntry ? Double.random(in: -30...(-15)) : Double.random(in: 15...30)
        
        ejectionOffset = CGSize(width: entryX, height: entryY)
        ejectionRotation = entryRotation
        ejectionOpacity = 0
        
        // Animation d'entrée rapide et dynamique avec rebond subtil
        withAnimation(.interpolatingSpring(stiffness: 350, damping: 30).delay(0.05)) {
            ejectionOffset = .zero
            ejectionRotation = 0
            ejectionOpacity = 1
        }
    }
}


// MARK: - Vue de démonstration avec effet de deck

struct GameCardDemoView: View {
    @State private var currentTheme = "Les animaux de compagnie"
    @State private var currentColors: [Color] = [.green, .mint]
    @State private var isEjecting = false
    @State private var isPaused = false
    
    let themes = [
        ("Les animaux de compagnie", [Color.green, Color.mint]),
        ("Sports d'hiver", [Color.blue, Color.cyan]),
        ("Cuisine française", [Color.orange, Color.yellow]),
        ("Films d'aventure", [Color.purple, Color.pink]),
        ("Pays d'Europe", [Color.teal, Color.blue])
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            // Arrière-plan
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // Titre
                GameTitle(
                    icon: "🎴",
                    title: "CARTE ACTUELLE",
                    subtitle: isPaused ? "Jeu en pause" : "Appuyez sur la carte pour pause"
                )
                
                // Zone de carte avec effet de deck
                ZStack {
                    // Cartes d'arrière-plan (effet de pile)
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray4))
                            .frame(width: 180 - CGFloat(index * 4), height: 270 - CGFloat(index * 6))
                            .offset(x: CGFloat(index * 2), y: CGFloat(index * -3))
                            .opacity(0.3 - Double(index) * 0.1)
                    }
                    
                    // Carte principale
                    GameCard(
                        theme: Theme(category: "Categorie", title: "Theme", colorName: ".blue"),
                        size: .large,
                        isEjecting: isEjecting,
                        onPause: {
                            isPaused.toggle()
                            print(isPaused ? "Jeu en pause" : "Jeu repris")
                        }
                    )
                }
                
                // Contrôles de navigation
                HStack(spacing: 30) {
                    RoundButton(
                        action: previousCard,
                        icon: "chevron.left",
                        colors: [.gray, .secondary],
                        size: 60
                    )
                    
                    RoundButton(
                        action: nextCard,
                        icon: "chevron.right",
                        colors: [.blue, .purple],
                        size: 60
                    )
                    
                    RoundButton(
                        action: shuffleCard,
                        icon: "shuffle",
                        colors: [.orange, .yellow],
                        size: 60
                    )
                }
                
                // Info sur la carte
                VStack(spacing: 8) {
                    Text("Carte \(currentIndex + 1) sur \(themes.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if isPaused {
                        Text("🔸 JEU EN PAUSE 🔸")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func nextCard() {
        changeCard(to: (currentIndex + 1) % themes.count)
    }
    
    private func previousCard() {
        changeCard(to: currentIndex > 0 ? currentIndex - 1 : themes.count - 1)
    }
    
    private func shuffleCard() {
        let randomIndex = Int.random(in: 0..<themes.count)
        changeCard(to: randomIndex)
    }
    
    private func changeCard(to newIndex: Int) {
        // Déclencher l'éjection
        isEjecting = true
        
        // Changer le thème après un délai ultra-court pour une transition fluide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentIndex = newIndex
            currentTheme = themes[newIndex].0
            currentColors = themes[newIndex].1
            
            // Faire rentrer la nouvelle carte immédiatement
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                isEjecting = false
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {

            
            // Vue de démonstration complète
            GameCardDemoView()
                .frame(height: 600)
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
