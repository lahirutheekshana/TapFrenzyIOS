import SwiftUI
import Charts

struct StatsTab: View {
    let sessions: [GameSession]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Game Statistics")
                    .font(.largeTitle)
                    .bold()
                
                // දත්ත තියෙනවද බලමු
                if sessions.isEmpty {
                    Text("තවම ගේම් එකක් ප්ලේ කරලා නැහැ! 🎮")
                        .padding()
                } else {
                    Chart {
                        ForEach(sessions) { session in
                            BarMark(
                                x: .value("Date", session.timestamp, unit: .day),
                                y: .value("Score", session.score)
                            )
                            .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                        }
                    }
                    .frame(height: 300)
                    .padding()
                }
                Spacer()
            }
            .navigationTitle("Stats")
        }
    }
}
