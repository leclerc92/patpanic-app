import SwiftUI

struct PlayerRowView: View {
    let name: String
    let icon: String?
    let index: Int
    let theme: String?
    let onConfig: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        
            HStack(spacing: 16) {
                // Numéro du joueur avec gradient
                PlayerNumberBadge(index: index)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Nom du joueur
                    
                    HStack {
                        Text(name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let icon = icon {
                            Text(icon)
                        }
                    }

                    // Statut
                    HStack(spacing: 6) {
                        Circle()
                            .fill((theme != nil) ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(((theme != nil) ? theme : "No theme, no gain") ?? "")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Bouton configuration
                ConfigPlayerButton(onConfig: onConfig)
                
                // Bouton supprimer moderne
                DeletePlayerButton(onDelete: onDelete)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal)
        }
}

struct PlayerNumberBadge: View {
    let index: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
            
            Text("\(index)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct ConfigPlayerButton: View {
    let onConfig: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Vibration tactile
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            onConfig()
        }) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isPressed ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isPressed)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct DeletePlayerButton: View {
    let onDelete: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Vibration tactile
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            onDelete()
        }) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}


#Preview {
    VStack(spacing: 12) {
        
        PlayerRowView(
            name: "Michel",
            icon: "🕺",
            index: 1,
            theme: nil,
            onConfig: { },
            onDelete: { }
)
        
        PlayerRowView(
            name: "Michel",
            icon: "🕺",
            index: 2,
            theme: "Geographie ",
            onConfig: { },
            onDelete: { }
        )
        
        PlayerRowView(
            name: "Jean-Baptiste-Emmanuel",
            icon: "🕺",
            index: 3,
            theme: "Cuisine",
            onConfig: { },
            onDelete: { }
        )

    
    }
    .background(Color(.systemGroupedBackground))
}
