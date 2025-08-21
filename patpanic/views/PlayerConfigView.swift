import SwiftUI

struct PlayerConfigView: View {
    
    @State var player: Player  // Garde une copie locale
    let onSave: (Player) -> Void  // Callback pour sauvegarder
    let onClose: () -> Void
    let gameManager: GameManager  // Pour accéder au CardManager
    
    @State private var selectedIcon = "🕺"
    @State private var selectedCategory = ""
    @State private var showThemeEmptyError = false
    
    private let playerIcons = ["🕺", "💃", "🧑‍🎤", "🤵", "👸", "🧙‍♂️", "🧙‍♀️", "🦸‍♂️", "🦸‍♀️", "🤴", "👑", "🎭", "🎨", "🎯", "🚀", "⭐", "🔥", "💎", "🌟", "⚡"]
    
    private var availableCategories: [String] {
        gameManager.getAvailableCategories()
    }
    
    private var hasPersonalCard: Bool {
        player.personalCard != nil
    }
    
    init(player: Player, gameManager: GameManager, onSave: @escaping (Player) -> Void, onClose: @escaping () -> Void) {
        self.player = player
        self.gameManager = gameManager
        self.onClose = onClose
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header compact
                HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("⚙️ Configuration")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Personnalise \(player.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        CancelButton(action: onClose)
                }
                .padding()
                .background(Color(.systemBackground))
            
            Spacer()
            
            // Contenu sans scroll
            VStack(alignment: .leading, spacing: 16) {
                // Sélection d'icône
                IconSelectionSection(selectedIcon: $selectedIcon, playerIcons: playerIcons)
                    .padding()
                
                // Sélection de catégorie
                CategorySelectionSection(
                    selectedCategory: $selectedCategory,
                    availableCategories: availableCategories,
                    gameManager: gameManager,
                    showThemeEmptyError: showThemeEmptyError,
                    isLocked: hasPersonalCard
                )
                    .padding()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Spacer()
            // Boutons d'action compacts
            ActionButtonsSection(saveConfiguration: saveConfiguration, onClose: onClose)
            .padding()
            .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
            .onAppear {
                selectedIcon = player.icon
                if let personalCard = player.personalCard,
                   availableCategories.contains(personalCard.theme.category) {
                    selectedCategory = personalCard.theme.category
                } else if !availableCategories.isEmpty {
                    selectedCategory = availableCategories.first ?? ""
                }
            }
            .onChange(of: selectedCategory) {
                // Cache l'erreur quand l'utilisateur sélectionne
                if showThemeEmptyError {
                    showThemeEmptyError = false
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveConfiguration() {
        if selectedCategory.isEmpty {
            showThemeEmptyError = true
            return
        }
        
        showThemeEmptyError = false
        player.icon = selectedIcon
        
        // Si le joueur a déjà une carte, on ne fait que sauvegarder l'icône
        if hasPersonalCard {
            onSave(player)
            onClose()
            return
        }
        
        // Génère la carte personnelle basée sur la catégorie sélectionnée
        if let personalCard = gameManager.generatePlayerCard(for: selectedCategory) {
            player.personalCard = personalCard
            onSave(player)  // Appelle le callback avec le player modifié
            onClose()
        } else {
            // Gestion d'erreur si aucune carte ne peut être générée
            print("❌ Impossible de générer une carte pour \(selectedCategory)")
            showThemeEmptyError = true
        }
    }
    
  
}

struct IconSelectionSection: View {
    @Binding var selectedIcon: String
    let playerIcons: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎭 Choisis ton avatar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(playerIcons, id: \.self) { icon in
                        IconButton(icon: icon, isSelected: selectedIcon == icon) {
                            selectedIcon = icon
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
        }
    }
}

struct CategorySelectionSection: View {
    @Binding var selectedCategory: String
    let availableCategories: [String]
    let gameManager: GameManager
    let showThemeEmptyError: Bool
    let isLocked: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("🎯 Ta catégorie personnelle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if isLocked {
                            Text("🔒")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(isLocked ? "Ta catégorie est déjà définie !" : "Choisis ta spécialité pour la 3ème manche !")
                        .font(.caption)
                        .foregroundColor(isLocked ? .orange : .secondary)
                    
                    if !isLocked {
                        Text("💡 Utilise le bouton mélange pour une sélection aléatoire")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Spacer()
                
                // Bouton shuffle pour sélection aléatoire (désactivé si verrouillé)
                RoundButton(
                    action: shuffleCategory,
                    icon: "shuffle",
                    colors: [.purple, .indigo],
                    size: 44,
                    iconColor: .white
                )
                .disabled(isLocked)
                .opacity(isLocked ? 0.5 : 1.0)
            }
            
            VStack(spacing: 8) {
                // Picker moderne avec style menu (désactivé si verrouillé)
                Menu {
                    ForEach(availableCategories, id: \.self) { category in
                        Button(action: {
                            if !isLocked {
                                selectedCategory = category
                            }
                        }) {
                            HStack {
                                Text(category.capitalized)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .disabled(isLocked)
                    }
                } label: {
                    HStack {
                        Text(selectedCategory.isEmpty ? "Sélectionne une catégorie" : selectedCategory.capitalized)
                            .font(.system(size: 14))
                            .foregroundColor(
                                isLocked ? .secondary : 
                                (selectedCategory.isEmpty ? .secondary : .primary)
                            )
                            .animation(.easeInOut(duration: 0.3), value: selectedCategory)
                        
                        Spacer()
                        
                        // Badge coloré selon la catégorie
                        if !selectedCategory.isEmpty {
                            Circle()
                                .fill(colorForCategory(selectedCategory))
                                .frame(width: 12, height: 12)
                                .opacity(isLocked ? 0.6 : 1.0)
                        }
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                        } else {
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .opacity(isLocked ? 0.7 : 1.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(showThemeEmptyError ? Color.red : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .disabled(isLocked)
                
                // Message d'erreur
                if showThemeEmptyError {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("Veuillez sélectionner une catégorie")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 4)
                }
                
                // Preview de la catégorie sélectionnée
                if !selectedCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isLocked ? "Carte réservée" : "Aperçu")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorForCategory(selectedCategory))
                                .frame(width: 8, height: 8)
                                .opacity(isLocked ? 0.6 : 1.0)
                            
                            Text(isLocked ? 
                                "Ta carte secrète de \"\(selectedCategory.capitalized)\" est réservée pour la 3ème manche !" :
                                "Tu joueras avec les thèmes de \"\(selectedCategory.capitalized)\""
                            )
                                .font(.system(size: 11))
                                .foregroundColor(isLocked ? .orange : .secondary)
                                .italic()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorForCategory(selectedCategory).opacity(isLocked ? 0.05 : 0.1))
                        )
                    }
                }
            }
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        let colorName = gameManager.getCategoryColor(for: category)
        
        switch colorName.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .gray
        }
    }
    
    private func shuffleCategory() {
        guard !availableCategories.isEmpty else { return }
        
        // Sélectionne une catégorie aléatoire différente de l'actuelle si possible
        let otherCategories = availableCategories.filter { $0 != selectedCategory }
        let categoriesToChooseFrom = otherCategories.isEmpty ? availableCategories : otherCategories
        
        if let randomCategory = categoriesToChooseFrom.randomElement() {
            selectedCategory = randomCategory
        }
    }
}

struct ActionButtonsSection: View {
    let saveConfiguration: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Text("Annuler")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            Button(action: saveConfiguration) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                    Text("Valider")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    PlayerConfigView(
        player: Player(name: "Alice"),
        gameManager: GameManager(),
        onSave: { _ in },
        onClose: {}
    )
}
