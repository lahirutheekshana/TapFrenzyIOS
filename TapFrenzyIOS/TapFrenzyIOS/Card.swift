import Foundation
import SwiftUI


struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}


enum GameLevel: Int {
    case L1 = 1
    case L2
    case L3
    case L4
   
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
   
    var litDuration: TimeInterval {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
   
    var glowColor: Color {
        switch self {
        case .L1: return .blue
        case .L2: return .green
        case .L3: return .orange
        case .L4: return .purple
        }
    }
}
