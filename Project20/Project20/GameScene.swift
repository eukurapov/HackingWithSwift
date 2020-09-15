//
//  GameScene.swift
//  Project20
//
//  Created by Eugene Kurapov on 15.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var scoreLabel: SKLabelNode!
    
    private var fireworks = [SKNode]()
    
    private var timer: Timer!
    
    private var launchCount = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontSize = fontSize
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width - 50, y: size.height - 50)
        addChild(scoreLabel)
        
        score = 0
        
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > size.height + 100 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    private func gameOver() {
        timer.invalidate()
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOver)
    }
    
    // MARK: - Add Fireworks
    
    private func addFirework(xMovement: CGFloat, x: CGFloat, y: CGFloat) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = fireworkName
        firework.colorBlendFactor = 1
        node.addChild(firework)
        
        switch Int.random(in: 1...3) {
        case 1: firework.color = .cyan
        case 2: firework.color = .green
        default: firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        let follow = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(follow)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        addChild(node)
        fireworks.append(node)
    }
    
    @objc
    private func launchFireworks() {
        launchCount += 1
        if launchCount > maxLaunchCount {
            gameOver()
            return
        }
        switch Int.random(in: 1...4) {
        case 1:
            addFirework(xMovement: 0, x: size.width / 2 - 200, y: bottomEdge)
            addFirework(xMovement: 0, x: size.width / 2 - 100, y: bottomEdge)
            addFirework(xMovement: 0, x: size.width / 2, y: bottomEdge)
            addFirework(xMovement: 0, x: size.width / 2 + 100, y: bottomEdge)
            addFirework(xMovement: 0, x: size.width / 2 + 200, y: bottomEdge)
        case 2:
            addFirework(xMovement: -200, x: size.width / 2 - 200, y: bottomEdge)
            addFirework(xMovement: -100, x: size.width / 2 - 100, y: bottomEdge)
            addFirework(xMovement: 0, x: size.width / 2, y: bottomEdge)
            addFirework(xMovement: 100, x: size.width / 2 + 100, y: bottomEdge)
            addFirework(xMovement: 200, x: size.width / 2 + 200, y: bottomEdge)
        case 3:
            addFirework(xMovement: movement, x: leftEdge, y: bottomEdge + 400)
            addFirework(xMovement: movement, x: leftEdge, y: bottomEdge + 300)
            addFirework(xMovement: movement, x: leftEdge, y: bottomEdge + 200)
            addFirework(xMovement: movement, x: leftEdge, y: bottomEdge + 100)
            addFirework(xMovement: movement, x: leftEdge, y: bottomEdge)
        case 4:
            addFirework(xMovement: -movement, x: rightEdge, y: bottomEdge + 400)
            addFirework(xMovement: -movement, x: rightEdge, y: bottomEdge + 300)
            addFirework(xMovement: -movement, x: rightEdge, y: bottomEdge + 200)
            addFirework(xMovement: -movement, x: rightEdge, y: bottomEdge + 100)
            addFirework(xMovement: -movement, x: rightEdge, y: bottomEdge)
        default:
            break
        }
    }
    
    // MARK: - Gestures
    
    private func touchesCheck(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        
        for case let node as SKSpriteNode in touchNodes {
            if node.name == fireworkName {
                for parent in fireworks {
                    guard let firework = parent.children.first as? SKSpriteNode else { continue }
                    if firework.name == selectedName && firework.color != node.color {
                        firework.colorBlendFactor = 1
                        firework.name = fireworkName
                    }
                }
                node.name = selectedName
                node.colorBlendFactor = 0
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesCheck(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchesCheck(touches)
    }
    
    // MARK: - Explode
    
    private func explodeFirework(fireworkNode: SKNode) {
        if let explode = SKEmitterNode(fileNamed: "explode") {
            explode.position = fireworkNode.position
            addChild(explode)
        }
        fireworkNode.removeFromParent()
    }
    
    func explode() {
        var explodedNum = 0
        for (index, node) in fireworks.enumerated().reversed() {
            guard let firework = node.children.first as? SKSpriteNode else { continue }
            if firework.name == selectedName {
                explodeFirework(fireworkNode: node)
                fireworks.remove(at: index)
                explodedNum += 1
            }
        }
        score += explodedNum * 2^explodedNum
    }
    
    // MARK: - Constant Values
    
    private let fontName: String = "Chalkduster"
    private let fontSize: CGFloat = 46.0
    
    private let fireworkName = "firework"
    private let selectedName = "selected"
    
    private let leftEdge: CGFloat = -22
    private var rightEdge: CGFloat { size.width + 22 }
    private let bottomEdge: CGFloat = -22
    private var movement: CGFloat { size.width * 1.5 }
    
    private let maxLaunchCount = 10
}
