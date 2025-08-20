import SwiftUI

struct PlayerName: View {
    let playerName: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text("\(icon)")
            Text("\(playerName)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
        }
    }
}

#Preview {
    PlayerName(playerName: "Alice", icon: "🎮")
}
