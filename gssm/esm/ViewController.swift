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
    @IBOutlet weak var aInput: NSTextField!
    @IBOutlet weak var bInput: NSTextField!
    @IBOutlet weak var toleranceInput: NSTextField!
    @IBOutlet weak var kMaxInput: NSTextField!
    @IBOutlet weak var tMaxInput: NSTextField!
    @IBOutlet weak var minInput: NSButton!
    @IBOutlet weak var maxInput: NSButton!
    
    @IBOutlet weak var x1Output: NSTextField!
    @IBOutlet weak var yf1Output: NSTextField!
    @IBOutlet weak var yf2Output: NSTextField!
    @IBOutlet weak var absOutput: NSTextField!
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
    @IBAction func maxClicked(_ sender: Any) {
        minInput.state = NSControl.StateValue(rawValue: 0)
        
    }
    
    @IBAction func minClicked(_ sender: Any) {
        maxInput.state = NSControl.StateValue(rawValue: 0)
    }

    @IBAction func runBtnClicked(_ sender: Any) {
//        self.executeCmd()
        self.clear()
        if !self.isValid() {
            return
        }
        
        let f = Parser(expression: functionsInput.stringValue)
        var a = aInput.doubleValue
        var b = bInput.doubleValue
        let tol: Double = toleranceInput.doubleValue
        var kMax: Int = kMaxInput.integerValue
        var tMax: Double = tMaxInput.doubleValue
        var isMin: Bool
        
        let r: Double = (pow(5, 1/2) - 1) / 2
        var x1: Double
        var x2: Double
        var f1: Double
        var f2: Double
        
        x1 = a + (1.0 - r) * (b - a)
        f1 = f.run(x: x1)
        x2 = a + r * (b - a)
        f2 = f.run(x: x2)
        if (f1.isNaN || f1.isInfinite || f2.isNaN || f2.isInfinite) {
            setInvalidInput(text: "cannot execute function with given parameters \nChange input parameters")
            return
        }
        
        if minInput.state == NSControl.StateValue(rawValue: 1) {
            isMin = true
        } else {
            isMin = false
        }
        
        let startTime = Date()
        var endTime = NSDate()
        let found: Bool = false
        var isTimeReached = false
        var k: Int = 0
        var message: String
        progressBar.doubleValue = 0.0
        var pauseTime: Double = 0.0
        var pauseStart: Date
        repeat {
            k += 1
            progressBar.doubleValue = Double(k * 100 / kMax)
            if isMin{
                message = "Found minimum of function with a given \ntolerance \(tol)"
                if f1 > f2 {
                    a = x1
                    x1 = x2
                    f1 = f2
                    x2 = a + r * (b - a)
                    f2 = f.run(x: x2)
                } else {
                    b = x2
                    x2 = x1
                    f2 = f1
                    x1 = a + (1 - r) * (b - a)
                    f1 = f.run(x: x1)
                }
            } else {
                message = "Found maximum of function with a given \ntolerance \(tol)"
                if f1 <= f2 {
                    a = x1
                    x1 = x2
                    f1 = f2
                    x2 = a + r * (b - a)
                    f2 = f.run(x: x2)
                } else {
                    b = x2
                    x2 = x1
                    f2 = f1
                    x1 = a + (1 - r) * (b - a)
                    f1 = f.run(x: x1)
                }
            }
            endTime = NSDate()
            progressBar.doubleValue = 100
            x1Output.doubleValue = x1
            yf1Output.doubleValue = f1
            yf2Output.doubleValue = f2
            absOutput.doubleValue = abs(b - a)
            kOutput.stringValue = String(k)
            elapsedTimeOutput.doubleValue = endTime.timeIntervalSince(startTime) - pauseTime
            
            if k == kMax {
                pauseStart = Date()
                if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given limit of iterations, add \(kMax) more iterations") {
                    kMax += kMax
                    kMaxInput.stringValue = String(kMax)
                } else {
                    message = "Not possible to find solution for given \namount of iteration \(kMax)"
                }
                pauseTime += Date().timeIntervalSince(pauseStart)
            }
            if NSDate().timeIntervalSince(startTime) - pauseTime > tMax {
                pauseStart = Date()
                if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given time limit, add \(tMax) more time?") {
                    tMax += tMax
                    tMaxInput.stringValue = String(tMax)
                } else {
                    isTimeReached = true
                    messageOutput.stringValue = "Not possible to find solution for given \ntime limit \(tMax)"
                }
                pauseTime += Date().timeIntervalSince(pauseStart)
            }
            
            
        } while abs(b - a) > tol && k < kMax && !isTimeReached && !found
            
        messageOutput.stringValue = message
        progressBar.doubleValue = 100
        x1Output.doubleValue = x1
        yf1Output.doubleValue = f1
        yf2Output.doubleValue = f2
        absOutput.doubleValue = abs(b - a)
        kOutput.stringValue = String(k)
        elapsedTimeOutput.doubleValue = endTime.timeIntervalSince(startTime) - pauseTime
    }
   

    @IBAction func clearBntClicked(_ sender: Any) {
        self.clear()
    }
    
    func clear() {
        x1Output.stringValue = ""
        yf1Output.stringValue = ""
        yf2Output.stringValue = ""
        kOutput.stringValue = ""
        absOutput.stringValue = ""
        elapsedTimeOutput.stringValue = ""
        messageOutput.stringValue = ""
        progressBar.doubleValue = 0
//        self.openExcel()
    }
    func setInvalidInput(text: String = "") {
        self.alertModal(messageText: "invalid input", informativeText: text)
        messageOutput.stringValue = "invalid input"
    }
    
    func isValid() -> Bool {
        for raw in [functionsInput.stringValue] {
            let f = Parser(expression: raw)
            do {
                _ = try f.check_run(x: 1)
            } catch {
                self.setInvalidInput(text: "Cannot parse function\nchange function field")
                return false
            }
        }
        if (!_validateFieldToDoubleValue(field: aInput, errMsg: "A is unknown\nchange A")){
            return false
        }
        if (!_validateFieldToDoubleValue(field: bInput, errMsg: "B is unknown\nchange B")){
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
        if (!_validateFieldToDoubleValue(field: tMaxInput, errMsg: "Limit of time is unknown\nchange Limit of time")){
            return false
        }
        if tMaxInput.doubleValue <= 0.0 {
            self.setInvalidInput(text: "Limit of time must be > 0\nchange Limit of time")
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
    
    func executeCmd() -> Bool {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["open looking_for.xlsx"]
        task.launch()
        return true
        print(task.standardError)
        print(task.standardOutput)
    }
    
    
//    func openExcel(){
//        let documentPath: String = Bundle.main.path(forResource: "looking_for", ofType: "xlsx")!
//        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
//        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
//        let string: String = worksheet.cell(forCellReference: "A1").stringValue()
//        print(string) // The Xcode console should now show the word "Alpha"
//    }
    
    
}

