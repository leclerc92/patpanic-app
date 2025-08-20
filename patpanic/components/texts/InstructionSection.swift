//
//  InstructionSection.swift
//  patpanic
//
//  Created by clement leclerc on 20/08/2025.
//

import SwiftUI

struct InstructionsSection: View {
    
    
    let rules: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre de la section
            HStack {
                Text("📋")
                    .font(.title2)
                Text("Instructions")
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
            .padding(.horizontal, 20)
            
            // Liste des règles
            VStack(spacing: 12) {
                ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                    InstructionRow(
                        number: index + 1,
                        text: rule
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
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
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// Composant pour chaque ligne d'instruction
struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Numéro avec style
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 30)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)
            
            // Texte de la règle
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}


#Preview {
    InstructionsSection(rules: GameManager().getCurrentRoundConfig().rules)
}
