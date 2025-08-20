import Foundation
import SwiftUICore

class Theme: Equatable, Codable {
    let category: String
    let title: String
    let colorName: String  // "blue", "red", etc.
    let excludedRounds: [Int]
    
    var color: Color {
        // Convertir le string en Color
        switch colorName.lowercased() {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        default: return .gray
        }
    }
    
    init(category: String, title: String, colorName: String, excludedRounds: [Int] = []) {
        self.category = category
        self.title = title
        self.colorName = colorName
        self.excludedRounds = excludedRounds
    }
    
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case category, title
        case colorName = "color"
        case excludedRounds
    }
    
    func isAvailableForRound(_ round: Int) -> Bool {
        return !excludedRounds.contains(round)
    }
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        return lhs.title == rhs.title && lhs.category == rhs.category
    }
}
