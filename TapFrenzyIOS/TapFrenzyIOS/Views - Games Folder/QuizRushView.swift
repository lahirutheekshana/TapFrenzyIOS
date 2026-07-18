import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @AppStorage("quizRushHighScore") private var highScore = 0
    
    // Countdown state
    @State private var isCountingDown = false
    @State private var countdownValue = 3
    @State private var showGo = false
    @State private var quizStarted = false
    
    var body: some View {
        ZStack {
           
            backgroundColorForFeedback()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: viewModel.answerFeedback)
            
            VStack {
                switch viewModel.gameState {
                case .loading:
                    VStack(spacing: 15) {
                        ProgressView().scaleEffect(1.5)
                        Text("Fetching Trivia Questions...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                case .failed:
                    VStack(spacing: 20) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Connection Failed")
                            .font(.title3).fontWeight(.bold)
                        Button(action: {
                            Task { await viewModel.fetchQuestions() }
                        }) {
                            Text("Retry")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 140)
                                .background(Color.purple)
                                .cornerRadius(12)
                        }
                    }
                    
                case .loaded:
                    if viewModel.isQuizOver {
                        gameOverScreen()
                    } else if !quizStarted && !isCountingDown {
                        // Ready screen — questions loaded, waiting to start
                        readyScreen()
                    } else {
                        activeQuizScreen()
                    }
                }
            }
            
            // Countdown overlay
            if isCountingDown {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                if showGo {
                    Text("GO!")
                        .font(.system(size: 120, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.8), radius: 20, x: 0, y: 10)
                        .transition(.scale(scale: 2).combined(with: .opacity))
                } else {
                    Text("\(countdownValue)")
                        .font(.system(size: 150, weight: .black, design: .rounded))
                        .foregroundColor(.purple)
                        .shadow(color: .purple.opacity(0.8), radius: 20, x: 0, y: 10)
                        .id(countdownValue)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.5).combined(with: .opacity),
                            removal: .scale(scale: 0.5).combined(with: .opacity)
                        ))
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchQuestions()
        }
    }
    
    // MARK: - Ready Screen
    private func readyScreen() -> some View {
        let quizSessions = GameSessionManager.shared.sessions.filter { $0.mode == .quizRush }
        let totalPlayed = quizSessions.count
        let bestScore = quizSessions.map(\.score).max() ?? highScore
        
        return VStack(spacing: 20) {
            // Stats cards row
            HStack(spacing: 14) {
                // Card 1: Total Games
                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(totalPlayed)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Games Played")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.23, blue: 0.9),
                                 Color(red: 0.35, green: 0.1, blue: 0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.purple.opacity(0.35), radius: 8, x: 0, y: 4)
                
                // Card 2: Highest Score
                VStack(spacing: 10) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(bestScore)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Best Score")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.5, blue: 0.1),
                                 Color(red: 0.85, green: 0.25, blue: 0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.orange.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            // Questions ready badge
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundColor(.purple)
                Text("\(viewModel.questions.count) Questions Ready")
                    .font(.headline).fontWeight(.bold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(15)
            
            // Subtitle
            Text("Test your trivia knowledge!")
                .font(.subheadline).foregroundColor(.secondary)
            
            // Start button
            Button(action: startCountdownSequence) {
                Text("START QUIZ")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220)
                    .background(Color.purple.gradient)
                    .cornerRadius(50)
                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.vertical, 25)

    }
    
    // MARK: - Game Over Screen
    private func gameOverScreen() -> some View {
        VStack(spacing: 20) {
            Text("QUIZ COMPLETED")
                .font(.title).fontWeight(.black).foregroundColor(.purple)
            Text("Final Score: \(viewModel.score)")
                .font(.title2).fontWeight(.bold)
            
            if viewModel.score > highScore {
                Text(" NEW HIGH SCORE!")
                    .font(.headline).foregroundColor(.green)
            } else {
                Text("High Score: \(highScore)")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            
            ShareLink("Share Score", item: "I just scored \(viewModel.score) on Quiz Rush — beat that")
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
            Button(action: {
                Task {
                    quizStarted = false
                    await viewModel.fetchQuestions()
                }
            }) {
                Text("Play Again")
                    .foregroundColor(Color(UIColor.systemBackground)).padding()
                    .frame(width: 180).background(Color.primary).cornerRadius(12)
            }
        }
        .padding(30).background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(25).shadow(radius: 10)
        .onAppear {
            if viewModel.score > highScore { highScore = viewModel.score }
        }
    }
    
    // MARK: - Active Quiz Screen
    private func activeQuizScreen() -> some View {
        let currentQuestion = viewModel.questions[viewModel.currentIndex]
        
        return ScrollView {
            VStack(spacing: 20) {
            
                HStack {
                    Text("Q: \(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                        .fontWeight(.semibold).foregroundColor(.secondary)
                    Spacer()
                    if viewModel.streak >= 2 {
                        Text(" \(viewModel.streak) Streak")
                            .font(.caption).fontWeight(.bold).foregroundColor(.orange)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15)).cornerRadius(8)
                    }
                    Spacer()
                    Text("Score: \(viewModel.score)")
                        .font(.headline).foregroundColor(.purple)
                }
                .padding().background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(15).padding(.horizontal)
                
                
                VStack {
                    Text(currentQuestion.decodedQuestion)
                        .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)
                        .padding(25).frame(maxWidth: .infinity, minHeight: 150)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .offset(x: viewModel.answerFeedback == .wrong ? -10 : 0)
                .animation(viewModel.answerFeedback == .wrong ? .default.repeatCount(3).speed(3) : .default, value: viewModel.answerFeedback)
                
               
                VStack(spacing: 14) {
                    if viewModel.shuffledAnswersForCurrentQuestion.isEmpty {
                        
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading answers…")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button("Reload Answers") {
                                viewModel.loadCurrentQuestionAnswers()
                            }
                            .font(.footnote)
                        }
                        .padding()
                        .onAppear {
                            viewModel.loadCurrentQuestionAnswers()
                        }
                    } else {
                        ForEach(Array(viewModel.shuffledAnswersForCurrentQuestion.enumerated()), id: \.offset) { _, answer in
                            Button(action: {
                                viewModel.answerSelected(answer)
                            }) {
                                HStack {
                                    Text(answer)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    if viewModel.isAnswerLocked {
                                        if isCorrectAnswer(answer) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if answer == viewModel.selectedAnswer {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(buttonColor(for: answer))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .stroke(Color.purple.opacity(0.35), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
                            }
                            .disabled(viewModel.isAnswerLocked)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .foregroundStyle(Color.primary)
            }
            .padding(.top, 10)
        }
        .onChange(of: viewModel.currentIndex) { _, _ in
            if viewModel.shuffledAnswersForCurrentQuestion.isEmpty {
                viewModel.loadCurrentQuestionAnswers()
            }
        }
    }
    
    // MARK: - Countdown Logic
    
    func startCountdownSequence() {
        AudioHapticManager.shared.playTapHaptic(style: .medium)
        
        withAnimation {
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
                        quizStarted = true
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func backgroundColorForFeedback() -> Color {
        switch viewModel.answerFeedback {
        case .correct: return Color.green.opacity(0.3)
        case .wrong: return Color.red.opacity(0.2)
        case .none: return Color(.systemGroupedBackground)
        }
    }
    
    private func isCorrectAnswer(_ answer: String) -> Bool {
        guard viewModel.currentIndex < viewModel.questions.count else { return false }
        return answer == viewModel.questions[viewModel.currentIndex].correctAnswer.htmlDecoded
    }
    
    
    private func buttonColor(for answer: String) -> Color {
        if viewModel.isAnswerLocked {
            if isCorrectAnswer(answer) {
                
                return Color.green.opacity(0.35)
            } else if answer == viewModel.selectedAnswer {
                
                return Color.red.opacity(0.30)
            }
        }
        
        return Color(.secondarySystemBackground)
    }
}
