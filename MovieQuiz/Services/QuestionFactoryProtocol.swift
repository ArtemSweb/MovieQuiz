import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData() //для перезапроса данных из сети по нажатию кнопки в алерте
}
