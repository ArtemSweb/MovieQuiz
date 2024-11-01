import UIKit

final class MovieQuizViewController: UIViewController {
    //MARK: - Структуры
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }

    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    //MARK: - элементы UI и мок-данные
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionTitleLable: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )]
    
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
        
        show(quiz: convert(model: questions[0]))
    }
    
    //MARK: - обработка нажатия на кнопки
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let flag = false
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer == flag)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let flag = true
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer == flag)
    }
    
    //MARK: - Вспомогательные функции
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        
        return quizStep
    }
    
    //метод для отображения рамки в цветах корректности ответа
    private func showAnswerResult(isCorrect: Bool) {
        enableAndDisableButton(state: false)
        if isCorrect {
            correctAnswer += 1
        }
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswer)/\(questions.count)"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен", text: text, buttonText: "Cыграть еще раз")
            showAction(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
    
    //блокировка-разблокировка кнопок после вопроса
    private func enableAndDisableButton(state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }

    //MARK: - Алерты
    private func showAction(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
