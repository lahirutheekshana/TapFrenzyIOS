import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @AppStorage("quizRushHighScore") private var highScore = 0
    
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
                    } else {
                        activeQuizScreen()
                    }
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchQuestions()
        }
    }
    
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
            
            Button(action: {
                Task { await viewModel.fetchQuestions() }
            }) {
                Text("Play Again")
                    .foregroundColor(.white).padding()
                    .frame(width: 180).background(Color.primary).cornerRadius(12)
            }
        }
        .padding(30).background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(25).shadow(radius: 10)
        .onAppear {
            if viewModel.score > highScore { highScore = viewModel.score }
        }
    }
    
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
