import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    //тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        //given
        let array = [1,1,2,3,5]
        
        //when
        let value = array[safe: 3]
        
        //then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    //тест на получение элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        //given
        let array = [1,1,2,3,5]
        
        //when
        let value = array[safe: 13]
        
        //then
        XCTAssertNil(value)
    }
}
