import UIKit

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case countGames
        case correctBest
        case totalBest
        case bestGameDate
        case allCorrectAnswers
        case allTotalQuestions
    }
    
    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey: "allCorrectAnswers")
        
        guard correctAnswers != 0 else { return 0 }
        
        return Double(correctAnswers) / Double(gamesCount * 10) * 100.0
    }
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.countGames.rawValue) }
        set { storage.set(newValue, forKey: Keys.countGames.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctBest.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalBest.rawValue)
            let dateGame = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correctAnswers, total: totalQuestions, date: dateGame)
        }
        set {
            storage.set(newValue, forKey: Keys.correctBest.rawValue)
            storage.set(newValue, forKey: Keys.totalBest.rawValue)
            storage.set(newValue, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // счетчик игр +1
        gamesCount += 1
        
        // получили данные
        let newAllCorrectAnswers = storage.integer(forKey: Keys.allCorrectAnswers.rawValue) + count
        let newAllTotalQuestions = storage.integer(forKey: Keys.allTotalQuestions.rawValue) + amount
        let timeGame = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
        
        //перезаписали данные
        storage.set(newAllCorrectAnswers, forKey: Keys.allCorrectAnswers.rawValue)
        storage.set(newAllTotalQuestions, forKey: Keys.allTotalQuestions.rawValue)
        
        // сравниваем лучший результат и записываем новые, если результат лучше рекорда
        let game = GameResult(correct: count, total: amount, date: Date())
        if game.isRecord(bestGame) {
            storage.set(count, forKey: Keys.correctBest.rawValue)
            storage.set(amount, forKey: Keys.totalBest.rawValue)
            storage.set(timeGame, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    
}
