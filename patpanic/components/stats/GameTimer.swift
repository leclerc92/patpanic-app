import SwiftUI

struct GameTimer: View {
    let timeRemaining: Int
    let totalTime: Int
    let onTimeUp: () -> Void
    
    @State private var pulseAnimation = false
    @State private var shakeAnimation = false
    @State private var scaleAnimation = false
    
    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }
    
    private var isUrgent: Bool {
        timeRemaining <= 10 && timeRemaining > 0
    }
    
    private var isCritical: Bool {
        timeRemaining <= 5 && timeRemaining > 0
    }
    
    private var timeText: String {
        if timeRemaining <= 0 {
            return "00:00"
        }
        
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timerColors: [Color] {
        if timeRemaining <= 0 {
            return [.red, .red.opacity(0.7)]
        } else if isCritical {
            return [.red, .orange]
        } else if isUrgent {
            return [.orange, .yellow]
        } else {
            return [.blue, .cyan]
        }
    }
    
    var body: some View {
        ZStack {
            // Cercle de progression
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: timerColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            // Container principal avec fond
            VStack(spacing: 2) {
                // Icône
                Image(systemName: timeRemaining <= 0 ? "hourglass" : "timer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(scaleAnimation ? 1.2 : 1.0)
                
                // Temps
                Text(timeText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: timerColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
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
            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            .offset(x: shakeAnimation ? -2 : 0)
            .shadow(
                color: isCritical ? .red.opacity(0.6) : isUrgent ? .orange.opacity(0.4) : .blue.opacity(0.2),
                radius: isCritical ? 12 : isUrgent ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .onChange(of: timeRemaining) { newTime in
            handleTimeChange(newTime)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func handleTimeChange(_ newTime: Int) {
        // Animation de pulsation pour les dernières secondes
        if isCritical {
            withAnimation(.easeInOut(duration: 0.3).repeatCount(2, autoreverses: true)) {
                scaleAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                scaleAnimation = false
            }
            
            // Vibration pour les dernières secondes
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        } else if isUrgent {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        // Animation de fin
        if newTime <= 0 {
            withAnimation(.easeInOut(duration: 0.5)) {
                pulseAnimation = true
            }
            
            // Animation de secousse
            withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
                shakeAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                shakeAnimation = false
                onTimeUp()
            }
        }
    }
    
    private func startAnimations() {
        // Animation de pulsation continue pour les états urgents
        if isUrgent {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// Extensions pour différents types de timers
extension GameTimer {
    
    // Timer standard pour une manche
    static func roundTimer(
        timeRemaining: Int,
        totalTime: Int = 60,
        onTimeUp: @escaping () -> Void
    ) -> GameTimer {
        GameTimer(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            onTimeUp: onTimeUp
        )
    }
    
    // Timer rapide pour actions spéciales
    static func quickTimer(
        timeRemaining: Int,
        totalTime: Int = 30,
        onTimeUp: @escaping () -> Void
    ) -> GameTimer {
        GameTimer(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            onTimeUp: onTimeUp
        )
    }
    
    // Timer long pour parties étendues
    static func longTimer(
        timeRemaining: Int,
        totalTime: Int = 120,
        onTimeUp: @escaping () -> Void
    ) -> GameTimer {
        GameTimer(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            onTimeUp: onTimeUp
        )
    }
}

// Composant pour positionner le timer en haut à droite
struct GameTimerOverlay: View {
    let timeRemaining: Int
    let totalTime: Int
    let onTimeUp: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                GameTimer(
                    timeRemaining: timeRemaining,
                    totalTime: totalTime,
                    onTimeUp: onTimeUp
                )
                .padding(.trailing, 20)
                .padding(.top, 10)
            }
            
            Spacer()
        }
    }
}

// Version avec étiquette pour debug/développement
struct GameTimerWithLabel: View {
    let timeRemaining: Int
    let totalTime: Int
    let label: String
    let onTimeUp: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            GameTimer(
                timeRemaining: timeRemaining,
                totalTime: totalTime,
                onTimeUp: onTimeUp
            )
        }
    }
}

// Manager pour gérer plusieurs timers
class TimerManager: ObservableObject {
    @Published var mainTimer: Int = 60
    @Published var bonusTimer: Int = 15
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    
    func startMainTimer(duration: Int, onComplete: @escaping () -> Void) {
        mainTimer = duration
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.mainTimer > 0 {
                self.mainTimer -= 1
            } else {
                self.stopTimer()
                onComplete()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func addBonusTime(_ seconds: Int) {
        mainTimer += seconds
    }
}

#Preview {
    ZStack {
        // Arrière-plan de test
        LinearGradient(
            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 40) {
            // Titre
            GameTitle(
                icon: "⏱️",
                title: "TIMER TESTS",
                subtitle: "Composants de chronométrage"
            )
            
            // Différents états du timer
            HStack(spacing: 20) {
                VStack(spacing: 10) {
                    GameTimerWithLabel(
                        timeRemaining: 45,
                        totalTime: 60,
                        label: "Normal",
                        onTimeUp: { print("Normal terminé") }
                    )
                }
                
                VStack(spacing: 10) {
                    GameTimerWithLabel(
                        timeRemaining: 8,
                        totalTime: 60,
                        label: "Urgent",
                        onTimeUp: { print("Urgent terminé") }
                    )
                }
                
                VStack(spacing: 10) {
                    GameTimerWithLabel(
                        timeRemaining: 3,
                        totalTime: 60,
                        label: "Critique",
                        onTimeUp: { print("Critique terminé") }
                    )
                }
                
                VStack(spacing: 10) {
                    GameTimerWithLabel(
                        timeRemaining: 0,
                        totalTime: 60,
                        label: "Fini",
                        onTimeUp: { print("Fini") }
                    )
                }
            }
            
            Divider()
            
            // Timer en overlay (position réelle)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .frame(height: 200)
                    .shadow(radius: 4)
                    .overlay(
                        Text("Zone de jeu simulée")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    )
                
                GameTimerOverlay(
                    timeRemaining: 25,
                    totalTime: 60,
                    onTimeUp: { print("Timer overlay terminé") }
                )
            }
            
            // Extensions pratiques
            HStack(spacing: 15) {
                GameTimer.quickTimer(
                    timeRemaining: 15,
                    onTimeUp: { print("Quick timer") }
                )
                
                GameTimer.roundTimer(
                    timeRemaining: 35,
                    onTimeUp: { print("Round timer") }
                )
                
                GameTimer.longTimer(
                    timeRemaining: 90,
                    totalTime: 120,
                    onTimeUp: { print("Long timer") }
                )
            }
            
            Spacer()
        }
        .padding()
    }
}
