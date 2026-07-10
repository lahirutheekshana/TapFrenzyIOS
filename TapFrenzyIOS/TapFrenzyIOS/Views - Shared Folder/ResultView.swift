import SwiftUI

struct ResultView: View {
    let score: Int
    let gameMode: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.largeTitle)
                .bold()
            
            Text("Your Score: \(score)")
                .font(.title)
            
            
            ShareLink("Share Score", item: "I just scored \(score) on \(gameMode) — beat that")
                .buttonStyle(.borderedProminent)
        }
    }
}
