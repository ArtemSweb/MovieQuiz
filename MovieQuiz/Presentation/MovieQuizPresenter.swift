import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    //MARK: - Вспомогательные методы
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        let flag = isYes
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == flag)
    }
    
    //MARK: - конвертация в модель квиза
    
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
    
    //MARK: - Обработка нажатия кнопок
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
     func noButtonClicked() {
        didAnswer(isYes: false)
    }
}
