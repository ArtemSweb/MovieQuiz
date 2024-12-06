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
    
    private var presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
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
        
        //работа лоадера
        activityIndicator.hidesWhenStopped = true
        
        //получение вопроса из фабрики
        let questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        self.questionFactory = questionFactory
        
        showLoadingIndicator()
        questionFactory.loadData()
        
        //реализация MVP
        presenter.viewController = self
        
        //статистика по играм
        statisticService = StatisticService()
        
        //алерт
        alertPresenter = AlertPresenter()
        alertPresenter?.setup(delegate: self)
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in 
            guard let self else { return }
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadDataFromClientError(with error: String) {
        showNetworkError(message: error)
    }
    
    func didFailToLoadImage(with error: String) {
        showNetworkError(message: error)
    }
    
    //MARK: - Вспомогательные функции
    
    //метод для отображения рамки в цветах корректности ответа
    func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestin() {
            hideLoadingIndicator()
            guard let statisticService else { return }
            
            let now = Date()
            let resGame = GameResult(correct: correctAnswer, total: presenter.questionsAmount, date: now)
            statisticService.store(resGame)
            
            let text = 
            """
                Ваш результат: \(correctAnswer)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Cыграть еще раз",
                completion: { [weak self] in
                    guard let self else { return }
                    
                    self.presenter.resetQuestionIndex()
                    self.correctAnswer = 0
                    self.questionFactory?.requestNextQuestion()
                })
            alertPresenter?.showAlert(model: viewModel)
        } else {
            showLoadingIndicator()  //запускаем лоадер при успешной загрузке нового фильма
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    //блокировка-разблокировка кнопок после вопроса
    private func enableAndDisableButton(state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
    
    //лоадер
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    //обработка ошибки загрузки
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Повторить загрузку") { [weak self] in
                guard let self else { return }
                
                //перезапрашиваем данные из сети
                self.questionFactory?.loadData()
                showLoadingIndicator()
            }
        
        alertPresenter?.showAlert(model: errorModel)
    }
    
    //MARK: - обработка нажатия на кнопки
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
}
