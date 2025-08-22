import SwiftUI

struct PlayerConfigView: View {
    @StateObject private var viewModel: PlayerConfigViewModel
    
    init(player: Player, gameManager: GameManager, onSave: @escaping (Player) -> Void, onClose: @escaping () -> Void) {
        self._viewModel = StateObject(
            wrappedValue: PlayerConfigViewModel(
                player: player,
                gameManager: gameManager,
                onSave: onSave,
                onClose: onClose
            )
        )
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
                            
                            Text("Personnalise \(viewModel.playerName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        CancelButton(action: viewModel.cancel)
                }
                .padding()
                .background(Color(.systemBackground))
            
            Spacer()
            
            // Contenu sans scroll
            VStack(alignment: .leading, spacing: 16) {
                // Sélection d'icône
                IconSelectionSection(viewModel: viewModel)
                    .padding()
                
                // Sélection de catégorie
                CategorySelectionSection(viewModel: viewModel)
                    .padding()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Spacer()
            // Boutons d'action compacts
            ActionButtonsSection(viewModel: viewModel)
            .padding()
            .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
    
    
  
}

struct IconSelectionSection: View {
    @ObservedObject var viewModel: PlayerConfigViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎭 Choisis ton avatar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.playerIcons, id: \.self) { icon in
                        IconButton(icon: icon, isSelected: viewModel.isIconSelected(icon)) {
                            viewModel.selectIcon(icon)
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
    @ObservedObject var viewModel: PlayerConfigViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("🎯 Ta catégorie personnelle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if viewModel.hasPersonalCard {
                            Text("🔒")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(viewModel.categoryLockText)
                        .font(.caption)
                        .foregroundColor(viewModel.categoryLockColor)
                    
                    if !viewModel.hasPersonalCard {
                        Text("💡 Utilise le bouton mélange pour une sélection aléatoire")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Spacer()
                
                // Bouton shuffle pour sélection aléatoire (désactivé si verrouillé)
                RoundButton(
                    action: viewModel.shuffleCategory,
                    icon: "shuffle",
                    colors: [.purple, .indigo],
                    size: 44,
                    iconColor: .white
                )
                .disabled(viewModel.hasPersonalCard)
                .opacity(viewModel.hasPersonalCard ? 0.5 : 1.0)
            }
            
            VStack(spacing: 8) {
                // Picker moderne avec style menu (désactivé si verrouillé)
                Menu {
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        Button(action: {
                            viewModel.selectCategory(category)
                        }) {
                            HStack {
                                Text(category.capitalized)
                                Spacer()
                                if viewModel.isCategorySelected(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .disabled(viewModel.hasPersonalCard)
                    }
                } label: {
                    HStack {
                        Text(viewModel.categoryDisplayText)
                            .font(.system(size: 14))
                            .foregroundColor(
                                viewModel.hasPersonalCard ? .secondary : 
                                (viewModel.selectedCategory.isEmpty ? .secondary : .primary)
                            )
                            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedCategory)
                        
                        Spacer()
                        
                        // Badge coloré selon la catégorie
                        if !viewModel.selectedCategory.isEmpty {
                            Circle()
                                .fill(viewModel.colorForCategory(viewModel.selectedCategory))
                                .frame(width: 12, height: 12)
                                .opacity(viewModel.hasPersonalCard ? 0.6 : 1.0)
                        }
                        
                        if viewModel.hasPersonalCard {
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
                            .opacity(viewModel.hasPersonalCard ? 0.7 : 1.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.showThemeEmptyError ? Color.red : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .disabled(viewModel.hasPersonalCard)
                
                // Message d'erreur
                if viewModel.showThemeEmptyError {
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
                if !viewModel.selectedCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.previewTitleText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.colorForCategory(viewModel.selectedCategory))
                                .frame(width: 8, height: 8)
                                .opacity(viewModel.hasPersonalCard ? 0.6 : 1.0)
                            
                            Text(viewModel.categoryPreviewText)
                                .font(.system(size: 11))
                                .foregroundColor(viewModel.previewTextColor)
                                .italic()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.colorForCategory(viewModel.selectedCategory).opacity(viewModel.hasPersonalCard ? 0.05 : 0.1))
                        )
                    }
                }
            }
        }
    }
    
}

struct ActionButtonsSection: View {
    @ObservedObject var viewModel: PlayerConfigViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.cancel) {
                Text("Annuler")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            Button(action: viewModel.saveConfiguration) {
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
