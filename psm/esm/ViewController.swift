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
    @IBOutlet weak var toleranceInput: NSTextField!
    @IBOutlet weak var kMaxInput: NSTextField!
    @IBOutlet weak var tMaxInput: NSTextField!
    @IBOutlet weak var minInput: NSButton!
    @IBOutlet weak var maxInput: NSButton!
    @IBOutlet weak var functionsInput: NSComboBoxCell!
    @IBOutlet weak var rInput: NSTextField!
    @IBOutlet weak var hInput: NSTextField!
    
    @IBOutlet weak var x1Output: NSTextField!
    @IBOutlet weak var yf1Output: NSTextField!
    @IBOutlet weak var kOutput: NSTextField!
    @IBOutlet weak var hOutput: NSTextField!
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
        self.clear()
        if !self.isValid() {
            return
        }
        var x0 = x0Input.doubleValue
        var x1: Double
        let f = Parser(expression: functionsInput.stringValue)
        
        
        let tol: Double = toleranceInput.doubleValue
        var h: Double = hInput.doubleValue
        let r: Double = rInput.doubleValue
        var kMax: Int = kMaxInput.integerValue
        let tMax: Double = tMaxInput.doubleValue
        var isMin: Bool
        
        
        var yf0: Double = f.run(x: x0)
        var yf1: Double
        var h1 = h
        var k: Int = 0
        
        if minInput.state == NSControl.StateValue(rawValue: 1) {
            isMin = true
        } else {
            isMin = false
        }
        
        let startTime = Date()
        var endTime = NSDate()
        var found: Bool = false
        var isTimeReached = false
        progressBar.doubleValue = 0.0
        repeat {
            k += 1
            progressBar.doubleValue = Double(k * 100 / kMax)
            if isMin{
                if abs(h) < tol / r {
                    h1 = h
                    x1 = x0
                    yf1 = yf0
                    found = true
                    messageOutput.stringValue = "Found minimum of function with a given \ntolerance \(tol)"
                } else {
                    x1 = x0 + h1
                    yf1 = f.run(x: x1)
                    if yf1 >= yf0 {
                        h1 = -h / r
                    } else {
                        h1 = h
                    }
                    x0 = x1
                    yf0 = yf1
                    h = h1
                }
            } else {
                if abs(h) < tol / r {
                    h1 = h
                    x1 = x0
                    yf1 = yf0
                    found = true
                    messageOutput.stringValue = "Found maximum of function with a given \ntolerance \(tol)"
                } else {
                    x1 = x0 + h1
                    yf1 = f.run(x: x1)
                    if yf1 <= yf0 {
                        h1 = -h / r
                    } else {
                        h1 = h
                    }
                    x0 = x1
                    yf0 = yf1
                    h = h1
                }
            }
            endTime = NSDate()
            if k == kMax {
                if self.dialogOKCancel(question: "Continue Search?", text: "Solution was not found in given limit of iterations, add \(kMax) more iterations") {
                    kMax += kMax
                    kMaxInput.stringValue = String(kMax)
                } else {
                    messageOutput.stringValue = "Not possible to find solution for given \namount of iterations \(kMax)"
                }
            }
            if endTime.timeIntervalSince(startTime) >= tMax {
                isTimeReached = true
                messageOutput.stringValue = "Not possible to find solution for given \ntime limit \(tMax)"
            }
            
            
        } while k < kMax && !isTimeReached && !found
            
        if k == 1 && found {
            messageOutput.stringValue = "Can't find an extremum or X0 placed in \nthe right-of-solution X*"
            self.alertModal(messageText: "Try X0 be lefter and closer to X*", informativeText: "Found not best fit X*")
        }
        progressBar.doubleValue = 100
        x1Output.doubleValue = x1
        yf1Output.doubleValue = yf1
        kOutput.stringValue = String(k)
        hOutput.doubleValue = h1
        elapsedTimeOutput.doubleValue = endTime.timeIntervalSince(startTime)
    }
   

    @IBAction func clearBntClicked(_ sender: Any) {
        self.clear()
    }
    
    func clear() {
        x1Output.stringValue = ""
        yf1Output.stringValue = ""
        kOutput.stringValue = ""
        hOutput.stringValue = ""
        elapsedTimeOutput.stringValue = ""
        messageOutput.stringValue = ""
        progressBar.doubleValue = 0
        
    }
    func setInvalidInput() {
        self.alertModal(messageText: "invalid input", informativeText: "")
        messageOutput.stringValue = "invalid input"
    }
    
    func isValid() -> Bool {
        for raw in [functionsInput.stringValue] {
            let f = Parser(expression: raw)
            do {
                _ = try f.check_run(x: 1)
            } catch {
                self.setInvalidInput()
                return false
            }
        }
        for el in [x0Input, hInput, rInput, toleranceInput, kMaxInput, tMaxInput] {
            if Double(el!.stringValue) == nil {
                self.setInvalidInput()
                return false
            }
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

