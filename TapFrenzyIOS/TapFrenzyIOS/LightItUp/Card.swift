import Foundation
import SwiftUI

// කාඩ් එකක තොරතුරු තබා ගන්නා ව්‍යුහය
struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}

// ලෙවල් 4 පාලනය කරන Enum එක
enum GameLevel: Int {
    case L1 = 1
    case L2
    case L3
    case L4
   
    // සෑම ලෙවල් එකකටම අදාළ Grid එකේ කාඩ් ගණන
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
   
    // කාඩ් එකක් පත්තු වී පවතින කාලය (Lit Window Duration)
    var litDuration: TimeInterval {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
   
    // Bonus Feature: ලෙවල් එක අනුව වෙනස් වන Glow Color එක
    var glowColor: Color {
        switch self {
        case .L1: return .blue
        case .L2: return .green
        case .L3: return .orange
        case .L4: return .purple
        }
    }
}
