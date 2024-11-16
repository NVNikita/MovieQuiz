//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Никита Нагорный on 16.11.2024.
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
