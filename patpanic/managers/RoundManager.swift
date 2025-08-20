import Foundation

struct RoundConfig {
    let title: String
    let nbTurns: Int
    let rules: String
    let timer: Int
    let seuil1: ClosedRange<Int>
    let seuil2: ClosedRange<Int>
    let seuil3: ClosedRange<Int>
}

enum Round: Int, CaseIterable {
    case round1 = 1
    case round2 = 2
    case round3 = 3
    
    var config: RoundConfig {
        switch self {
        case .round1:
            return RoundConfig(
                title: "🐍 Vif comme une anguille",
                nbTurns: 1,
                rules: "Deux réponse pas carte, enchaine le plus vite possible ! ",
                timer: 45,
                seuil1: 0...3,
                seuil2: 3...6,
                seuil3: 6...20
            )
        case .round2:
            return RoundConfig(
                title: "🦉 Erudit comme un hiboux",
                nbTurns: 3,
                rules: "Trouve le nombre de mot demandé, le plus vite possible !",
                timer: 20,
                seuil1: 0...2,
                seuil2: 3...5,
                seuil3: 6...7
            )
        case .round3:
            return RoundConfig(
                title: "🐝 Endurant comme un abeille",
                nbTurns: 1,
                rules: "Catégorie personnalisée, elimine les autres joueurs !",
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
