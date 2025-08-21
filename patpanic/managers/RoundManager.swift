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
    "Temps impartis de 45 secondes ",
    "Tu dois donner deux réponses par carte",
    "Chaque carte te rapport 1 point",
    "Valide en autant que possible !! ",
    "Tu peux passer la carte sans pénalité",
    "Tu peux mettre pause en appuyant sur la carte pour debattre de la réponse !"
]


enum Round: Int, CaseIterable {
    case round1 = 1
    case round2 = 2
    case round3 = 3
    
    var config: RoundConfig {
        switch self {
        case .round1:
            return RoundConfig(
                title: "Vif comme une anguille",
                icon: "🐍",
                nbTurns: 1,
                rules: rules1,
                timer: 45,
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
                rules: rules1,
                timer: 20,
                seuil1: 0...1,   // Très faible
                seuil2: 2...3,   // Faible  
                seuil3: 4...5,   // Moyen
                seuil4: 6...8,   // Bien
                seuil5: 9...15   // Excellent
            )
        case .round3:
            return RoundConfig(
                title: "Endurant comme un abeille",
                icon: "🐝",
                nbTurns: 1,
                rules: rules1,
                timer: 15,
                seuil1: 0...2,   // Très faible
                seuil2: 3...4,   // Faible  
                seuil3: 5...6,   // Moyen
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


