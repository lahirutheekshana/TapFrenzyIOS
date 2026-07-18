import SwiftUI
import Charts

struct StatsTab: View {
  
    @ObservedObject var manager = GameSessionManager.shared
    @AppStorage("username") var username: String = "Player"
    @State private var selectedMode: SessionGameMode = .tapFrenzy
    
    // Dark theme colors
    private let darkBg = Color(red: 0.07, green: 0.07, blue: 0.12)
    private let cardBg = Color(red: 0.11, green: 0.11, blue: 0.18)
    private let neonCyan = Color(red: 0.0, green: 0.9, blue: 0.95)
    private let neonPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    private let neonPink = Color(red: 1.0, green: 0.2, blue: 0.6)
    private let neonGreen = Color(red: 0.2, green: 1.0, blue: 0.4)
    
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
                // Dark gradient background
                LinearGradient(
                    colors: [darkBg, Color(red: 0.05, green: 0.05, blue: 0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Welcome header with neon glow
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome Back,")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Text(username)
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [neonCyan, neonPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        Spacer()
                        
                        // Neon avatar circle
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [neonCyan, neonPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: neonCyan.opacity(0.5), radius: 10)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
                    
                    if manager.sessions.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "gamecontroller")
                                .font(.system(size: 60))
                                .foregroundColor(neonCyan.opacity(0.5))
                                .shadow(color: neonCyan.opacity(0.3), radius: 15)
                            Text("No Games Played Yet!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Play a game to see your statistics here.")
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Summary Cards
                                HStack(spacing: 14) {
                                    NeonStatCard(
                                        title: "Total Sessions",
                                        value: "\(totalSessions)",
                                        icon: "play.circle.fill",
                                        gradientColors: [neonCyan, Color(red: 0.1, green: 0.5, blue: 0.9)],
                                        glowColor: neonCyan
                                    )
                                    NeonStatCard(
                                        title: "Total Points",
                                        value: "\(totalPoints)",
                                        icon: "star.fill",
                                        gradientColors: [neonPink, neonPurple],
                                        glowColor: neonPink
                                    )
                                }
                                .padding(.horizontal)

                                // Charts Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("SCORES BY MODE")
                                        .font(.caption)
                                        .fontWeight(.heavy)
                                        .foregroundColor(neonCyan.opacity(0.8))
                                        .tracking(2)
                                        .padding(.horizontal)

                                    // Custom segmented picker
                                    HStack(spacing: 8) {
                                        ForEach(SessionGameMode.allCases, id: \.self) { mode in
                                            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedMode = mode } }) {
                                                Text(mode.rawValue)
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.45))
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(selectedMode == mode
                                                                  ? LinearGradient(colors: neonGradientForMode(mode), startPoint: .leading, endPoint: .trailing)
                                                                  : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.06)], startPoint: .leading, endPoint: .trailing))
                                                    )
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(selectedMode == mode ? neonGradientForMode(mode).first!.opacity(0.6) : Color.clear, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
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
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: neonGradientForMode(selectedMode),
                                                            startPoint: .bottom,
                                                            endPoint: .top
                                                        )
                                                    )
                                                    .cornerRadius(6)
                                                    .annotation(position: .top) {
                                                        Text("\(session.score)")
                                                            .font(.caption2)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white.opacity(0.7))
                                                    }
                                                }
                                            }
                                            .chartLegend(.hidden)
                                            .chartXAxis {
                                                AxisMarks { _ in
                                                    AxisValueLabel()
                                                        .foregroundStyle(Color.white.opacity(0.5))
                                                }
                                            }
                                            .chartYAxis {
                                                AxisMarks { _ in
                                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                                        .foregroundStyle(Color.white.opacity(0.1))
                                                    AxisValueLabel()
                                                        .foregroundStyle(Color.white.opacity(0.5))
                                                }
                                            }
                                        } else {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("No data for \(selectedMode.rawValue)")
                                                    .foregroundColor(.white.opacity(0.4))
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .frame(height: 220)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(cardBg)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [neonGradientForMode(selectedMode).first!.opacity(0.3), Color.clear],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                    .shadow(color: neonGradientForMode(selectedMode).first!.opacity(0.15), radius: 12, x: 0, y: 4)
                                    .padding(.horizontal)
                                }

                                // Recent Games Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("RECENT GAMES")
                                        .font(.caption)
                                        .fontWeight(.heavy)
                                        .foregroundColor(neonCyan.opacity(0.8))
                                        .tracking(2)
                                        .padding(.horizontal)

                                    VStack(spacing: 10) {
                                        ForEach(recentGames) { session in
                                            HStack(spacing: 14) {
                                                // Neon icon badge
                                                Image(systemName: iconForMode(session.mode))
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: 42, height: 42)
                                                    .background(
                                                        Circle()
                                                            .fill(
                                                                LinearGradient(
                                                                    colors: gradientForMode(session.mode),
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                    )
                                                    .shadow(color: gradientForMode(session.mode).first!.opacity(0.5), radius: 8)
                                                
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(session.mode.rawValue)
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                    Text(session.timestamp, style: .date)
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.45))
                                                }

                                                Spacer()

                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text("\(session.score)")
                                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                                        .foregroundStyle(
                                                            LinearGradient(
                                                                colors: gradientForMode(session.mode),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                    Text("pts")
                                                        .font(.caption2)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white.opacity(0.4))
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(cardBg)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(
                                                                LinearGradient(
                                                                    colors: [gradientForMode(session.mode).first!.opacity(0.25), Color.clear],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                ),
                                                                lineWidth: 1
                                                            )
                                                    )
                                            )
                                            .shadow(color: gradientForMode(session.mode).first!.opacity(0.15), radius: 6, x: 0, y: 3)
                                        }
                                    }
                                    .padding(.horizontal)
                                }

                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Mode Styling Helpers
    
    private func iconForMode(_ mode: SessionGameMode) -> String {
        switch mode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "brain.head.profile"
        }
    }
    
    private func gradientForMode(_ mode: SessionGameMode) -> [Color] {
        switch mode {
        case .tapFrenzy:
            return [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.15, blue: 0.2)]
        case .lightItUp:
            return [Color(red: 0.5, green: 0.2, blue: 1.0), Color(red: 0.2, green: 0.6, blue: 1.0)]
        case .quizRush:
            return [Color(red: 0.0, green: 0.9, blue: 0.8), Color(red: 0.15, green: 0.7, blue: 0.4)]
        }
    }
    
    private func neonGradientForMode(_ mode: SessionGameMode) -> [Color] {
        switch mode {
        case .tapFrenzy:
            return [neonPink, Color(red: 1.0, green: 0.5, blue: 0.0)]
        case .lightItUp:
            return [neonPurple, neonCyan]
        case .quizRush:
            return [neonGreen, neonCyan]
        }
    }
    
    private func shadowColorForMode(_ mode: SessionGameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color.orange.opacity(0.3)
        case .lightItUp: return Color.purple.opacity(0.3)
        case .quizRush: return Color.teal.opacity(0.3)
        }
    }
}

// MARK: - Neon Stat Card

struct NeonStatCard: View {
    var title: String
    var value: String
    var icon: String
    var gradientColors: [Color]
    var glowColor: Color
    
    private let cardBg = Color(red: 0.11, green: 0.11, blue: 0.18)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: glowColor.opacity(0.6), radius: 8)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [gradientColors.first!.opacity(0.4), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: glowColor.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    StatsTab()
}
