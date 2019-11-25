//
//  esmTests.swift
//  esmTests
//
//  Created by Abakirov Nursultan on 9/26/19.
//  Copyright © 2019 user. All rights reserved.
//

import XCTest
@testable import esm

class esmTests: XCTestCase {

    func testParsingFunction1() {
        let f = Parser(expression: "x^2-4*sin(x)")
        let x = 1.0
        let expected = pow(x, 2) - 4 * sin(x)
        let result = f.run(x: x)
        XCTAssertTrue(result == expected)
    }
    func testParsingFunction2() {
        let f = Parser(expression: "(x-2)^2-log(x)")
        let x = 1.0
        let expected = pow((x - 2), 2) - log(x)
        let result = f.run(x: x)
        XCTAssertTrue(result == expected)
    }
    func testParsingFunction3() {
        let f = Parser(expression: "4*x^3-2*x-6")
        let x = 1.0
        let expected = pow(4 * x, 3) - 2 * x - 6
        let result = f.run(x: x)
        XCTAssertTrue(result == expected)
    }
    func testParsingFunction4() {
        let f = Parser(expression: "1500*x^3-0.001*exp(2*x)")
        let x = 1.0
        let expected = pow(1500 * x, 3) - 0.001 * exp(2 * x)
        let result = f.run(x: x)
        XCTAssertTrue(result == expected)
    }
    func testParsingFunction5() {
        let f = Parser(expression: "0.01*exp(x)^2")
        let x = 1.0
        let expected = pow(0.01 * exp(x), 2)
        let result = f.run(x: x)
        print(expected, result)
        XCTAssertTrue(result == expected)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//            
//            let f = Parser(expression: "0.01*exp(x)^2")
//            let x = 1.0
//            let expected = pow(0.01 * exp(x), 2)
//            let result = f.run(x: x)
//        }
//    }

}
