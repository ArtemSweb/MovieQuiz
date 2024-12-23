import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    //MARK: - элементы UI и мок-данные
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionTitleLable: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
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
        showLoadingIndicator()
        
        //реализация MVP
        presenter = MovieQuizPresenter(viewController: self)
        
        //алерт
        alertPresenter = AlertPresenter()
        alertPresenter?.setup(delegate: self)
    }
    
    //MARK: - Вспомогательные функции
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    //отображение вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //блокировка-разблокировка кнопок после вопроса
    func enableAndDisableButton(state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
    
    //лоадер
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    //MARK: - отображение Alert
    //обработка ошибки загрузки
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Повторить загрузку") { [weak self] in
                guard let self else { return }
                presenter.resetQuizParametr()
            }
        
        alertPresenter?.showAlert(model: errorModel)
    }
    
    func showQuizResult(message: String) {
        let text = message
        let viewModel = AlertModel(
            title: "Этот раунд окончен!",
            message: text,
            buttonText: "Cыграть еще раз",
            completion: { [weak self] in
                guard let self else { return }
                presenter.resetQuizParametr()
            })
        alertPresenter?.showAlert(model: viewModel)
    }
    
    //MARK: - обработка нажатия на кнопки
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
