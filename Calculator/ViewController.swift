//
//  ViewController.swift
//  Calculator
//
//  Created by 祝韶明 on 15/6/1.
//  Copyright (c) 2015年 祝韶明. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var isPrint = false
    var haveDot = false
    var brain = CalculatorBrain()
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var resultDisplay: UILabel!
    @IBAction func numButton(sender: UIButton) {
        let digit = sender.currentTitle!
        if isPrint {
            display.text = display.text! + digit        //输入状态时将前后输入的数字拼接
        }else {
            display.text = digit                        //输入第一个数字时将0换成当前输入数字
            isPrint = true                            //当输入了第一个数字之后即判断为输入状态
        }
    }
    //添加小数点
    @IBAction func appendDot() {
        if !haveDot {
            if isPrint {
                display.text! += "."
                haveDot = true
            }else {
                display.text! = "0."
                isPrint = true
                haveDot = true
            }
        }
    }
    //撤销按钮
    @IBAction func backspace() {
        if display.text!.characters.count > 1 {
            display.text = String(display.text!.characters.dropLast())
        }else {
            display.text = "0"
            isPrint = false
            haveDot = false
        }
    }
    //清除按钮
    @IBAction func clean() {
        brain.clean()
        haveDot = false
        isPrint = false
        display.text! = "0"
        resultDisplay.text! = "0"
    }
    //设置 M 变量
    @IBAction func setM() {
        brain.setM(displayValue)
        isPrint = false
        haveDot = false
        display.text = "0"
        
    }
    @IBAction func getM() {
        display.text! = "\(brain.getM())"
        enter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //第一行显示值
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            isPrint = false
            resultDisplay.text = "\(newValue!)"
        }
    }
    
    @IBAction func enter() {
        isPrint = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
            resultDisplay.text = "\(displayValue!)"
            display.text = "0"
        }else {
            displayValue = nil
        }
    }

    @IBAction func operate(sender: UIButton) {
        if isPrint {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            }else {
                displayValue = nil
            }
        }
    }
}

