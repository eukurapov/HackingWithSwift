//
//  ViewController.swift
//  Hangman
//
//  Created by Eugene Kurapov on 31.08.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let maxAttmpts = 7
    
    private var word: String! {
        didSet {
            word = word.uppercased()
            wordLabel.text = maskedWord
        }
    }
    private var usedLetters = [String]()
    private var failedAttempts: Int! {
        didSet {
            attemptsLabel.text = "\(maxAttmpts - failedAttempts) attempts left"
        }
    }
    private var score: Int! {
        didSet {
            scoreLabel.text = "Score: \(score!)"
        }
    }
    
    private var scoreLabel: UILabel!
    private var attemptsLabel: UILabel!
    private var wordLabel: UILabel!
    private var letter: UITextField!
    
    private var maskedWord: String {
        var maskedWord = ""
        for letter in word {
            if usedLetters.contains(String(letter)) {
                maskedWord.append(letter)
            } else {
                maskedWord.append("?")
            }
        }
        return maskedWord
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score"
        view.addSubview(scoreLabel)
        
        attemptsLabel = UILabel()
        attemptsLabel.translatesAutoresizingMaskIntoConstraints = false
        attemptsLabel.textAlignment = .right
        attemptsLabel.text = "Attempts"
        view.addSubview(attemptsLabel)
        
        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 44)
        wordLabel.text = "WORD"
        view.addSubview(wordLabel)
        
        letter = UITextField()
        letter.translatesAutoresizingMaskIntoConstraints = false
        letter.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 36)
        letter.addTarget(self, action: #selector(onLetterEdit), for: .editingChanged)
        letter.placeholder = "?"
        view.addSubview(letter)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("Check", for: .normal)
        submit.addTarget(self, action: #selector(checkLetter), for: .touchUpInside)
        view.addSubview(submit)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            attemptsLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            attemptsLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            letter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            letter.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
            
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submit.topAnchor.constraint(equalTo: letter.bottomAnchor),
            submit.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGame()
    }
    
    private func initGame(fromStart: Bool = true) {
        failedAttempts = 0
        score = fromStart ? 0 : score + 1
        usedLetters.removeAll()
        word = loadWord()
    }
    
    private func loadWord() -> String {
        var word = "RHYTHM"
        if let url = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let sourceString = try? String(contentsOf: url) {
                let words = sourceString.components(separatedBy: .newlines)
                if !words.isEmpty {
                    word = words.lazy.shuffled().first ?? word
                }
            }
        }
        print(word)
        return word
    }
    
    @objc
    private func onLetterEdit() {
        if let text = letter.text, !text.isEmpty {
            letter.text = String(text.last!).uppercased()
        } else {
            letter.text = ""
        }
    }
    
    @objc
    private func checkLetter() {
        if let suggestedLetter = letter.text?.last {
            let letterStr = String(suggestedLetter)
            if !usedLetters.contains(letterStr) {
                usedLetters.append(letterStr)
                if word.contains(suggestedLetter) {
                    wordLabel.text = maskedWord
                } else {
                    failedAttempts += 1
                }
            }
            letter.text = ""
            if maskedWord == word {
                let ac = UIAlertController(
                    title: "Congratulations!",
                    message: "You've guessed the word!",
                    preferredStyle: .alert)
                ac.addAction(UIAlertAction(
                    title: "Next",
                    style: .default,
                    handler: { _ in
                        self.initGame(fromStart: false)
                }))
                present(ac, animated: true)
            }
            if failedAttempts == maxAttmpts {
                let ac = UIAlertController(
                    title: "FAIL!",
                    message: "You couldn't guess a word. Your final score is \(score!).",
                    preferredStyle: .alert)
                ac.addAction(UIAlertAction(
                    title: "Start again",
                    style: .default,
                    handler: { _ in
                        self.initGame()
                }))
                present(ac, animated: true)
            }
        }
    }

}

