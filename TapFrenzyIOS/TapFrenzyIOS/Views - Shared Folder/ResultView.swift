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
            
            
            ShareLink(
                item: "මම \(gameMode) ගේම් එකේදී ලකුණු \(score)ක් ලබා ගත්තා! ඔයාට පුළුවන්ද මේක පරද්දන්න? ",
                subject: Text("My Score!"),
                message: Text("Check out my score!")
            ) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
