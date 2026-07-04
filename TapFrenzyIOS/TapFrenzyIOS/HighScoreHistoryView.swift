import SwiftUI

struct HighScoreHistoryView: View {
    
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpScore = 0
    @AppStorage("quizRushHighScore") private var quizRushScore = 0
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(
                        color: .yellow.opacity(0.5),
                        radius: 15,
                        x: 0,
                        y: 10)
                    .padding(.top, 40)
                
                Text("Your Best Records")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
               
                VStack(spacing: 20) {
                    ScoreRowView(
                        gameName: "Tap Frenzy",
                        score: tapFrenzyScore,
                        icon: "hand.tap.fill",
                        color: .orange)
                    
                    ScoreRowView(
                        gameName: "Light It Up",
                        score: lightItUpScore,
                        icon: "lightbulb.fill",
                        color: .blue)
                    
                    ScoreRowView(
                        gameName: "Quiz Rush",
                        score: quizRushScore,
                        icon: "timer",
                        color: .purple)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ScoreRowView: View {
    let gameName: String
    let score: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Text(gameName)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(score)")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        HighScoreHistoryView()
    }
}
