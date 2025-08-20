import SwiftUI

struct ScoreDisplay: View {
    let playerName: String
    let score: Int
    
    var body: some View {
        HStack {
            Text("🎯")
                .font(.title3)
            Text("Score: \(score)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreDisplay(playerName: "Alice", score: 5)
        ScoreDisplay(playerName: "Bob", score: 12)
    }
}