//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Никита Нагорный on 16.11.2024.
//


//UIKit содежит Foundation - поэтому везде импортирую эту библу в проекте
import UIKit

final class StatisticService: StatisticServiceProtocol {
    // сокращение для читаемости и упрощения кода (убрали дублирование кода)
    private let storage: UserDefaults = .standard
    
    // создали энумчики для ключей что бы избежать опечаток при записи/чтении
    private enum Keys: String {
        case gamesCount
        case correctAnswersBest
        case totalQuestionsBest
        case dataGameBest
        case correctAnswers
        case totalQuestions
    }
    
    var gamesCount: Int {
        get {return storage.integer(forKey: Keys.gamesCount.rawValue)}
        set {storage.set(newValue, forKey: Keys.gamesCount.rawValue)}
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswersBest.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalQuestionsBest.rawValue)
            // распакововываем дату
            let dateGameBest = storage.object(forKey: Keys.dataGameBest.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correctAnswers, total: totalQuestions, date: dateGameBest)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswersBest.rawValue)
            storage.set(newValue, forKey: Keys.totalQuestionsBest.rawValue)
            storage.set(newValue, forKey: Keys.dataGameBest.rawValue)
        }
    }
    
    var totalAccuracy: Double{
        let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        // проерка на 0 (избежания краша при делении на 0)
        guard totalQuestions > 0 else { return 0 }
        
        return Double((correctAnswers / (gamesCount * 10)) * 100)
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        // получиили кол-во правильных вопросов и ответои и обновили
        let updateCorrectQuestions = storage.integer(forKey: Keys.correctAnswers.rawValue) + count
        let updateTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        
        // перезаписали новые данные в память
        storage.set(updateCorrectQuestions, forKey: Keys.correctAnswers.rawValue)
        storage.set(updateTotalQuestions, forKey: Keys.totalQuestions.rawValue)
        
        // проверка на получение лучшего результата c последующей записью в память
        let game = GameResult(correct: count, total: amount, date: Date())
        if game.isRecord(bestGame) { bestGame = game }
    }
    
    
}


