import SwiftUI
import Charts

struct StatsTab: View {
    // ඔයාගේ saved sessions මෙතනට Load වෙන්න ඕනේ
    let sessions: [GameSession]
        
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Game Statistics")
                    .font(.largeTitle)
                    .bold()
                
                // Chart එක මෙතනින් පටන් ගන්නවා
                Chart {
                    ForEach(sessions) { session in
                        BarMark(
                            x: .value("Game", session.timestamp, unit: .day),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                    }
                }
                .frame(height: 300)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Stats")
        }
    }
}
