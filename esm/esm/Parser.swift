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
    
    private var raw: String
    
    init(expression: String) {
        self.raw = expression
    }
    public func run(x: Decimal.FloatLiteralType) -> Decimal.FloatLiteralType {
        let expression = Expression(self.raw, symbols: [
            .variable("x"): { _ in x},
            .function("exp", arity: 1): {args in exp(args[0])},
            .function("log", arity: 1): {args in log(args[0])},
            .infix("^"): {args in pow(args[0], args[1])}
            ])
        do {
            return try expression.evaluate()
        } catch {
            fatalError()
        }
    }
    
    public func check_run(x: Decimal.FloatLiteralType) throws -> Decimal.FloatLiteralType {
        let expression = Expression(self.raw, symbols: [
            .variable("x"): { _ in x},
            .function("exp", arity: 1): {args in exp(args[0])},
            .function("log", arity: 1): {args in log(args[0])},
            .infix("^"): {args in pow(args[0], args[1])}
            ])
        do {
            return try expression.evaluate()
        } catch {
            throw MyError.runtimeError("invalid")
        }
    }
}
