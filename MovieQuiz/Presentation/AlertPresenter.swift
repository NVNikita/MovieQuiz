//
//  AlertPresenter.swift
//  MovieQuiz
//
//

import UIKit

class AlertPresenter {
    func showAlert( view: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.comletion?()
        }
        
        alert.addAction(action)
        
        view.present(alert, animated: true, completion: nil)
    }
}
