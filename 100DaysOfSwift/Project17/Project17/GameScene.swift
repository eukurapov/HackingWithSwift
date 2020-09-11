//
//  GameScene.swift
//  Project17
//
//  Created by Eugene Kurapov on 11.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "⭐️ \(score)"
        }
    }
    private var isGameOver = true {
        didSet {
            gameOver.isHidden = !isGameOver
            startGame.isHidden = !isGameOver
        }
    }
    
    private var possibleEnemies = ["ball", "hammer", "tv"]
    private var timer: Timer?
    
    private var gameOver: SKSpriteNode!
    private var startGame: SKLabelNode!
    
    private var isMoving = false
    private var countEnemies = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        let starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: size.width, y: size.height/2)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 44.0
        addChild(scoreLabel)
        
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOver.isHidden = true
        addChild(gameOver)
        
        startGame = SKLabelNode(fontNamed: fontName)
        startGame.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        startGame.fontSize = 44.0
        startGame.text = "Start Game"
        addChild(startGame)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    @objc
    private func generateEnemy() {
        let node: SKSpriteNode
        if Int.random(in: 1...5) == 1 {
            node = SKSpriteNode(imageNamed: "star")
            node.name = friendName
        } else {
            guard let enemy = possibleEnemies.randomElement() else { return }
            node = SKSpriteNode(imageNamed: enemy)
            node.name = enemyName
            
            countEnemies += 1
            if countEnemies % levelLimit == 0 {
                let interval = startInterval - stepInterval * Double(countEnemies / levelLimit)
                resetTimerFor(interval)
            }
        }
        node.position = CGPoint(x: size.width + 300, y: CGFloat.random(in: 50...(size.height-50)))
        addChild(node)
        
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.angularVelocity = 5
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        node.physicsBody?.linearDamping = 0
    }
    
    @objc
    private func start() {
        score = 0
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: size.height/2)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        player.physicsBody?.isDynamic = false
        addChild(player)
        
        let fire = SKEmitterNode(fileNamed: "fire")!
        fire.position = CGPoint(x: -player.size.width/2, y: 0)
        player.addChild(fire)
        
        resetTimerFor(startInterval)
        
        isGameOver = false
    }
    
    private func resetTimerFor(_ interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: startInterval, target: self, selector: #selector(generateEnemy), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchNodes = nodes(at: location)
        if player != nil, touchNodes.contains(player) { isMoving = true }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if !isGameOver {
            var location = touch.location(in: self)
            if isMoving {
                if location.y < movingThreshold { location.y = movingThreshold }
                if location.y > size.height - movingThreshold { location.y = size.height - movingThreshold }
                player.position = location
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchNodes = nodes(at: location)
        if touchNodes.contains(startGame) { start() }
        if player != nil, touchNodes.contains(player) { isMoving = false }
    }
 
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var collisionNode: SKNode?

        if contact.bodyA.node == player {
            collisionNode = contact.bodyB.node
        } else if contact.bodyB.node == player {
            collisionNode = contact.bodyA.node
        } else {
            return
        }
        
        if collisionNode?.name == enemyName {
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            explosion.position = player.position
            addChild(explosion)

            player.removeFromParent()
            timer?.invalidate()
            for node in children {
                if node.name == enemyName {
                    node.removeFromParent()
                }
            }
            isGameOver = true
        } else if collisionNode?.name == friendName {
            let magic = SKEmitterNode(fileNamed: "magic")!
            magic.position = contact.contactPoint
            addChild(magic)
            collisionNode?.removeFromParent()
            score += 1
        }
    }
    
    // MARK: - Constant Values
    
    private let fontName: String = "Chalkduster"
    private let levelLimit: Int = 20
    private let movingThreshold: CGFloat = 100
    private let enemyName = "enemy"
    private let friendName = "friend"
    private let startInterval: TimeInterval = 1
    private let stepInterval: TimeInterval = 0.1
}
