import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // счетчик вопросов
    private var currentQuestionIndex: Int = 0
    // счетчик правильных ответов
    private var correctAnswers: Int = 0
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    //фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    //вопрос который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // класс алерта
    private var alertPresenter: AlertPresenter?
    // класс статистики
    private var statisticService: StatisticService?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter()
        statisticService = StatisticService()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        imageView.layer.cornerRadius = 20
    }
    
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
    
    // функци конвертирвания данных
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // функция показа данных на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // показ финального алерта
    private func alertFinal( rezult: QuizResultsViewModel) {
        guard let statisticService = statisticService else { return }
        
        // обновляем статистику
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let gamesCount = statisticService.gamesCount
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)

        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)\n
        Количество сыгранных квизов: \(gamesCount)\n
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n
        Средняя точность: \(totalAccuracy)%
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
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // функция переключения состояний
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть еще раз")
            
            alertFinal(rezult: viewModel)
        } else {
            currentQuestionIndex += 1
                
            self.questionFactory?.requestNextQuestion()
        }
    }
}
