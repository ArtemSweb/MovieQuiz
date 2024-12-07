import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswer = 0
    
    private var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticServiceProtocol?

    
    init(viewController: MovieQuizViewControllerProtocol) {
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
        
        self.proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == flag)
    }
    
    func resetQuizParametr() {
        currentQuestionIndex = 0
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
    
    //MARK: - методы работы с параметрами
    func upCorrectAnswerCounter() {
        correctAnswer += 1
    }
    
    func isLastQuestin() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //MARK: - Модель квиза
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
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.enableAndDisableButton(state: false)
        if isCorrect {
            self.upCorrectAnswerCounter()
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    //MARK: - Отображение вопроса или алерта
    private func proceedToNextQuestionOrResults() {
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
