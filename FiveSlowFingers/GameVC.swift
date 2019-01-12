//
//  ViewController.swift
//  FiveSlowFingers
//
//  Created by fsociety.1 on 5/30/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}

class GameVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!  // words table view
    @IBOutlet weak var inputTextField: UITextField!  // text field for word input
    @IBOutlet weak var bottomConst: NSLayoutConstraint! // bottom constraint under text field
    @IBOutlet weak var timerLabel: UILabel!  // timer label which starts from 60
    @IBOutlet weak var speakSwitch: UISwitch!  // switch to toggle text to speech
    
    var allWords = [String]()
    var selectedWords = [String]()
    var previousCorrect = [Bool]()
    var previuosWordsIndex = [Int]()
    var correctCounter = 0
    var incorrectCounter = 0
    var wordIndex = 0
    var chosenLang = String()
    var chosenFile = String()
    var chosenKeyb = String()
    var firstInput = true
    
    var array = 0...60
    var counter = 60
    var timer1 = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        inputTextField.autocorrectionType = .no
        inputTextField.tintColor = UIColor.black
        inputTextField.becomeFirstResponder()
        loadWords()
    }
    
    @objc func timerAction() {
        counter -= 1
        timerLabel.text = "\(counter)"
        if counter == 0 {
            timer1.invalidate()
            self.performSegue(withIdentifier: "showResult", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let vc = segue.destination as! ResultVC
            vc.getLanguage = chosenKeyb
            vc.getCorrect = correctCounter
            vc.getIncorrect = incorrectCounter
        }
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomConst.constant = keyboardHeight + 10
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConst.constant = 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if wordIndex < selectedWords.count && inputTextField.text! != "" {
            if selectedWords[wordIndex] == inputTextField.text! {
                correctCounter += 1
                previousCorrect.append(true)
            }
            else {
                incorrectCounter += 1
                previousCorrect.append(false)
            }
            previuosWordsIndex.append(wordIndex)
            wordIndex += 1
            inputTextField.text = ""
            speak(index: wordIndex)
            tableView.reloadData()
            if wordIndex < selectedWords.count {
                 tableView.scrollToRow(at: [0, wordIndex], at: .middle, animated: true)
            }
            else {
                print("Finished")
            }
        }
        return true
    }
    override var textInputMode: UITextInputMode? {
        let language = chosenKeyb

        for tim in UITextInputMode.activeInputModes {
            if tim.primaryLanguage!.contains(language) {
                return tim
            }
        }
        return super.textInputMode
    }
    
    
    /* Function to fill array with words from .txt file */
    func fillArray(){
        do {
            if let path = Bundle.main.path(forResource: chosenFile, ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                allWords = data.components(separatedBy: "\n")
            }
        } catch let err as NSError {
            print(err)
        }
    }
    

    func loadWords(){
        fillArray()  // filling array
        for _ in 1...500 {
            let randomIndex = Int(arc4random() % UInt32(allWords.count))
            selectedWords.append(allWords[randomIndex])
            tableView.reloadData()
        }
        selectedWords.removeDuplicates()
        print("Count", selectedWords.count)
        speak(index: 0)
    }

    @IBAction func inputChanged(_ sender: Any) {
        if firstInput {
            timer1.invalidate()
            timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            firstInput = false
        }
        if inputTextField.text?.last == " " && wordIndex < selectedWords.count && inputTextField.text!.count > 1 && inputTextField.text! != "  " {
            if selectedWords[wordIndex] == inputTextField.text!.dropLast() {
                correctCounter += 1
                previousCorrect.append(true)
            }
            else {
                incorrectCounter += 1
                previousCorrect.append(false)
            }
            previuosWordsIndex.append(wordIndex)
            wordIndex += 1
            inputTextField.text = ""
            speak(index: wordIndex)
            tableView.reloadData()
            if wordIndex < selectedWords.count {
                tableView.scrollToRow(at: [0, wordIndex], at: .middle, animated: true)
            }
            else {
                print("Finished")
            }
            
        }
        else if inputTextField.text! == "  " {
            inputTextField.text! = ""
        }
    }
    
    /* function to pronounce word */
    func speak(index: Int){
        if speakSwitch.isOn {
            let utterance = AVSpeechUtterance(string: selectedWords[index])
            utterance.voice = AVSpeechSynthesisVoice(language: chosenLang)
            
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }        
    }
    
    

    
    /* Return to previous Controller */
    @IBAction func back(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        self.present(vc, animated: false, completion: nil)  // presenting controlller
    }
}



extension GameVC: UITableViewDelegate, UITableViewDataSource {
    
    /* function returning number of rows in table view */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWords.count  // returning elements amount in selectedWords array
    }
    
    /* fill cells with data */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == wordIndex {
            cell.backgroundColor =  #colorLiteral(red: 0.7960784314, green: 0.7960784314, blue: 0.7960784314, alpha: 1)  // change current words cell background color
        }
        else {
            cell.backgroundColor = UIColor.white  // if cell word not typed yet set background color to white
        }
        
        if previuosWordsIndex.contains(indexPath.row) && previousCorrect[indexPath.row] == true {
            cell.textLabel?.textColor = #colorLiteral(red: 0.03529411765, green: 0.4901960784, blue: 0.09803921569, alpha: 1) // change word color if it is correct typed
        }
        else if previuosWordsIndex.contains(indexPath.row) && previousCorrect[indexPath.row] == false {
            cell.textLabel?.textColor = #colorLiteral(red: 0.9647058824, green: 0.05882352941, blue: 0.0862745098, alpha: 1) // change word color if it is incorrect typed
        }
        else {
            cell.textLabel?.textColor = UIColor.black  // set word color to black if it's not typed yet
        }
        cell.selectionStyle = .none  // cannot select row in tableview
        cell.layer.cornerRadius = 5  // round cell corners
        cell.textLabel?.font = cell.textLabel?.font.withSize(25)   // set font size to 25
        cell.textLabel?.text = selectedWords[indexPath.row]  // set cell label text to word from words array
        return cell
    }
    
}

