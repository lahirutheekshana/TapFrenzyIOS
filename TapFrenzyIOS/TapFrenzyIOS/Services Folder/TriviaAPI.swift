import Foundation


class QuizService {
    private let apiUrlString = "https://opentdb.com/api.php?amount=10&type=multiple"
    
    
    func fetchTriviaQuestions() async throws -> [Question] {
        guard let url = URL(string: apiUrlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(QuizResponse.self, from: data)
        
        return decodedResponse.results
    }
}
