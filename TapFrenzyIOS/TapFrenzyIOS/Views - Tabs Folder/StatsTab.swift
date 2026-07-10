import SwiftUI
import Charts

struct StatsTab: View {
  
    @ObservedObject var manager = GameSessionManager.shared
    @State private var selectedMode: SessionGameMode = .tapFrenzy
    
    var totalSessions: Int {
        manager.sessions.count
    }
    
    var totalPoints: Int {
        manager.sessions.reduce(0) { $0 + $1.score }
    }
    
    var recentGames: [GameSession] {
        Array(manager.sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if manager.sessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Games Played Yet!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Play a game to see your statistics here.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // Summary Cards
                            HStack(spacing: 15) {
                                StatCard(title: "Total Sessions", value: "\(totalSessions)", icon: "play.circle.fill", color: .blue)
                                StatCard(title: "Total Points", value: "\(totalPoints)", icon: "star.fill", color: .orange)
                            }
                            .padding(.horizontal)
                            
                            // Charts Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Scores by Mode")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Picker("Game Mode", selection: $selectedMode) {
                                    ForEach(SessionGameMode.allCases, id: \.self) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                                
                                let modeSessions = manager.sessions.filter { $0.mode == selectedMode }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    if !modeSessions.isEmpty {
                                        let recentModeSessions = Array(modeSessions.suffix(10))
                                        Chart {
                                            ForEach(Array(recentModeSessions.enumerated()), id: \.element.id) { index, session in
                                                BarMark(
                                                    x: .value("Game", "G\(index + 1)"),
                                                    y: .value("Score", session.score)
                                                )
                                                .foregroundStyle(Color.blue.gradient)
                                                .cornerRadius(6)
                                                .annotation(position: .top) {
                                                    Text("\(session.score)")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        .chartLegend(.hidden)
                                    } else {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("No data for \(selectedMode.rawValue)")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                                .padding()
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                            
                            // Recent Games Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Games")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(recentGames) { session in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(session.mode.rawValue)
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                Text(session.timestamp, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(session.score) pts")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                        }
                                        .padding()
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatsTab()
}
