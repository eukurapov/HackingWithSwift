//
//  ViewController.swift
//  Project2
//
//  Created by Evgeniy Kurapov on 10.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionsAsked = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "spain", "uk", "us", "russia" ]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ⓘ", style: .done, target: self, action:  #selector(showScore))
        
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        questionsAsked += 1
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        //title = "Score: \(score), Country: \(countries[correctAnswer].uppercased())"
        title = countries[correctAnswer].uppercased()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var alertTitle: String
        var actionTitle = "Continue"
        var message = ""
        
        if (sender.tag == correctAnswer) {
            alertTitle = "Correct"
            score += 1
        } else {
            alertTitle = "Wrong"
            message =
            """
            It's \(countries[sender.tag].uppercased()).
            \(countries[correctAnswer].uppercased()) flag is number \(correctAnswer + 1).
            \n
            """
            score -= (score > 0 ? 1 : 0)
        }
        
        var ac: UIAlertController!
        if (questionsAsked < 10) {
            ac = UIAlertController(title: alertTitle, message: message + "Your score is \(score)", preferredStyle: .alert)
        } else {
            ac = UIAlertController(title: alertTitle, message: message + "Your final score is \(score)", preferredStyle: .alert)
            actionTitle = "Start again"
            questionsAsked = 0
            score = 0
        }
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    @objc func showScore() {
        let ac = UIAlertController(title: "Score", message: "Your score is \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }

}

