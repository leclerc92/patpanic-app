import SwiftUI

struct ScoreDisplay: View {
    let score: Int
    
    private var scoreColor: LinearGradient {
        if score > 0 {
            return LinearGradient(
                colors: [.green, .mint],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if score < 0 {
            return LinearGradient(
                colors: [.red, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [.blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var scoreIcon: String {
        if score > 0 {
            return "📈" // Tendance montante
        } else if score < 0 {
            return "📉" // Tendance descendante
        } else {
            return "🎯" // Neutre
        }
    }
    
    private var scorePrefix: String {
        if score > 0 {
            return "+\(score)"
        } else {
            return "\(score)" // Le signe négatif est déjà inclus
        }
    }
    
    var body: some View {
        HStack {
            Text(scoreIcon)
                .font(.title3)
            Text("Score: \(scorePrefix)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(scoreColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
        .scaleEffect(score != 0 ? 1.05 : 1.0)
        .animation(.interpolatingSpring(stiffness: 400, damping: 30), value: score)
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreDisplay(score: 15)   // Points gagnés
        ScoreDisplay(score: -5)   // Points perdus
        ScoreDisplay(score: 0)    // Neutre
    }
    .padding()
}
