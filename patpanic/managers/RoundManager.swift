import Foundation

struct RoundConfig {
    let title: String
    let icon: String
    let nbTurns: Int
    let rules: [String]
    let timer: Int
    let seuil1: ClosedRange<Int>  // Très faible
    let seuil2: ClosedRange<Int>  // Faible  
    let seuil3: ClosedRange<Int>  // Moyen
    let seuil4: ClosedRange<Int>  // Bien
    let seuil5: ClosedRange<Int>  // Excellent
}

var rules1: [String] = [
    "Temps imparti de 45 secondes ",
    "Tu dois donner deux réponses par carte",
    "Chaque carte te rapport 1 point",
    "Valide en autant que possible !! ",
    "Tu peux passer la carte sans pénalité",
    "Tu peux mettre pause en appuyant sur la carte pour debattre de la réponse !"
]

var rules2: [String] = [
    "Temps impartis de 30 secondes",
    "Tu dois donner le nombre de réponse indiqué à chaque tour",
    "Chaque carte te rapport le nombre de point restant sur le chrono",
    "Si tu passes une carte, tu perd autant de points que de réponses que tu dois donner",
    "Tu peux mettre pause en appuyant sur la carte pour debattre de la réponse !"
]

var rules3: [String] = [
    "Temps impartis de 20 secondes",
    "Cette manche se joue avec ta catégorie personnelle",
    "Tu ne peux peux passer sinon tu gagne 0 points",
    "chaque adversaire qui passe ou répete  est éliminé et tu gagne 1 point",
    "soit le dernier en liste pour gagner, et gagner 2x le nb de joueurs en points"
]



enum Round: Int, CaseIterable {
    case round1 = 1
    case round2 = 2
    case round3 = 3
    
    var config: RoundConfig {
        let customTimer = GameSettingsHelper.getTimerForRound(self)
        
        switch self {
        case .round1:
            return RoundConfig(
                title: "Vif comme une anguille",
                icon: "🐍",
                nbTurns: 1,
                rules: rules1,
                timer: customTimer,
                seuil1: 0...2,   // Très faible
                seuil2: 3...5,   // Faible  
                seuil3: 6...8,   // Moyen
                seuil4: 9...12,  // Bien
                seuil5: 13...20  // Excellent
            )
        case .round2:
            return RoundConfig(
                title: "Erudit comme un hiboux",
                icon: "🦉",
                nbTurns: 3,
                rules: rules2,
                timer: customTimer,
                seuil1: -30...1,   // Très faible
                seuil2: 2...3,   // Faible
                seuil3: 4...5,   // Moyen
                seuil4: 6...8,   // Bien
                seuil5: 9...15   // Excellent
            )
        case .round3:
            return RoundConfig(
                title: "Endurant comme une abeille",
                icon: "🐝",
                nbTurns: 1,
                rules: rules3,
                timer: customTimer,
                seuil1: 0...0,   // Très faible
                seuil2: 1...2,   // Faible
                seuil3: 3...6,   // Moyen
                seuil4: 7...9,   // Bien
                seuil5: 10...15  // Excellent
            )
        }
    }
    
    var isLastRound: Bool {
        self == Round.allCases.last
    }
    
    var next: Round? {
        Round(rawValue: self.rawValue + 1)
    }
}


