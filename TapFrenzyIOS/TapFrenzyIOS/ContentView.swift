import SwiftUI
internal import Combine

struct ContentView: View {
    // --- GAME STATES ---
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    @State private var isGameStarted = false
   
    // --- CHALLENGE STATES ---
    // Target Challenge: Button එකේ පිහිටීම
    @State private var buttonPosition = CGPoint(x: 180, y: 350)
    // Shrinking Challenge: ඉතිරි කාලය අනුව scale එක වෙනස් වීම
    private var buttonScale: CGFloat {
        if timeRemaining > 5 {
            return 1.0
        } else if timeRemaining > 2 {
            return 0.75
        } else {
            return 0.5 // අවසාන තත්පර වලදී ගොඩක් කුඩා වේ
        }
    }
   
    // --- TIMERS ---
    // ප්‍රධාන තත්පර 10 කවුන්ටරය
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Target Challenge එක සඳහා තත්පර 2ක ටයිමරය
    let motionTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
   
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
               
                if !isGameStarted {
                    // 1. START SCREEN
                    VStack(spacing: 20) {
                        Text("⚡ Tap Frenzy ⚡")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(.blue)
                       
                        Text("Tap the button as fast as you can in 10 seconds!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                       
                        Button(action: startGame) {
                            Text("START GAME")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.blue)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                    }
                } else if !isGameOver {
                    // 2. ACTIVE GAME SCREEN
                    VStack {
                        // Top Bar: Score & Timer
                        HStack {
                            VStack(alignment: .leading) {
                                Text("SCORE")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(score)")
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                           
                            Spacer()
                           
                            VStack(alignment: .trailing) {
                                Text("TIME LEFT")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(timeRemaining)s")
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(timeRemaining <= 3 ? .red : .orange)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(15)
                        .padding()
                       
                        Spacer()
                       
                        // Main Game Area (Moving and Shrinking Button)
                        ZStack {
                            Button(action: {
                                handleTap()
                                // Tap එකක් කරපු ගමන්ම තැන වෙනස් කරන්නත් පුළුවන් (Optional)
                                moveButton(in: geometry.size)
                            }) {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(buttonScale) // Challenge: Shrinking Button
                                    .overlay(
                                        Text("TAP!")
                                            .font(.title2)
                                            .fontWeight(.black)
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: Color.accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            .position(buttonPosition) // Challenge: Moving Target
                            // Smooth animation එකක් ලබා දීම
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: buttonPosition)
                            .animation(.easeInOut, value: buttonScale)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    // ටයිමර් මඟින් දත්ත ලබා ගැනීම
                    .onReceive(gameTimer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        } else {
                            isGameOver = true
                        }
                    }
                    // Target Challenge: තත්පර 2න් 2ට බොත්තම වෙනස් තැනකට යැවීම
                    .onReceive(motionTimer) { _ in
                        moveButton(in: geometry.size)
                    }
                } else {
                    // 3. GAME OVER SCREEN
                    VStack(spacing: 25) {
                        Text("Game Over! 🏁")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                       
                        VStack(spacing: 5) {
                            Text("YOUR FINAL SCORE")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(score)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                       
                        Button(action: resetGame) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220)
                            .background(Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                    }
                }
            }
            .onAppear {
                // මුලින්ම Button එක screen එකේ මැදට සෙට් කිරීම
                buttonPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
   
    // --- GAME LOGIC FUNCTIONS ---
   
    func startGame() {
        score = 0
        timeRemaining = 10
        isGameOver = false
        isGameStarted = true
    }
   
    func handleTap() {
        if timeRemaining > 0 {
            score += 1
        }
    }
   
    // Target Challenge: Safe Area එක ඇතුළත random තැනක් තෝරාගැනීම
    func moveButton(in size: CGSize) {
        let padding: CGFloat = 80
        let minX = padding
        let maxX = size.width - padding
        let minY = padding + 100 // Top bar එකට අහු නොවෙන්න
        let maxY = size.height - padding
       
        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)
       
        buttonPosition = CGPoint(x: randomX, y: randomY)
    }
   
    func resetGame() {
        startGame()
    }
}

// Preview Preview window එක සඳහා
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
