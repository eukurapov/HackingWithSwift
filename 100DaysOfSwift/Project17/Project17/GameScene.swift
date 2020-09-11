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
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var isGameOver = true {
        didSet {
            gameOver.isHidden = !isGameOver
            startGame.isHidden = !isGameOver
        }
    }
    
    private var possibleEnemies = ["ball", "hammer", "tv"]
    private var timer: Timer!
    
    private var gameOver: SKSpriteNode!
    private var startGame: SKLabelNode!
    
    private var isMoving = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        let starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: size.width, y: size.height/2)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOver.isHidden = true
        addChild(gameOver)
        
        startGame = SKLabelNode(fontNamed: "Chalkduster")
        startGame.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        startGame.fontSize = 44.0
        startGame.text = "Start Game"
        addChild(startGame)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    @objc
    private func generateEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let enemyNode = SKSpriteNode(imageNamed: enemy)
        enemyNode.position = CGPoint(x: size.width + 300, y: CGFloat.random(in: 50...(size.height-50)))
        enemyNode.name = "enemy"
        addChild(enemyNode)
        
        enemyNode.physicsBody = SKPhysicsBody(texture: enemyNode.texture!, size: enemyNode.size)
        enemyNode.physicsBody?.categoryBitMask = 1
        enemyNode.physicsBody?.angularVelocity = 5
        enemyNode.physicsBody?.angularDamping = 0
        enemyNode.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemyNode.physicsBody?.linearDamping = 0
    }
    
    @objc
    private func start() {
        score = 0
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: size.height/2)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        let fire = SKEmitterNode(fileNamed: "fire")!
        fire.position = CGPoint(x: -player.size.width/2, y: 0)
        player.addChild(fire)
        
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(generateEnemy), userInfo: nil, repeats: true)
        
        isGameOver = false
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
                if location.y < 100 { location.y = 100 }
                if location.y > size.height - 100 { location.y = size.height - 100 }
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
        
        if !isGameOver {
            score += 1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)

        player.removeFromParent()
        timer.invalidate()
        for node in children {
            if node.name == "enemy" {
                node.removeFromParent()
            }
        }
        isGameOver = true
    }
}
