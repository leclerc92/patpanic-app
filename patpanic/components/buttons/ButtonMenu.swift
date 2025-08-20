//
//  ButtonMenu.swift
//  patpanic
//
//  Created by clement leclerc on 19/08/2025.
//

import SwiftUI

struct ButtonMenu: View {
    
    let action: () -> Void
    let title: String
    let subtitle: String?
    let icon: String?
    let colors: [Color]
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icône
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                }
                
                // Textes
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Flèche
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                // Gradient de fond
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                // Bordure brillante
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colors.first?.opacity(0.3) ?? .black.opacity(0.1),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

extension ButtonMenu {
    static func primaryButton(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        action: @escaping () -> Void
    ) -> ButtonMenu {
        ButtonMenu(
            action: action,
            title: title,
            subtitle: subtitle,
            icon: icon,
            colors: [Color.blue, Color.purple]
        )
    }
    
    static func secondaryButton(
            title: String,
            subtitle: String? = nil,
            icon: String? = nil,
            action: @escaping () -> Void
        ) -> ButtonMenu {
            ButtonMenu(
                action: action,
                title: title,
                subtitle: subtitle,
                icon: icon,
                colors: [Color.orange, Color.red]
            )
        }
}

#Preview {
    VStack {
        
        ButtonMenu.primaryButton(
                   title: "Nouvelle Partie",
                   subtitle: "Commencer une partie rapide",
                   icon: "play.fill"
               ) {
                   print("Nouvelle partie")
        }
               
        ButtonMenu.secondaryButton(
                   title: "Multijoueur",
                   subtitle: "Jouer avec des amis",
                   icon: "person.2.fill"
               ) {
                   print("Multijoueur")
        }
        
        ButtonMenu(
            action: { print("Personnalisé") },
            title: "Paramètres",
            subtitle: "Configurer le jeu",
            icon: "gearshape.fill",
            colors: [Color.indigo, Color.cyan]
        )
        
        // Bouton sans sous-titre et sans icône
        ButtonMenu(
            action: { print("Simple") },
            title: "À propos",
            subtitle: nil,
            icon: nil,
            colors: [Color.gray, Color.secondary]
        )
    }.padding()
}
