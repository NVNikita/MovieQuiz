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
    
    // счетчик вопросов
    private var currentQuestionIndex: Int = 0
    // счетчик правильных ответов
    private var correctAnswers: Int = 0
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        
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
        let viewModel = convert(model: question)
        
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
    
    // функци конвертирвания данных
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
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
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        // данные в алерт для показа
        let gameCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let timeRecord = statisticService.bestGame.date
        let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных игр: \(gameCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(timeRecord.dateTimeString))
        Средняя точность: \(totalAccuracy)
        """
        
        let alertModel = AlertModel(title: "Раунд окончен",
                                    message: message,
                                    buttonText: "Сыграть еще раз",
                                    comletion: { [ weak self ] in
                                        guard let self = self else { return }
                                        self.currentQuestionIndex = 0
                                        self.correctAnswers = 0
                                        questionFactory?.requestNextQuestion()
        })
        
        alertPresenter?.showAlert(view: self, model: alertModel)
    }
    
    // функция покраски рамки взависимости от ответа юзера
    private func showAnswerResult(isCorrect: Bool) {
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
        if currentQuestionIndex == questionsAmount - 1 {
            alertFinal()
        } else {
            currentQuestionIndex += 1
                
            questionFactory?.requestNextQuestion()
        }
    }
    
    // функция включения индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // функция показа алерта ошибки
    private func showNetworkError( message: String) {
        
        let alertErrorModel = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText: "Попробовать еще раз",
                                         comletion: { [ weak self ] in
                                         guard let self = self else { return }
                                         self.correctAnswers = 0
                                         self.currentQuestionIndex = 0
                                         questionFactory?.requestNextQuestion()
        })
        
        alertPresenter?.showAlert(view: self, model: alertErrorModel)
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        //делаем кнопки неактивными до показа след вопроса
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
