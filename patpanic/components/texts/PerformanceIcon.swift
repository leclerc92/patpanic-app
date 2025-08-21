//
//  PerformanceIcon.swift
//  patpanic
//
//  Created by clement leclerc on 21/08/2025.
//

import SwiftUI

// Composant pour l'icône de performance
struct PerformanceIcon: View {
    let icon: String
    let colors: [Color]
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Cercle de fond avec gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
            
            // Cercle de bordure
            Circle()
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: rotationAngle)
            
            // Icône
            Text(icon)
                .font(.system(size: 32))
        }
        .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
        .onAppear {
            rotationAngle = 360
        }
    }
}

#Preview {
    PerformanceIcon(icon: "😎", colors: [.blue, .purple])
}
