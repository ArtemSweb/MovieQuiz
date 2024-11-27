import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - элементы UI и мок-данные
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionTitleLable: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //стили надписей
        textLabel.font = UIFont(name: "YSDisplay-bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-medium", size: 20)
        questionTitleLable.font = UIFont(name: "YSDisplay-medium", size: 20)
        
        //стили картинок
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        //стили кнопок
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-medium", size: 20)
        
        //получение вопроса из фабрики
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
        //статистика по играм
        statisticService = StatisticService()
        
        //алерт
        alertPresenter = AlertPresenter()
        alertPresenter?.setup(delegate: self)
    }
    
    //MARK: - QuestionFactoryDelegate
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
    
    //MARK: - Вспомогательные функции
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizStep
    }
    
    //метод для отображения рамки в цветах корректности ответа
    private func showAnswerResult(isCorrect: Bool) {
        enableAndDisableButton(state: false)
        if isCorrect {
            correctAnswer += 1
        }
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    //отображение вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        enableAndDisableButton(state: true)
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService else { return }
            
            let now = Date()
            let resGame = GameResult(correct: correctAnswer, total: questionsAmount, date: now)
            statisticService.store(resGame)
            
            let text = 
            """
                Ваш результат: \(correctAnswer)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Cыграть еще раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    
                    self.currentQuestionIndex = 0
                    self.correctAnswer = 0
                    self.questionFactory.requestNextQuestion()
                })
            alertPresenter?.showAlert(model: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
        }
    }
    
    //блокировка-разблокировка кнопок после вопроса
    private func enableAndDisableButton(state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
    
    //лоадер
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    //обработка ошибки загрузки
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Повторить загрузку",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswer = 0
                self.questionFactory.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(model: errorModel)
    }
    
    //MARK: - обработка нажатия на кнопки
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let flag = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == flag)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let flag = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == flag)
    }
}
