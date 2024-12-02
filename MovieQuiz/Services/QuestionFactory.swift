import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoadingProtocol
    private var movies: [MostPopularMovie] = []
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        )]
    
    init(delegate: QuestionFactoryDelegate? = nil, moviesLoader: MoviesLoadingProtocol) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData(){
        moviesLoader.loadMovies{ [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.count == 0 {
                        self.delegate?.didFailToLoadDataFromClientError(with: mostPopularMovies.errorMessage)
                    } else {
                        self.movies = mostPopularMovies.items //сохранили фильм в массив
                        self.delegate?.didLoadDataFromServer() //сообщили делегатору о готовности
                    }
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadImage(with: "Failed to load image")
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            var questionRating = Float.random(in: rating - 0.4...rating + 0.4)
            questionRating = round(questionRating * 10) / 10.0                      //округление до десятых
            let text = "Рейтинг этого фильма больше чем \(questionRating)?"
            let correctAnswer = rating > questionRating
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
