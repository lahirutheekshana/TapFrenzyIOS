import SwiftUI
import Combine
internal import _LocationEssentials

struct TapFrenzyView: View {
    
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = false
    @State private var isGameOver = false
   
    
    @State private var comboMultiplier = 1
    @State private var lastTapTime = Date()
    @State private var buttonScale: CGFloat = 1.0
   
        @AppStorage("tapFrenzyHighScore") private var highScore = 0
   

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
   
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.red.opacity(0.15)]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
           
            VStack(spacing: 30) {
                // Header Display (Score & High Score)
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                    }
                   
                    Spacer()
                   
                    VStack(alignment: .trailing) {
                        Text("HIGH SCORE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("\(highScore)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top,
                        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20)
                HStack(spacing: 40) {
                    // Countdown Timer Display
                    VStack {
                        Text("TIME")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("\(timeRemaining)s")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(timeRemaining <= 3 ? .red : .primary)
                    }
                    .padding()
                    .frame(minWidth: 100)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                   
                    // Combo Multiplier Display (Challenge 1)
                    VStack {
                        Text("COMBO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("x\(comboMultiplier)")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(comboMultiplier > 1 ? .red : .gray)
                    }
                    .padding()
                    .frame(minWidth: 100)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                }
               
                Spacer()
               
                // Main Interaction Area
                if !isGameActive && !isGameOver {
                    // Start Game Screen
                    Button(action: startGame) {
                        Text("START GAME")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220)
                            .background(Color.orange.gradient)
                            .cornerRadius(50)
                            .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                } else if isGameOver {
                    // Game Over View
                    VStack(spacing: 20) {
                        Text("GAME OVER")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                       
                        Text("Final Score: \(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                       
                        if score > highScore {
                            Text("New High Score! ")
                                .font(.headline)
                                .foregroundColor(.green)
                                .transition(.scale)
                        }
                       
                        ShareLink("Share Score", item: "I just scored \(score) on Tap Frenzy — beat that")
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        
                        Button(action: startGame) {
                            HStack {
                                Text("Play Again")
                            }
                            .font(.headline)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .padding()
                            .frame(width: 200)
                            .background(Color.primary)
                            .cornerRadius(15)
                        }
                        .padding(.top, 5)
                    }
                    .padding(30)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .onAppear(perform: updateHighScore)
                } else {
                    
                    Button(action: handleTap) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.gradient)
                                .frame(width: 180, height: 180)
                                .shadow(color: .orange.opacity(0.5), radius: 15, x: 0, y: 10)
                           
                            VStack(spacing: 4) {
                                Text("TAP!")
                                    .font(.system(size: 34, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("+\(comboMultiplier)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                   
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: buttonScale)
                }
               
                Spacer()
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        
        .onReceive(timer) { _ in
            guard isGameActive else { return }
           
            if timeRemaining > 0 {
                timeRemaining -= 1
               
               
                withAnimation {
                    buttonScale = CGFloat(timeRemaining) / 10.0 * 0.4 + 0.6
                }
            } else {
                isGameActive = false
                isGameOver = true
                let lat = LocationService.shared.currentLocation?.coordinate.latitude ?? 6.9271
                let lon = LocationService.shared.currentLocation?.coordinate.longitude ?? 79.8612
                let session = GameSession(mode: .tapFrenzy, score: score, timestamp: Date(), latitude: lat, longitude: lon)
                GameSessionManager.shared.saveSession(session: session)
            }
        }
    }
   
   
    
    func startGame() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        buttonScale = 1.0
        isGameOver = false
        isGameActive = true
        lastTapTime = Date()
    }
   
    func handleTap() {
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastTapTime)
       
        if timeInterval < 0.5 {
            if comboMultiplier < 5 {
                comboMultiplier += 1
            }
        } else {
            comboMultiplier = 1
        }
       
        score += comboMultiplier
        lastTapTime = now
       
        
        withAnimation(.easeInOut) {
            buttonScale -= 0.05
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                buttonScale += 0.05
            }
        }
    }
   
    
    func updateHighScore() {
        if score > highScore {
            highScore = score
        }
    }
}

#Preview {
    NavigationStack {
        TapFrenzyView()
    }
}

