import SwiftUI
import Combine
internal import _LocationEssentials

struct TapFrenzyView: View {
    
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = false
    @State private var isGameOver = false
    @State private var isCountingDown = false
    @State private var countdownValue = 3
    @State private var showGo = false
   
    
    @State private var comboMultiplier = 1
    @State private var lastTapTime = Date()
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonColor: Color = .orange
    @State private var buttonOffset: CGSize = .zero
   
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
                if isCountingDown {
                    if showGo {
                        Text("GO!")
                            .font(.system(size: 120, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.8), radius: 20, x: 0, y: 10)
                            .transition(.scale(scale: 2).combined(with: .opacity))
                    } else {
                        Text("\(countdownValue)")
                            .font(.system(size: 150, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.8), radius: 20, x: 0, y: 10)
                            .id(countdownValue)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 1.5).combined(with: .opacity),
                                removal: .scale(scale: 0.5).combined(with: .opacity)
                            ))
                    }
                } else if !isGameActive && !isGameOver {
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
                                .fill(buttonColor.gradient)
                                .frame(width: 180, height: 180)
                                .shadow(color: buttonColor.opacity(0.5), radius: 15, x: 0, y: 10)
                           
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
                    .offset(buttonOffset)
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: buttonScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonOffset)
                    .animation(.easeInOut(duration: 0.2), value: buttonColor)
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
                
                AudioHapticManager.shared.playNotificationHaptic(type: .warning)
                AudioHapticManager.shared.playGameOverSound()
                
                let lat = LocationService.shared.currentLocation?.coordinate.latitude ?? 6.9271
                let lon = LocationService.shared.currentLocation?.coordinate.longitude ?? 79.8612
                let session = GameSession(mode: .tapFrenzy, score: score, timestamp: Date(), latitude: lat, longitude: lon)
                GameSessionManager.shared.saveSession(session: session)
            }
        }
    }
   
   
    
    func startGame() {
        AudioHapticManager.shared.playTapHaptic(style: .medium)
        
        withAnimation {
            isGameOver = false
            isCountingDown = true
            countdownValue = 3
            showGo = false
        }
        
        startCountdown()
    }
    
    func startCountdown() {
        if countdownValue > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                AudioHapticManager.shared.playTapSound()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    countdownValue -= 1
                }
                startCountdown()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                AudioHapticManager.shared.playSuccessSound()
                AudioHapticManager.shared.playTapHaptic(style: .heavy)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    showGo = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        isCountingDown = false
                        showGo = false
                        
                        score = 0
                        timeRemaining = 10
                        comboMultiplier = 1
                        buttonScale = 1.0
                        buttonColor = .orange
                        buttonOffset = .zero
                        isGameActive = true
                        lastTapTime = Date()
                    }
                }
            }
        }
    }
   
    func handleTap() {
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastTapTime)
        
        AudioHapticManager.shared.playTapSound()
        if comboMultiplier >= 4 {
            AudioHapticManager.shared.playTapHaptic(style: .heavy)
        } else {
            AudioHapticManager.shared.playTapHaptic(style: .medium)
        }
       
        if timeInterval < 0.5 {
            if comboMultiplier < 5 {
                comboMultiplier += 1
            }
        } else {
            comboMultiplier = 1
        }
       
        score += comboMultiplier
        lastTapTime = now
       
        let colors: [Color] = [.orange, .red, .blue, .green, .purple, .pink, .yellow, .cyan]
        buttonColor = colors.randomElement() ?? .orange
        
        let randomX = CGFloat.random(in: -100...100)
        let randomY = CGFloat.random(in: -150...150)
        buttonOffset = CGSize(width: randomX, height: randomY)
        
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

