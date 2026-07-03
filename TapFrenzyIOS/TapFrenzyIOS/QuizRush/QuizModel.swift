import Foundation


struct QuizResponse: Codable {
    let results: [Question]
}


struct Question: Codable, Identifiable {
    var id: String { question }
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
   
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    var decodedQuestion: String {
        return question.htmlDecoded
    }
   
   
    var allAnswers: [String] {
        var answers = incorrectAnswers.map { $0.htmlDecoded }
        answers.append(correctAnswer.htmlDecoded)
        return answers.shuffled()
    }
}


extension String {
    var htmlDecoded: String {
        guard self.contains("&") else { return self }
        
        var decoded = self
        
        
        let namedEntities: [String: String] = [
            "&quot;": "\"", "&#039;": "'", "&apos;": "'", "&amp;": "&",
            "&lt;": "<", "&gt;": ">", "&nbsp;": " ",
            "&rsquo;": "\u{2019}", "&lsquo;": "\u{2018}",
            "&rdquo;": "\u{201D}", "&ldquo;": "\u{201C}",
            "&ndash;": "\u{2013}", "&mdash;": "\u{2014}", "&hellip;": "\u{2026}",
            "&eacute;": "é", "&egrave;": "è", "&ecirc;": "ê", "&euml;": "ë",
            "&uuml;": "ü", "&ouml;": "ö", "&auml;": "ä",
            "&Uuml;": "Ü", "&Ouml;": "Ö", "&Auml;": "Ä",
            "&ccedil;": "ç", "&ntilde;": "ñ", "&Ntilde;": "Ñ",
            "&aacute;": "á", "&iacute;": "í", "&oacute;": "ó", "&uacute;": "ú",
            "&Aacute;": "Á", "&Eacute;": "É", "&Iacute;": "Í", "&Oacute;": "Ó", "&Uacute;": "Ú"
        ]
        
        for (entity, character) in namedEntities where decoded.contains(entity) {
            decoded = decoded.replacingOccurrences(of: entity, with: character)
        }
        
        
        if decoded.contains("&#") {
            decoded = decoded.decodedNumericEntities()
        }
        
        return decoded
    }
    
    private func decodedNumericEntities() -> String {
        var result = ""
        let chars = Array(self)
        var i = 0
        while i < chars.count {
            if chars[i] == "&", i + 1 < chars.count, chars[i + 1] == "#",
               let semicolonOffset = chars[i...].firstIndex(of: ";") {
                let entityBody = String(chars[(i + 2)..<semicolonOffset])
                let scalarValue: UInt32?
                if entityBody.hasPrefix("x") || entityBody.hasPrefix("X") {
                    scalarValue = UInt32(entityBody.dropFirst(), radix: 16)
                } else {
                    scalarValue = UInt32(entityBody)
                }
                if let value = scalarValue, let scalar = Unicode.Scalar(value) {
                    result.append(Character(scalar))
                    i = semicolonOffset + 1
                    continue
                }
            }
            result.append(chars[i])
            i += 1
        }
        return result
    }
}
