//
//  CalculatorBrain.swift
//  Mycalculator
//
//  Created by HealthJudge on 2018/4/9.
//  Copyright © 2018年 HealthHIT. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperations((Double,Double)->Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "𝛑" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±": Operation.unaryOperation({ -$0 }),
        "×" : Operation.binaryOperations({ $0 * $1 }),
        "-" : Operation.binaryOperations({ $0 - $1 }),
        "+" : Operation.binaryOperations({ $0 + $1 }),
        "÷" : Operation.binaryOperations({ $0 / $1 }),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol:String){
        if let operation = operations[symbol]{
            switch operation{
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil{
                    accumulator = function(accumulator!)
                }
            case .binaryOperations(let function):
                if accumulator != nil{
                    pendingBinaryOperation = PendingBinaryOperation(function:function,firstOperand:accumulator!)
                    accumulator = nil
                }
            case .equals:
                performpendingBinaryOperation()
            }
        }
    }
    
    private mutating func performpendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil{
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation:PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let function: (Double,Double)->Double
        let firstOperand:Double
        
        func perform(with secondOperand:Double)->Double{
            return function(firstOperand,secondOperand)
        }
    }
    
    mutating func setOperand(_ operand:Double){
        accumulator = operand
    }
    
    var result:Double?{
        get{
            return accumulator
        }
    }
}
