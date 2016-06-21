//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 祝韶明 on 15/6/8.
//  Copyright (c) 2015年 祝韶明. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }

    
    //储存整个运算的栈
    private var opStack = [Op]()
    private var m = 0.0
    
    //储存已知的运算
    private var knownOps = [String:Op]()
    
    //一旦建立了实例对象则以下代码执行
    init() {
        //避免重复键入特殊符号
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("π") { $0 * 3.14 })
        learnOp(Op.UnaryOperation("±") { 0 - $0 })
    }
    
    var program: AnyObject { //guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            //剩余的栈
            let op = remainingOps.removeLast()
            switch op {
            //如果是操作数，则直接返回操作数
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                //对栈进行递归，如果下一个是数字则返回运算结果，否则一直递归下去
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                //对栈进行递归，获取第一个操作数
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    //对剩余栈进行递归，获取第二个操作数，然后返回运算结果
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        //递归结束出口
        return (nil, ops)
    }
    //开始对整个栈进行递归运算
    private func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over.")
        return result
    }
    
    //操作数入栈
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    //运算符入栈
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    //储存变量 M
    func setM(value: Double?){
        m = value!
    }
    //提取变量 M
    func getM() -> Double{
        return m
    }
    
    //清空栈
    func clean(){
        opStack.removeAll()
    }
}