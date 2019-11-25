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
//        execute()
        self.clear()
        if !self.isValid() {
            return
        }
        let f = Parser(expression: functionsInput.stringValue)
        let fd = Parser(expression: fd1Input.stringValue)
        var x0 = x0Input.doubleValue
        var x1: Double
        let tol: Double = toleranceInput.doubleValue
        var kMax: Int = kMaxInput.integerValue
        var tMax: Double = tMaxInput.doubleValue
        var relEr: Double
        
        var pauseTime: Double = 0.0
        var pauseStart: Date
        let startTime = Date()
        
        var fx = f.run(x: x0)
        var fdx = fd.run(x: x0)
        progressBar.doubleValue = 0.0
        var k: Int = 0
        var exit: Bool = false
        

        if (fx.isNaN || fx.isInfinite || fdx.isNaN || fdx.isInfinite) {
            setInvalidInput(text: "cannot execute function with given parameters \nChange X0")
            return
        }
        
        repeat {
            k += 1
            progressBar.doubleValue = Double(k * 100 / kMax)
            x1 = x0 - fx / fdx
            fx = f.run(x: x1)
            fdx = fd.run(x: x1)
            
            
            relEr = abs(fx / fdx)
            if abs(x1 - x0) <= tol {
                messageOutput.stringValue = "Found root of function with a given \ntolerance \(tol)"
                exit = true
            }
            if k == kMax {
                pauseStart = Date()
                if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given limit of iterations, add \(kMax) more iterations") {
                    kMax += kMax
                    kMaxInput.stringValue = String(kMax)
                } else {
                    messageOutput.stringValue = "Not possible to find solution for given \namount of iterations \(kMax)"
                    exit = true
                }
                pauseTime += Date().timeIntervalSince(pauseStart)
            }
            if NSDate().timeIntervalSince(startTime) - pauseTime > tMax {
                pauseStart = Date()
                if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given time limit, add \(tMax) more time?") {
                    tMax += tMax
                    tMaxInput.stringValue = String(tMax)
                } else {
                    exit = true
                    messageOutput.stringValue = "Not possible to find solution for given \ntime limit \(tMax)"
                }
                pauseTime += Date().timeIntervalSince(pauseStart)
            }
            xOutput.doubleValue = x0
            fOutput.doubleValue = fx
            relOutput.doubleValue = relEr
            fd1Output.doubleValue = fdx
            kOutput.stringValue = String(k)
            elapsedTimeOutput.doubleValue = NSDate().timeIntervalSince(startTime) - pauseTime
            x0 = x1
        } while !exit
        
        progressBar.doubleValue = 100
        xOutput.doubleValue = x0
        fOutput.doubleValue = fx
        relOutput.doubleValue = relEr
        fd1Output.doubleValue = fdx
        kOutput.stringValue = String(k)
        elapsedTimeOutput.doubleValue = NSDate().timeIntervalSince(startTime) - pauseTime
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
        if (!_validateFieldToDoubleValue(field: x0Input, errMsg: "X0 is unknown\nchange X0")){
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
    
    func execute() {
        print("starting executing")
        let task = Process()
//        task.executableURL = URL(fileURLWithPath: "/Users/nabakirov/Documents/mo_swift/nsm_root/builds/derivative")
//        task.arguments = ["sin(x)"]
        
//        print(Bundle.path(forResource: "derivative",ofType: "ext", inDirectory: "assets"))
        
        
        task.executableURL = URL(fileURLWithPath: "Documents/mo_swift/nsm_root/assets/derivative")
        task.arguments = ["/"]
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)

        print(output)
        print(error)
//        do {
//            try task.run()
//            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
//            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
//
//            let output = String(decoding: outputData, as: UTF8.self)
//            let error = String(decoding: errorData, as: UTF8.self)
//
//            print(output)
//            print(error)
//        } catch {
//            print(error)
//        }
        
        
        
    }
}

