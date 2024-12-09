import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB0utlets
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    
    //фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    //вопрос который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // класс алерта
    private var alertPresenter: AlertPresenter?
    // класс статиксервиса
    private var statisticService: StatisticService?
    // счетчик правильных ответов
    private var correctAnswers: Int = 0
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        
        presenter.viewController = self
        statisticService = StatisticService()
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
        
    }
    
    // статус бар
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    // обрашаемся к методу фабрики вопросов для генерации вопросов
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // обращение к методу для генерации вопроса
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    // перевод экрана в состояние ошибки
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private Methods
    
    // функция показа данных на экран
    private func show(quiz step: QuizStepViewModel) {
        // делаем кнопки активными
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // показ финального алерта
    private func alertFinal() {
        guard let statisticService = statisticService else { return }
        
        //данные в статиксервис для обновления данных и вычисления лучшего результата
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        // данные в алерт для показа
        let gameCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let timeRecord = statisticService.bestGame.date
        let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let message = """
        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
        Количество сыгранных игр: \(gameCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(timeRecord.dateTimeString))
        Средняя точность: \(totalAccuracy)
        """
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: message,
                                    buttonText: "Сыграть еще раз",
                                    comletion: { [ weak self ] in
                                        guard let self = self else { return }
                                        self.presenter.resetQuestionIndex()
                                        self.correctAnswers = 0
                                        questionFactory?.requestNextQuestion()
        })
        
        alertPresenter?.showAlert(view: self, model: alertModel)
    }
    
    // функция покраски рамки взависимости от ответа юзера
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        
    }
    
    // функция переключения состояний
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if presenter.isLastQuestion() {
            alertFinal()
        } else {
            presenter.switchToNextQuestion()
                
            questionFactory?.requestNextQuestion()
        }
    }
    
    // функция включения индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // функция показа алерта ошибки
    private func showNetworkError( message: String) {
        hideLoadingIndicator()
        
        let alertErrorModel = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText: "Попробовать еще раз",
                                         comletion: { [ weak self ] in
                                         guard let self = self else { return }
                                         self.correctAnswers = 0
                                         self.presenter.resetQuestionIndex()
                                         questionFactory?.requestNextQuestion()
        })
        
        alertPresenter?.showAlert(view: self, model: alertErrorModel)
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        //делаем кнопки неактивными до показа след вопроса
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        //делаем кнопки неактивными до показа след вопроса
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
