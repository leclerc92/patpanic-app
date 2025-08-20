//
//  GameInput.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import SwiftUI

struct GameInput: View {
    @Binding var content: String
    let action: () -> Void
    let labelIcon: String
    let label: String
    let textField: String
    let buttonIcon: String
    let buttonColors: [Color]
    
    @State private var isFocused = false
    @State private var animateButton = false
    @FocusState private var isTextFieldFocused: Bool
    
    init(
        content: Binding<String>,
        action: @escaping () -> Void,
        labelIcon: String,
        label: String,
        textField: String,
        buttonIcon: String = "plus",
        buttonColors: [Color] = [.green, .mint]
    ) {
        self._content = content
        self.action = action
        self.labelIcon = labelIcon
        self.label = label
        self.textField = textField
        self.buttonIcon = buttonIcon
        self.buttonColors = buttonColors
    }
    
    var body: some View {
        VStack(spacing: 18) {
            // Label avec icône
            HStack(spacing: 8) {
                Text(labelIcon)
                    .font(.title2)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Text(label)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Spacer()
            }
            
            // Input avec bouton
            HStack(spacing: 12) {
                // TextField stylé
                TextField(textField, text: $content)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isFocused ?
                                        LinearGradient(
                                            colors: buttonColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            colors: [.clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: isFocused ? 2 : 0
                                    )
                            )
                            .shadow(
                                color: isFocused ? buttonColors.first?.opacity(0.2) ?? .black.opacity(0.05) : .black.opacity(0.05),
                                radius: isFocused ? 8 : 4,
                                x: 0,
                                y: 2
                            )
                    )
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            action()
                        }
                    }
                    .onChange(of: isTextFieldFocused) { focused in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isFocused = focused
                        }
                    }
                
                // Bouton d'action (utilise notre RoundButton existant)
                RoundButton(
                    action: {
                        // Vérifier que le contenu n'est pas vide
                        if !isEmpty {
                            action()
                        } else {
                            // Animation de feedback si vide
                            withAnimation(.easeInOut(duration: 0.1)) {
                                animateButton = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                animateButton = false
                            }
                        }
                    },
                    icon: buttonIcon,
                    colors: buttonColors,
                    size: 50,
                    iconColor: .white
                )
                .disabled(isEmpty)
                .scaleEffect(animateButton ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: animateButton)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    private var isEmpty: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}

// Extensions pour des types d'inputs prédéfinis
extension GameInput {
    
    // Input pour ajouter un joueur
    static func addPlayer(
        content: Binding<String>,
        action: @escaping () -> Void
    ) -> GameInput {
        GameInput(
            content: content,
            action: action,
            labelIcon: "👥",
            label: "Ajouter un joueur",
            textField: "Nom du joueur",
            buttonIcon: "plus",
            buttonColors: [.green, .blue]
        )
    }
    
}



#Preview {
    ScrollView {
        VStack(spacing: 30) {
        
            GameInput.addPlayer(content: .constant(""), action: {})
            
            // Input personnalisé
            GameInput(
                content: .constant(""),
                action: {
                    print("Action personnalisée")
                },
                labelIcon: "🎯",
                label: "Custom Input",
                textField: "Placeholder personnalisé",
                buttonIcon: "star.fill",
                buttonColors: [.pink, .purple]
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
