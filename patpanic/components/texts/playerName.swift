import SwiftUI

struct PlayerName: View {
    let playerName: String
    let icon: String
    
    @State private var bounceAnimation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône du joueur
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .scaleEffect(bounceAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: bounceAnimation)
            
            // Nom du joueur
            Text(playerName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primary, .primary.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
        .onAppear {
            bounceAnimation = true
        }
    }
}

#Preview {
    PlayerName(playerName: "Alice", icon: "🎮")
}
