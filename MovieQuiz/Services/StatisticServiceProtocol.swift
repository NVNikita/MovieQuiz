//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//

import UIKit

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get set }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
}
