//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Никита Нагорный on 13.11.2024.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: (() -> Void)?
}
