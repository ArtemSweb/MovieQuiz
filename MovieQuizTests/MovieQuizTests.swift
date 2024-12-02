import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
    
    func divizion(num1: Int, num2: Int, handler: @escaping (Float) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if num2 != 0 {
                handler(Float(num1) / Float(num2))
            } else {
                handler(0)
            }
        }
    }
}


final class MovieQuizTests: XCTestCase {
    func testAddition() throws {
        let arithmeticOperations = ArithmeticOperations()
        let expectation = expectation(description: "Addition function expectation")
        
        arithmeticOperations.addition(num1: 1, num2: 2) { result in
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
//
//    func testDivizion() throws {
//        let arithmeticOperations = ArithmeticOperations()
//        let result = arithmeticOperations.divizion(num1: 4, num2: 2)
//        
//        XCTAssertEqual(result, 2)
//    }
//    
//    func testDivizionByZero() throws {
//        let arithmeticOperations = ArithmeticOperations()
//        let result = arithmeticOperations.divizion(num1: 4, num2: 0)
//        
//        XCTAssertEqual(result, 0)
//    }
}
