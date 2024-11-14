//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Никита Нагорный on 13.11.2024.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
