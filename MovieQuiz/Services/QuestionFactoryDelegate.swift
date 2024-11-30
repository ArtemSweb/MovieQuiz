import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() //успешная загрузка из сети
    func didFailToLoadData(with error: Error) //ошибка загрузки
}
