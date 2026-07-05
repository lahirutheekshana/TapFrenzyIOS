import SwiftUI
import Combine

struct LightItUpView: View {
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var currentLevel: GameLevel = .L1
    @State private var roundTimeRemaining = 60
    @State private var isGameActive = false
    @State private var isGameOver = false
   
   
    @State private var showLevelUpFlash = false
   
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
   
    
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var litTimer: Timer? = nil
   
    
    var columns: [GridItem] {
        switch currentLevel {
        case .L1, .L2:
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
        case .L3, .L4:
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
        }
    }
   
    var body: some View {
        ZStack {
            
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
           
            VStack(spacing: 20) {
            
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE: \(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                       
                        Text("HIGH: \(highScore)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                   
                    Spacer()
                   
                    
                    Text("LEVEL \(currentLevel.rawValue)")
                        .font(.headline)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(currentLevel.glowColor.opacity(0.2))
                        .foregroundColor(currentLevel.glowColor)
                        .clipShape(Capsule())
                   
                    Spacer()
                   
                    
                    VStack(alignment: .trailing) {
                        Text("⏱️ \(roundTimeRemaining)s")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(roundTimeRemaining <= 10 ? .red : .primary)
                       
                        
                        HStack(spacing: 3) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)
               
                Spacer()
               
                // Content Switcher Area
                if !isGameActive && !isGameOver {
                    // Start Button Screen
                    Button(action: startGame) {
                        Text("START GAME")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220)
                            .background(Color.blue.gradient)
                            .cornerRadius(50)
                            .shadow(radius: 5)
                    }
                } else if isGameOver {
                    // Game Over Screen
                    VStack(spacing: 15) {
                        Text("GAME OVER ")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.red)
                       
                        Text("Final Score: \(score)")
                            .font(.title3)
                            .fontWeight(.semibold)
                       
                        if score > highScore {
                            Text(" NEW HIGH SCORE! ")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                       
                        Button(action: startGame) {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180)
                                .background(Color.primary)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding(30)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                } else {
                
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(0..<cards.count, id: \.self) { index in
                            let card = cards[index]
                           
                            RoundedRectangle(cornerRadius: 15)
                                .fill(card.isLit ? currentLevel.glowColor.gradient : Color(.tertiarySystemGroupedBackground).gradient)
                                .frame(height: 100)
                                
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .shadow(color: card.isLit ? currentLevel.glowColor.opacity(0.6) : .clear, radius: card.isLit ? 12 : 0)
                                .overlay(
                                    Image(systemName: card.isLit ? "lightbulb.fill" : "lightbulb")
                                        .font(.title)
                                        .foregroundColor(card.isLit ? .white : .secondary.opacity(0.4))
                                )
                                .onTapGesture {
                                    handleTap(at: index)
                                }
                                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: card.isLit)
                        }
                    }
                    .padding(25)
                }
               
                Spacer()
            }
           
            
            if showLevelUpFlash {
                Color.white
                    .ignoresSafeArea()
                    .opacity(0.4)
                    .transition(.opacity)
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { stopLitTimer() }
        .onReceive(gameTimer) { _ in
            guard isGameActive else { return }
           
            if roundTimeRemaining > 0 {
                roundTimeRemaining -= 1
                updateLevelProgression()
            } else {
                endGame()
            }
        }
    }
   
   
   
    func startGame() {
        score = 0
        lives = 3
        currentLevel = .L1
        roundTimeRemaining = 60
        isGameOver = false
        setupCards()
        isGameActive = true
        startLitTimer()
    }
   
    func setupCards() {
        cards = Array(repeating: Card(), count: currentLevel.cardCount)
    }
   
    
    func updateLevelProgression() {
        let elapsedTime = 60 - roundTimeRemaining
        var nextLevel = GameLevel.L1
       
        if elapsedTime >= 45 {
            nextLevel = .L4
        } else if elapsedTime >= 30 {
            nextLevel = .L3
        } else if elapsedTime >= 15 {
            nextLevel = .L2
        }
       
       
        if nextLevel != currentLevel {
            currentLevel = nextLevel
            setupCards()
            startLitTimer()
           
            
            withAnimation(.easeOut(duration: 0.15)) {
                showLevelUpFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeIn(duration: 0.15)) {
                    showLevelUpFlash = false
                }
            }
        }
    }
   
    
    func startLitTimer() {
        stopLitTimer()
       
        litTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litDuration, repeats: true) { _ in
            guard isGameActive else { return }
           
            
            for i in 0..<cards.count {
                cards[i].isLit = false
            }
           
            
            if !cards.isEmpty {
                let randomIndex = Int.random(in: 0..<cards.count)
                cards[randomIndex].isLit = true
               
                
                if currentLevel == .L4 && cards.count > 1 {
                    var secondRandomIndex = Int.random(in: 0..<cards.count)
                    while secondRandomIndex == randomIndex {
                        secondRandomIndex = Int.random(in: 0..<cards.count)
                    }
                    cards[secondRandomIndex].isLit = true
                }
            }
        }
    }
   
    func stopLitTimer() {
        litTimer?.invalidate()
        litTimer = nil
    }
   
    
    func handleTap(at index: Int) {
        guard isGameActive else { return }
       
        if cards[index].isLit {
            
            score += 10
            cards[index].isLit = false
        } else {
            
            if lives > 1 {
                lives -= 1
            } else {
                lives = 0
                endGame()
            }
        }
    }
   
    func endGame() {
        isGameActive = false
        isGameOver = true
        stopLitTimer()
        if score > highScore {
            highScore = score
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
