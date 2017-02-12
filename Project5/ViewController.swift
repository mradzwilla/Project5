//
//  ViewController.swift
//  Project5
//
//  Created by Michael Radzwilla on 2/11/17.
//  Copyright © 2017 swifttutorial. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))

        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        
        if title == nil{
            title = allWords[0]
        } else {
            let currentWordIndex = allWords.index(of: title!)!
            title = allWords[currentWordIndex + 1]
        }
        
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @IBAction func newWord(_ sender: UIButton) {
        startGame()
        
        let newWordAlert = UIAlertController(title: "New Word", message: "Your new word is \(title!)", preferredStyle: .alert)
        newWordAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(newWordAlert, animated: true)

    }
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] _ in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if lowerAnswer == title {
            returnErrorMessage(alertTitle: "That's the same word...", message: "That's a little too easy")
            return
        }
        
        if lowerAnswer.characters.count < 3 {
            returnErrorMessage(alertTitle: "Word Too Short", message: "Please make your word at least 3 letters long!")
            return
        }
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
            return
        }
        returnErrorMessage(alertTitle: errorTitle, message: errorMessage)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func returnErrorMessage(alertTitle: String, message: String){
        let ac = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}

