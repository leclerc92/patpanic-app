import SwiftUI

struct PlayerConfigView: View {
    
    @State var player: Player  // Garde une copie locale
    let onSave: (Player) -> Void  // Callback pour sauvegarder
    let onClose: () -> Void
    
    @State private var selectedIcon = "🕺"
    @State private var playerCategory = ""
    @State private var hasUsedShuffle = false
    @State private var showingAlert = false
    @State private var showThemeEmptyError = false

    private let playerIcons = ["🕺", "💃", "🧑‍🎤", "🤵", "👸", "🧙‍♂️", "🧙‍♀️", "🦸‍♂️", "🦸‍♀️", "🤴", "👑", "🎭", "🎨", "🎯", "🚀", "⭐", "🔥", "💎", "🌟", "⚡"]
    
    init(player: Player, onSave: @escaping (Player) -> Void, onClose: @escaping () -> Void,) {
        self.player = player
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
                
                // Thème personnalisé
                ThemeSelectionSection(
                    customTheme: $playerCategory,
                    shouldDisableShuffle: hasUsedShuffle,
                    showThemeEmptyError: showThemeEmptyError,
                    generateRandomTheme: generateRandomTheme
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
                if let category = player.category {
                    playerCategory = category
                }
            }
            .onChange(of: playerCategory) {
                // Cache l'erreur quand l'utilisateur commence à taper
                if showThemeEmptyError {
                    showThemeEmptyError = false
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func generateRandomTheme() {
        // Ne permet plus d'utiliser le shuffle si déjà utilisé ou si le joueur a déjà une card
        guard !hasUsedShuffle else { return }
        
       
        hasUsedShuffle = true 
    }
    
    private func saveConfiguration() {
            let trimmedTheme = playerCategory.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedTheme.isEmpty {
                showThemeEmptyError = true
                return
            }
            
            showThemeEmptyError = false
            player.icon = selectedIcon
            player.category = trimmedTheme
            
            onSave(player)  // Appelle le callback avec le player modifié
            onClose()
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

struct ThemeSelectionSection: View {
    @Binding var customTheme: String
    let shouldDisableShuffle: Bool
    let showThemeEmptyError: Bool
    let generateRandomTheme: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎯 Ton thème pour la 3ème manche")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Propose un thème original !")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                // Input personnalisé pour thème multiligne
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Ex: Les marques de camion...", text: $customTheme, axis: .vertical)
                        .lineLimit(2...3)
                        .font(.system(size: 14))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(showThemeEmptyError ? Color.red : Color.clear, lineWidth: 1)
                                )
                        )
                        .submitLabel(.done)
                    
                    // Message d'erreur
                    if showThemeEmptyError {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("Le thème ne peut pas être vide")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                RoundButton.replayButton(size: 40){
                    generateRandomTheme()
                }
                .padding()
                .disabled(shouldDisableShuffle)
                .opacity(shouldDisableShuffle ? 0.5 : 1.0)
            }
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
        onSave: { _ in },
        onClose: {},
    )
}
