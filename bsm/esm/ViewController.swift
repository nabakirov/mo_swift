//
//  ViewController.swift
//  esm
//
//  Created by user on 12/8/18.
//  Copyright © 2018 user. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    @IBOutlet weak var functionInput: NSTextField!
    @IBOutlet weak var x0Input: NSTextField!
//    @IBOutlet weak var hInput: NSTextField!
    @IBOutlet weak var toleranceInput: NSTextField!
    @IBOutlet weak var kMaxInput: NSTextField!
    @IBOutlet weak var tMaxInput: NSTextField!
    @IBOutlet weak var functionsInput: NSComboBoxCell!

    @IBOutlet weak var x1Output: NSTextField!
    @IBOutlet weak var yf1Output: NSTextField!
    @IBOutlet weak var kOutput: NSTextField!
    @IBOutlet weak var elapsedTimeOutput: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var messageOutput: NSTextField!
    @IBOutlet weak var resultTolField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func runBtnClicked(_ sender: Any) {
        self.clear()
        if !self.isValid() {
            return
        }
        
        var a: Decimal.FloatLiteralType = Decimal.FloatLiteralType(x0Input!.doubleValue)
        var b: Decimal.FloatLiteralType = Decimal.FloatLiteralType(tMaxInput!.doubleValue)
        let f = Parser(expression: functionsInput.stringValue)
        
        
        
        let tol: Decimal.FloatLiteralType = Decimal.FloatLiteralType(toleranceInput!.doubleValue)
//        let h: Double = tol
        var kMax: Int = kMaxInput.integerValue
//        var isMin: Bool
        
        
        var fa = f.run(x: a)
        let fb = f.run(x: b)
        if (fa.isNaN || fb.isNaN || fa.isInfinite || fb.isInfinite) {
            setInvalidInput(text: "cannot execute function with given parameters \nChange endpoints of the interval [a, b]")
            return
        }
        var fm: Decimal.FloatLiteralType
        var k: Int = 0
        var m: Decimal.FloatLiteralType = 0
        let startTime = Date()
        var tolResult: Decimal.FloatLiteralType = 0.0
        progressBar.doubleValue = 0
        var prevPosition: Decimal.FloatLiteralType = 0.0
        
        if sign(x: fa) == sign(x: fb) {
            setInvalidInput(text: "Sign on f(a) and f(b) must be opposite!\nChange endpoints of the interval [a, b]!")
            return
        } else {
            repeat {
                k += 1
                tolResult = abs(a - b)
                if tolResult <= tol {
                    messageOutput.stringValue = "Reached tollerance"
                    break
                }
                m =  a + (b - a) / 2
                fa = f.run(x: a)
                fm = f.run(x: m)
                if sign(x: fa) == sign(x: fm) {
                    a = m
                } else {
                    b = m
                }
                if k == kMax {
                    if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given limit of iterations, add \(kMax) more iterations") {
                        kMax += kMax
                        kMaxInput.stringValue = String(kMax)
                    } else {
                        messageOutput.stringValue = "Not possible to find solution for given \namount of iterations \(kMax)"
                    }
                }
                let position = Decimal.FloatLiteralType((k * 100) / kMax)
                if(Int(position) % 10 == 0 && position != prevPosition) {
                    prevPosition = position
                    progressBar.doubleValue = position
                }
            } while k < kMax
        }
        resultTolField.stringValue = "\(tolResult)"
        progressBar.doubleValue = 100
        x1Output.stringValue = "\(m)"
        yf1Output.stringValue = "\(f.run(x: m))"
        kOutput.stringValue = String(k)
        let endTime = NSDate()
        elapsedTimeOutput.doubleValue = endTime.timeIntervalSince(startTime)

    }
    func _round(x: Decimal.FloatLiteralType) -> Decimal.FloatLiteralType {
        let decimal = 10000000000000000.0
        return round(x * decimal) / decimal
    }
    
    @IBAction func clearBntClicked(_ sender: Any) {
        self.clear()
    }
    
    func clear() {
        x1Output.stringValue = ""
        yf1Output.stringValue = ""
        kOutput.stringValue = ""
        elapsedTimeOutput.stringValue = ""
        messageOutput.stringValue = ""
        progressBar.doubleValue = 0
        resultTolField.stringValue = ""
        
    }
    func setInvalidInput(text: String = "") {
        self.alertModal(messageText: "invalid input", informativeText: text)
        messageOutput.stringValue = "invalid input"
    }
    
    func isValid() -> Bool {
        let raw = functionsInput.stringValue
        if (raw.isEmpty) {
            self.setInvalidInput(text: "function field is empty")
            return false
        }
        let f = Parser(expression: raw)
        do {
            _ = try f.check_run(x: 1)
        } catch {
            self.setInvalidInput(text: "cannot parse function\nchange function field")
            return false
        }
        
//        [[x0Input, "LeftEndPoint is unknown"], [toleranceInput], kMaxInput, tMaxInput]
        if (!_validateFieldToDoubleValue(field: x0Input, errMsg: "LeftEndPoint is unknown\nchange LeftEndPoint")){
            return false
        }
        if (!_validateFieldToDoubleValue(field: toleranceInput, errMsg: "Tollerance is unknown\nchange Tollerance")){
            return false
        }
        if (!_validateFieldToDoubleValue(field: kMaxInput, errMsg: "Limit of iteration is unknown\nchange Limit of iteration")){
            return false
        }
        if (kMaxInput.intValue <= 0) {
            self.setInvalidInput(text: "Limit of iteration must be > 0\nchange Limit of iteration")
            return false
        }
        
        if (!_validateFieldToDoubleValue(field: tMaxInput, errMsg: "RightEndPoint is unknown\nchange RightEndPoint")){
            return false
        }
        
        return true
    }
    func _validateFieldToDoubleValue(field: NSTextField, errMsg: String = "") -> Bool {
        if Double(field.stringValue) == nil {
            self.setInvalidInput(text: errMsg)
            return false
        }
        return true
    }
    
    func alertModal(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.runModal()
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func sign(x: Decimal.FloatLiteralType) -> Int {
        if x < 0 {
            return -1
        } else if x > 0 {
            return 1
        } else {
            return 0
        }
    }
}

