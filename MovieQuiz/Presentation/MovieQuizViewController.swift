import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB0utlets
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    
    // класс алерта
    private var alertPresenter: AlertPresenter?
    // класс презентер
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter()
    }
    
    // статус бар
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    
    // функция показа данных на экран
    func show(quiz step: QuizStepViewModel) {
        // делаем кнопки активными
        noButton.isEnabled = true
        yesButton.isEnabled = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // показ финального алерта
    func alertFinal() {
        let message = presenter.makeRezultMessage()
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: message,
                                    buttonText: "Сыграть еще раз",
                                    comletion: { [ weak self ] in
                                        guard let self = self else { return }
                                        self.presenter.restartGame()
        })
        
        alertPresenter?.showAlert(view: self, model: alertModel)
    }
    
    // функция покраски рамки взависимости от ответа юзера
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // функция включения индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // функция показа алерта ошибки
    func showNetworkError( message: String) {
        hideLoadingIndicator()
        
        let alertErrorModel = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText: "Попробовать еще раз",
                                         comletion: { [ weak self ] in
                                         guard let self = self else { return }
                                         self.presenter.restartGame()
        })
        
        alertPresenter?.showAlert(view: self, model: alertErrorModel)
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        //делаем кнопки неактивными до показа след вопроса
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        //делаем кнопки неактивными до показа след вопроса
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        presenter.noButtonClicked()
    }
}
