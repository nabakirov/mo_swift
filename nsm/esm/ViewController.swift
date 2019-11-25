//
//  ViewController.swift
//  esm
//
//  Created by user on 12/8/18.
//  Copyright © 2018 user. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    @IBOutlet weak var functionsInput: NSComboBoxCell!
    @IBOutlet weak var fd1Input: NSComboBox!
    @IBOutlet weak var fd2Input: NSComboBox!
    @IBOutlet weak var x0Input: NSTextField!
    @IBOutlet weak var deltaInput: NSTextField!
    @IBOutlet weak var rInput: NSTextField!
    @IBOutlet weak var toleranceInput: NSTextField!
    @IBOutlet weak var kMaxInput: NSTextField!
    @IBOutlet weak var tMaxInput: NSTextField!
    
    
    @IBOutlet weak var xOutput: NSTextField!
    @IBOutlet weak var fOutput: NSTextField!
    @IBOutlet weak var relOutput: NSTextField!
    @IBOutlet weak var fd1Output: NSTextField!
    @IBOutlet weak var fd2Output: NSTextField!
    @IBOutlet weak var kOutput: NSTextField!
    @IBOutlet weak var elapsedTimeOutput: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var messageOutput: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func sign(x: Double) -> Int {
        if x < 0 {
            return -1
        }
        else if x > 0 {
            return 1
        }
        else {
            return 0
        }
    }
   

    @IBAction func runBtnClicked(_ sender: Any) {
        self.clear()
        if !self.isValid() {
            return
        }
        let f = Parser(expression: functionsInput.stringValue)
        let fd1 = Parser(expression: fd1Input.stringValue)
        let fd2 = Parser(expression: fd2Input.stringValue)
        let delta = deltaInput.doubleValue
        var x0 = x0Input.doubleValue
        let r = rInput.doubleValue
        let tol: Double = toleranceInput.doubleValue
        var kMax: Int = kMaxInput.integerValue
        let tMax: Double = tMaxInput.doubleValue
        
        
        var fx0: Double
        var dfx0: Double
        var ddfx0: Double
        var qnd: Double
        var dp0: Double = 0
        var dp: Double = 0
        var relEr: Double
        var x1: Double

        let startTime = Date()
        var endTime = NSDate()
        var isTimeReached = false
        var k: Int = 0
        var cond: Int = 0
        progressBar.doubleValue = 0.0
        repeat {
            k += 1
            progressBar.doubleValue = Double(k * 100 / kMax)
            fx0 = f.run(x: x0)
            dfx0 = fd1.run(x: x0)
            ddfx0 = fd2.run(x: x0)
            if abs(ddfx0) <= tol {
                qnd = 0
                cond = 1
            } else {
                dp = dfx0 / ddfx0
            }
            if k == 1 {
                dp0 = dp
            }
            if sign(x: dp0) == sign(x: dp) {
                x1 = x0 - dp
            } else {
                x1 = x0 - dp / r
            }
            dp0 = dp
            relEr = 2 * abs(dp) / (abs(x1) + tol)
            
            if relEr <= delta {
                if cond != 1 {
                    cond = 2
                }
            }
            x0 = x1
            
            endTime = NSDate()
            if k == kMax {
                if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given limit of iterations, add \(kMax) more iterations") {
                    kMax += kMax
                    kMaxInput.stringValue = String(kMax)
                } else {
                    messageOutput.stringValue = "Attention: It isn't possible to find a solution\nwith a given Number Of Iterations = \(kMax)"
                }
            }
            if endTime.timeIntervalSince(startTime) >= tMax {
                isTimeReached = true
                messageOutput.stringValue = "Not possible to find solution for given \ntime limit \(tMax)"
            }

            xOutput.doubleValue = x0
            fOutput.doubleValue = fx0
            relOutput.doubleValue = relEr
            fd1Output.doubleValue = dfx0
            fd2Output.doubleValue = ddfx0
            kOutput.stringValue = String(k)
            elapsedTimeOutput.doubleValue = endTime.timeIntervalSince(startTime)
            
        } while k < kMax && !isTimeReached && cond == 0
        
        if cond == 1 {
            messageOutput.stringValue = "The optimal solution is not found. Met division by zero"
        }
        else if cond == 2 {
            if ddfx0 > 0 {
                messageOutput.stringValue = "Found minimum of function"
            }
            else if ddfx0 < 0 {
                messageOutput.stringValue = "Found maximum of function"
            }
            else {
                messageOutput.stringValue = "Found kink point of function"
            }
        }
        progressBar.doubleValue = 100
        xOutput.doubleValue = x0
        fOutput.doubleValue = fx0
        relOutput.doubleValue = relEr
        fd1Output.doubleValue = dfx0
        fd2Output.doubleValue = ddfx0
        kOutput.stringValue = String(k)
        elapsedTimeOutput.doubleValue = endTime.timeIntervalSince(startTime)
    }
   

    @IBAction func clearBntClicked(_ sender: Any) {
        self.clear()
    }
    
    func clear() {
        progressBar.doubleValue = 0
        xOutput.stringValue = ""
        fOutput.stringValue = ""
        relOutput.stringValue = ""
        fd1Output.stringValue = ""
        fd2Output.stringValue = ""
        kOutput.stringValue = ""
        elapsedTimeOutput.stringValue = ""
        messageOutput.stringValue = ""
        
    }
    func setInvalidInput(text: String = "") {
        self.alertModal(messageText: "invalid input", informativeText: text)
        messageOutput.stringValue = "invalid input"
    }
    
    func checkFuncInput(raw: String, errMsg: String) -> Bool {
        let f = Parser(expression: raw)
        do {
            _ = try f.check_run(x: 1)
        } catch {
            self.setInvalidInput(text: errMsg)
            return false
        }
        return true
    }
    
    func isValid() -> Bool {
        if checkFuncInput(raw: functionsInput.stringValue, errMsg: "Cannot parse function\nchange function field") == false{
            return false
        }
        if checkFuncInput(raw: fd1Input.stringValue, errMsg: "Cannot parse f`(x)\nchange f`(x) field") == false{
            return false
        }
        if checkFuncInput(raw: fd2Input.stringValue, errMsg: "Cannot parse f``(x)\nchange f``(x) field") == false{
            return false
        }
        if (!_validateFieldToDoubleValue(field: x0Input, errMsg: "X0 is unknown\nchange X0")){
            return false
        }
        if (!_validateFieldToDoubleValue(field: deltaInput, errMsg: "delta is unknown\nchange delta")){
            return false
        }
        if (!_validateFieldToDoubleValue(field: rInput, errMsg: "R is unknown\nchange R")){
            return false
        }
        if (!_validateFieldToDoubleValue(field: kMaxInput, errMsg: "Limit of iteration is unknown\nchange Limit of iteration")){
            return false
        }
        if (kMaxInput.intValue <= 0) {
            self.setInvalidInput(text: "Limit of iteration must be > 0\nchange Limit of iteration")
            return false
        }
        if (!_validateFieldToDoubleValue(field: tMaxInput, errMsg: "Limit of time is unknown\nchange Limit of time")){
            return false
        }
        if tMaxInput.doubleValue <= 0.0 {
            self.setInvalidInput(text: "Limit of time must be > 0\nchange Limit of time")
            return false
        }
        if (!_validateFieldToDoubleValue(field: toleranceInput, errMsg: "Tollerance is unknown\nchange Tollerance")){
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
    
}

