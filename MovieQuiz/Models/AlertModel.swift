//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Никита Нагорный on 14.11.2024.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var comletion: (() -> Void)?
}
