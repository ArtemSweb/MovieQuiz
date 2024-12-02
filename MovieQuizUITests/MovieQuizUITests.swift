import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    //тест что кнопка "Да" перелистывает вопрос
    func testYesButton() {
        sleep(4)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(4)
        
        let secontPoster = app.images["Poster"]
        let secontPosterData = secontPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secontPosterData)
    }
    
    //тест что кнопка "Нет" перелистывает вопрос
    func testNoButton() {
        sleep(4)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(4)
        
        let secontPoster = app.images["Poster"]
        let secontPosterData = secontPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secontPosterData)
    }
    
    //тест счетчика вопросов
    func testIndexQuestionLable() {
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["Yes"].tap()
        sleep(2)
        app.buttons["Yes"].tap()
        sleep(2)
        app.buttons["Yes"].tap()
        sleep(2)
        
        XCTAssertEqual(indexLabel.label, "4/10")
    }
    
    //тест появления алерта в конце квиза
    func testShowAlert() {
        //ждем загрузку первого вопроса
        sleep(2)
        
        //10 раз жмем кнопку "Да"
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        sleep(2)
        //ловим алерт
        let alert = app.alerts["Game result"]
        
        //проверяем наличие алерта и верность текста заголовка и кнопки
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Cыграть еще раз")
    }
    
    func testDismissAlert() {
        testShowAlert()
        
        //ловим алерт
        let alert = app.alerts["Game result"]
        
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
