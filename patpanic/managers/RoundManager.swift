import Foundation

struct RoundConfig {
    let title: String
    let icon: String
    let nbTurns: Int
    let rules: [String]
    let timer: Int
    let seuil1: ClosedRange<Int>
    let seuil2: ClosedRange<Int>
    let seuil3: ClosedRange<Int>
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
                seuil1: 0...3,
                seuil2: 3...6,
                seuil3: 6...20
            )
        case .round2:
            return RoundConfig(
                title: "Erudit comme un hiboux",
                icon: "🦉",
                nbTurns: 3,
                rules: rules1,
                timer: 20,
                seuil1: 0...2,
                seuil2: 3...5,
                seuil3: 6...7
            )
        case .round3:
            return RoundConfig(
                title: "Endurant comme un abeille",
                icon: "🐝",
                nbTurns: 1,
                rules: rules1,
                timer: 15,
                seuil1: 0...3,
                seuil2: 4...7,
                seuil3: 8...10
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
