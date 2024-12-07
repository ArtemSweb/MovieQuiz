import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswer = 0
    
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticServiceProtocol?

    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        //фабрика вопросов
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        
        //статистика по играм
        statisticService = StatisticService()
    }
    
    
    //MARK: - Вспомогательные методы
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        let flag = isYes
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == flag)
    }
    
    func resetQuizParametr() {
        self.resetQuestionIndex()
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    
    //MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadDataFromClientError(with error: String) {
        viewController?.showNetworkError(message: error)
    }
    
    func didFailToLoadImage(with error: String) {
        viewController?.showNetworkError(message: error)
    }
    
    //MARK: - конвертация в модель квиза
    
    func upCorrectAnswerCounter() {
        correctAnswer += 1
    }
    
    func isLastQuestin() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizStep
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewController?.show(quiz: viewModel)
        }
    }
    //MARK: - Отображение вопроса или алерта
    func showNextQuestionOrResults() {
        viewController?.enableAndDisableButton(state: true)
        if self.isLastQuestin() {
            viewController?.hideLoadingIndicator()
            guard let statisticService else { return }
            
            let now = Date()
            let resGame = GameResult(correct: correctAnswer, total: self.questionsAmount, date: now)
            statisticService.store(resGame)
            
            let text =
            """
                Ваш результат: \(correctAnswer)/\(self.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(self.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            viewController?.showQuizResult(message: text)
        } else {
            viewController?.showLoadingIndicator()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    //MARK: - Обработка нажатия кнопок
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
     func noButtonClicked() {
        didAnswer(isYes: false)
    }
}
