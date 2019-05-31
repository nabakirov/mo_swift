//
//  Parser.swift
//  esm
//
//  Created by user on 12/9/18.
//  Copyright © 2018 user. All rights reserved.
//

import Foundation

enum MyError: Error {
    case runtimeError(String)
}

class Parser {
    
    private var expression: Expression
    private var x: Double
    
    init(expression: String) {
        self.x = 0
        self.expression = Expression("1 + 1")
        self.expression = Expression(expression, symbols: [
            .variable("x"): { _ in self.x},
            .function("exp", arity: 1): {args in exp(args[0])},
            .function("log", arity: 1): {args in log(args[0])},
            
            ])
    }
    public func run(x: Double) -> Double {
        
        self.x = x
        do {
            return try self.expression.evaluate()
        } catch {
            fatalError()
        }
    }

    public func check_run(x: Double) throws -> Double {
        
        self.x = x
        do {
            return try self.expression.evaluate()
        } catch {
            throw MyError.runtimeError("invalid")
        }
    }
}
