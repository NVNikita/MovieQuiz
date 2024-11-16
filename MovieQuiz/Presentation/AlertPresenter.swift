//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Никита Нагорный on 14.11.2024.
//

import UIKit

class AlertPresenter {
    func showAlert( view: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.comletion?()
        }
        
        alert.addAction(action)
        
        view.present(alert, animated: true, completion: nil)
    }
}
