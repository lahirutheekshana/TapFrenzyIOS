import Foundation
import SwiftUI
import Combine

enum QuizState {
    case loading, loaded, failed
}

enum AnswerFeedback {
    case correct, wrong, none
}

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var gameState: QuizState = .loading
    @Published var isQuizOver = false
    @Published var shuffledAnswersForCurrentQuestion: [String] = []
    
    
    @Published var answerFeedback: AnswerFeedback = .none
    @Published var isAnswerLocked = false
    @Published var selectedAnswer: String? = nil
    
    
    private let quizService = QuizService()
    
    func fetchQuestions() async {
        gameState = .loading
        isQuizOver = false
        currentIndex = 0
        score = 0
        streak = 0
        answerFeedback = .none
        isAnswerLocked = false
        selectedAnswer = nil
        
        do {
            
            let fetchedQuestions = try await quizService.fetchTriviaQuestions()
            
            if !fetchedQuestions.isEmpty {
                self.questions = fetchedQuestions
                self.gameState = .loaded
                self.loadCurrentQuestionAnswers()
            } else {
                self.gameState = .failed
            }
        } catch {
            print("Error fetching quiz: \(error)")
            self.gameState = .failed
        }
    }
    
    func loadCurrentQuestionAnswers() {
        guard currentIndex < questions.count else {
            print(" loadCurrentQuestionAnswers: currentIndex \(currentIndex) out of range for \(questions.count) questions")
            return
        }
        let answers = questions[currentIndex].allAnswers
        print(" loadCurrentQuestionAnswers: loaded \(answers.count) answers for question \(currentIndex)")
        shuffledAnswersForCurrentQuestion = answers
    }
    
    func answerSelected(_ selectedAnswer: String) {
        guard !isAnswerLocked else { return }
        isAnswerLocked = true
        self.selectedAnswer = selectedAnswer
        
        let correctAnswer = questions[currentIndex].correctAnswer.htmlDecoded
        
        if selectedAnswer == correctAnswer {
            
            streak += 1
            let bonus = streak >= 3 ? 5 : 0
            score += 10 + bonus
            answerFeedback = .correct
        } else {
            // Wrong Answer Logic
            streak = 0
            if score >= 2 { score -= 2 }
            answerFeedback = .wrong
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.moveToNextQuestion()
        }
    }
    
    private func moveToNextQuestion() {
        self.answerFeedback = .none
        self.isAnswerLocked = false
        self.selectedAnswer = nil
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            loadCurrentQuestionAnswers()
        } else {
            isQuizOver = true
        }
    }
}
