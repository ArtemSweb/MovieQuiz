import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswers
        case totalQuestions
    }
    
    var gamesCount: Int {
        get { return storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correctAnswers, total: totalQuestions, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey:Keys.correctAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestions > 0 else { return 0 }
        
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    func store(_ gameResult: GameResult) {
        // кол-во игр
        gamesCount += 1
        
        // апдейт общее количество правильных ответов и вопросов
        let updatedCorrectAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue) + gameResult.correct
        let updatedTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + gameResult.total
        
        storage.set(updatedCorrectAnswers, forKey: Keys.correctAnswers.rawValue)
        storage.set(updatedTotalQuestions, forKey: Keys.totalQuestions.rawValue)
        
        // чекаем и аплдейтим лучший результат, если текущий результат лучше
        let currentGame = GameResult(correct: gameResult.correct, total: gameResult.total, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
