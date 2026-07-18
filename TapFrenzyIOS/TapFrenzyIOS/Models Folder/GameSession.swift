import Foundation
import Combine
import Charts


enum SessionGameMode: String, Codable, Plottable, CaseIterable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
}

struct GameSession: Identifiable, Codable, Hashable {
    var id = UUID()
    let mode: SessionGameMode // මෙතනටත් අලුත් නම දුන්නා
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

class GameSessionManager: ObservableObject {
    static let shared = GameSessionManager()
    private let storageKey = "savedGameSessions"
    
    @Published var sessions: [GameSession] = []
    
    init(){
        self.sessions = loadSessions()
    }
    
    func saveSession(session: GameSession) {
        var allSessions = loadSessions()
        allSessions.append(session)
        
        if let encodedData = try? JSONEncoder().encode(allSessions) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
        }
        self.sessions = allSessions
    }
    
    func loadSessions() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decodedSessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return decodedSessions
    }
    
    func resetSessions() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        self.sessions = []
    }
}
