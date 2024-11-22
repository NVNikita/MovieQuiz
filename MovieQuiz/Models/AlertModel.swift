//
//  AlertModel.swift
//  MovieQuiz
//
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var comletion: (() -> Void)?
}
