//
//  ViewController.swift
//  Project8
//
//  Created by Eugene Kurapov on 28.08.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var scoreLabel: UILabel!
    private var questionsLabel: UILabel!
    private var answersLabel: UILabel!
    private var answer: UITextField!
    private var letterButtons = [UIButton]()
    
    private var selectedLetters = [UIButton]()
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var foundWords = 0
    private var level = 1
    private var answers = [String]()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        questionsLabel = UILabel()
        questionsLabel.translatesAutoresizingMaskIntoConstraints = false
        questionsLabel.font = UIFont.systemFont(ofSize: 24)
        questionsLabel.numberOfLines = 0
        questionsLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        questionsLabel.text = "QUESTIONS"
        view.addSubview(questionsLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.numberOfLines = 0
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        answersLabel.textAlignment = .right
        answersLabel.text = "ANSWERS"
        view.addSubview(answersLabel)
        
        answer = UITextField()
        answer.translatesAutoresizingMaskIntoConstraints = false
        answer.font = UIFont.systemFont(ofSize: 44)
        answer.textAlignment = .center
        answer.isUserInteractionEnabled = false
        answer.placeholder = "Tap letters to guess"
        view.addSubview(answer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        submit.setTitle("SUBMIT", for: .normal)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.addTarget(self, action: #selector(clearAnswer), for: .touchUpInside)
        clear.setTitle("CLEAR", for: .normal)
        view.addSubview(clear)
        
        let buttonsContainer = UIView()
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.layer.borderColor = UIColor.lightGray.cgColor
        buttonsContainer.layer.borderWidth = 1
        buttonsContainer.layer.cornerRadius = 10
        view.addSubview(buttonsContainer)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            questionsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            questionsLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            questionsLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: questionsLabel.heightAnchor),
            
            answer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            answer.topAnchor.constraint(equalTo: questionsLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: answer.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsContainer.widthAnchor.constraint(equalToConstant: 750),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 320),
            buttonsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsContainer.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let cellWidth = 150
        let cellHeight = 80
        let cols = 5
        let rows = 4
        for row in 0..<rows {
            for col in 0..<cols {
                let button = UIButton(type: .system)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                button.setTitle("WWW", for: .normal)
                button.frame = CGRect(
                    x: col * cellWidth,
                    y: row * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                button.addTarget(self, action: #selector(selectLetter), for: .touchUpInside)
                buttonsContainer.addSubview(button)
                letterButtons.append(button)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
    }
    
    @objc
    private func selectLetter(_ sender: UIButton) {
        if let letters = sender.titleLabel?.text {
            answer.text?.append(contentsOf: letters)
            selectedLetters.append(sender)
            sender.isShown(false)
        }
    }
    
    @objc
    private func submitAnswer() {
        if let word = answer.text {
            if let index = answers.firstIndex(of: word) {
                score += 1
                foundWords += 1
                answer.text = ""
                selectedLetters.removeAll()
                var answersLines = answersLabel.text?.components(separatedBy: .newlines)
                answersLines?[index] = word
                answersLabel.text = answersLines?.joined(separator: "\n")
                
                if foundWords % 7 == 0 {
                    let ac = UIAlertController(
                        title: "Next Level",
                        message: "Good job! Let's proceed with the next level!",
                        preferredStyle: .alert)
                    ac.addAction(UIAlertAction(
                        title: "GO!",
                        style: .default,
                        handler: { _ in
                            self.level += 1
                            self.loadLevel()
                    }))
                    present(ac, animated: true)
                }
            } else {
                score -= 1
                let ac = UIAlertController(
                    title: "Wrong",
                    message: "That's not a word you're looking for",
                    preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    @objc
    private func clearAnswer() {
        answer.text = ""
        for button in selectedLetters {
            button.isShown(true)
        }
        selectedLetters.removeAll()
    }

    private func loadLevel() {
        var answersText = ""
        var questionsText = ""
        var letters = [String]()
        answers.removeAll()
        if let url = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let sourceString = try? String(contentsOf: url) {
                var lines = sourceString.components(separatedBy: .newlines).filter { !$0.isEmpty }
                lines.shuffle()
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    letters.append(contentsOf: parts[0].components(separatedBy: "|"))
                    let answer = parts[0].replacingOccurrences(of: "|", with: "")
                    answersText += "\(answer.count) letters\n"
                    answers.append(answer)
                    questionsText += "\(index + 1). \(parts[1])\n"
                }
                letterButtons.shuffle()
                if letterButtons.count == letters.count {
                    for index in letterButtons.indices {
                        letterButtons[index].isShown(true)
                        letterButtons[index].setTitle(letters[index], for: .normal)
                    }
                }
                questionsLabel.text = questionsText.trimmingCharacters(in: .whitespacesAndNewlines)
                answersLabel.text = answersText.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}

extension UIButton {
    
    func isShown(_ value: Bool) {
        UIView.animate(
            withDuration: 1,
            animations: {
                self.alpha = (value ? 1 : 0)
        })
    }
    
}

