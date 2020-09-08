//
//  GameScene.swift
//  Project14
//
//  Created by Eugene Kurapov on 07.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var numRounds = 0
    
    private var scoreLabel: SKLabelNode!
    private var gameOver: SKSpriteNode!
    private var start: SKLabelNode!
    
    private var slots = [WhackNode]()
    private var popupTime = 0.85

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 42.0
        addChild(scoreLabel)
        
        for i in 0..<5 { addNode(at: CGPoint(x: 100 + 170 * i, y: 410)) }
        for i in 0..<4 { addNode(at: CGPoint(x: 180 + 170 * i, y: 320)) }
        for i in 0..<5 { addNode(at: CGPoint(x: 100 + 170 * i, y: 230)) }
        for i in 0..<4 { addNode(at: CGPoint(x: 180 + 170 * i, y: 140)) }
        
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOver.zPosition = 1
        gameOver.isHidden = true
        addChild(gameOver)
        
        start = SKLabelNode(fontNamed: "Chalkduster")
        start.text = "START NEW GAME"
        start.fontSize = 48.0
        start.name = startButton
        start.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        start.zPosition = 1
        addChild(start)
    }
    
    private func startGame() {
        numRounds = 0
        score = 0
        gameOver.isHidden = true
        start.isHidden = true
        for slot in slots {
            slot.isHit = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.popup()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node.name == startButton {
                startGame()
            } else {
                guard let whackNode = node.parent?.parent as? WhackNode else { continue }
                guard whackNode.isVisible else { continue }
                guard !whackNode.isHit else { continue }
                
                whackNode.hit()
                if whackNode.penguin.name == "friend" {
                    score -= 5
                    run(SKAction.playSoundFileNamed("whackBad", waitForCompletion: false))
                } else if whackNode.penguin.name == "enemy" {
                    whackNode.penguin.xScale = 0.85
                    whackNode.penguin.yScale = 0.85
                    score += 1
                    run(SKAction.playSoundFileNamed("whack", waitForCompletion: false))
                }
            }
        }
    }
    
    private func addNode(at position: CGPoint) {
        let node = WhackNode()
        node.configure(at: position)
        slots.append(node)
        addChild(node)
    }
    
    private func popup() {
        numRounds += 1

        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            gameOver.isHidden = false
            start.isHidden = false

            return
        }
        
        popupTime *= 0.991
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)  }
        
        let minDelay = popupTime / 2
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.popup()
        }
    }
    
    // MARK: - Constant Values
    
    private let startButton = "StartButton"
}
