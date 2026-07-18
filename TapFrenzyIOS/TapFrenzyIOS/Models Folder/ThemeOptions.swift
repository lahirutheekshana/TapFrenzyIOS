import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppAccentColor: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case orange = "Orange"
    case purple = "Purple"
    case green = "Green"
    case pink = "Pink"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .orange: return .orange
        case .purple: return .purple
        case .green: return .green
        case .pink: return .pink
        }
    }
}
