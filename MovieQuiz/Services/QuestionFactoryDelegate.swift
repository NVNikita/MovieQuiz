//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
