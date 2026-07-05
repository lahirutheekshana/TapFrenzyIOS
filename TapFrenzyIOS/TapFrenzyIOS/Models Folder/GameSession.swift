import Foundation

// තනි ගේම් එකක දත්ත තබාගන්නා ව්‍යුහය (Codable වීම අනිවාර්යයි JSON කරන්න)
struct GameSession: Identifiable, Codable {
    var id = UUID()
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

// UserDefaults හරහා දත්ත Save සහ Load කරන Class එක
class GameSessionManager {
    static let shared = GameSessionManager()
    private let storageKey = "savedGameSessions"
    
    // අලුත් ගේම් එකක් ඉවර වුනාම ඒ දත්ත Save කිරීම
    func saveSession(session: GameSession) {
        var allSessions = loadSessions()
        allSessions.append(session)
        
        // JSON විදියට Encode කරලා UserDefaults වල Save කිරීම
        if let encodedData = try? JSONEncoder().encode(allSessions) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
        }
    }
    
    // Save කරලා තියෙන දත්ත ඔක්කොම ආපහු Load කිරීම
    func loadSessions() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decodedSessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return decodedSessions
    }
}
