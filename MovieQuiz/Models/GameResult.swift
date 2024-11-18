//
//  GameResult.swift
//  MovieQuiz
//
//

import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isRecord(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
