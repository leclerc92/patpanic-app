//
//  RoundButton.swift
//  panicpas-app
//
//  Created by clement leclerc on 17/08/2025.
//

import SwiftUI

struct RoundButton: View {
    
    let action: () -> Void
    let icon: String
    let colors: [Color]
    let size: CGFloat
    let iconColor: Color
    
    @State private var isPressed = false
    @State private var isAnimating = false
    
    init(
        action: @escaping () -> Void,
        icon: String,
        colors: [Color],
        size: CGFloat = 80,
        iconColor: Color = .white
    ) {
        self.action = action
        self.icon = icon
        self.colors = colors
        self.size = size
        self.iconColor = iconColor
    }
    
    var body: some View {
        Button(action: {
            // Animation de feedback
            withAnimation(.easeInOut(duration: 0.1)) {
                isAnimating = true
            }
            
            // Vibration tactile
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Exécuter l'action
            action()
            
            // Reset de l'animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = false
            }
        }) {
            ZStack {
                // Fond avec gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: colors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                // Bordure brillante
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.4), .clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size, height: size)
                
                // Icône
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundStyle(iconColor)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isAnimating)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .shadow(
            color: colors.first?.opacity(0.4) ?? .black.opacity(0.2),
            radius: isPressed ? 4 : 12,
            x: 0,
            y: isPressed ? 2 : 6
        )
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// Extensions pour les actions spécifiques du jeu
extension RoundButton {
    
    // Bouton pour valider une carte (action positive)
    static func validateButton(
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) -> RoundButton {
        RoundButton(
            action: action,
            icon: "checkmark",
            colors: [Color.green, Color.mint],
            size: size,
            iconColor: .white
        )
    }
    
    // Bouton pour passer une carte (action neutre)
    static func skipButton(
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) -> RoundButton {
        RoundButton(
            action: action,
            icon: "arrow.right",
            colors: [Color.orange, Color.yellow],
            size: size,
            iconColor: .white
        )
    }
    
    // Bouton pour annuler/refuser une carte (action négative)
    static func cancelButton(
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) -> RoundButton {
        RoundButton(
            action: action,
            icon: "xmark",
            colors: [Color.red, Color.pink],
            size: size,
            iconColor: .white
        )
    }
    
    // Bouton pour aide/indice
    static func hintButton(
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) -> RoundButton {
        RoundButton(
            action: action,
            icon: "lightbulb.fill",
            colors: [Color.blue, Color.cyan],
            size: size,
            iconColor: .white
        )
    }
    
    // Bouton pour pause
    static func pauseButton(
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) -> RoundButton {
        RoundButton(
            action: action,
            icon: "pause.fill",
            colors: [Color.gray, Color.secondary],
            size: size,
            iconColor: .white
        )
    }
    
    // Bouton pour rejouer/recommencer
    static func replayButton(
        size: CGFloat = 80,
        action: @escaping () -> Void
    ) -> RoundButton {
        RoundButton(
            action: action,
            icon: "arrow.clockwise",
            colors: [Color.purple, Color.indigo],
            size: size,
            iconColor: .white
        )
    }
}

// Vue helper pour afficher deux boutons côte à côte (valider/passer)
struct GameActionButtons: View {
    let onValidate: () -> Void
    let onSkip: () -> Void
    let buttonSize: CGFloat
    
    init(
        buttonSize: CGFloat = 80,
        onValidate: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.buttonSize = buttonSize
        self.onValidate = onValidate
        self.onSkip = onSkip
    }
    
    var body: some View {
        HStack(spacing: 40) {
            RoundButton.skipButton(size: buttonSize, action: onSkip)
            RoundButton.validateButton(size: buttonSize, action: onValidate)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        // Exemple des boutons principaux du jeu
        Text("Actions de jeu")
            .font(.headline)
            .padding()
        
        GameActionButtons(
            buttonSize: 90,
            onValidate: { },
            onSkip: { }
        )
        
        Divider()
        
        // Autres boutons d'action
        Text("Autres actions")
            .font(.headline)
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
            RoundButton.cancelButton(size: 70) {
            }
            
            RoundButton.hintButton(size: 70) {
            }
            
            RoundButton.pauseButton(size: 70) {
            }
            
            RoundButton.replayButton(size: 70) {
            }
            
            // Bouton personnalisé
            RoundButton(
                action: { },
                icon: "star.fill",
                colors: [Color.pink, Color.purple],
                size: 70,
                iconColor: .white
            )
            
            // Bouton avec couleurs personnalisées
            RoundButton(
                action: { },
                icon: "heart.fill",
                colors: [Color.red, Color.orange],
                size: 70,
                iconColor: .white
            )
        }
        
        Spacer()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
