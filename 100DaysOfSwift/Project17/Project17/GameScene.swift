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
    private var isGameOver = false
    
    private var possibleEnemies = ["ball", "hammer", "tv"]
    private var timer: Timer!
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        let starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: size.width, y: size.height/2)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: size.height/2)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(generateEnemy), userInfo: nil, repeats: true)
    }
    
    @objc
    private func generateEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let enemyNode = SKSpriteNode(imageNamed: enemy)
        enemyNode.position = CGPoint(x: size.width + 300, y: CGFloat.random(in: 50...(size.height-50)))
        addChild(enemyNode)
        
        enemyNode.physicsBody = SKPhysicsBody(texture: enemyNode.texture!, size: enemyNode.size)
        enemyNode.physicsBody?.categoryBitMask = 1
        enemyNode.physicsBody?.angularVelocity = 5
        enemyNode.physicsBody?.angularDamping = 0
        enemyNode.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemyNode.physicsBody?.linearDamping = 0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        var location = touch.location(in: self)
        if location.y < 100 { location.y = 100 }
        if location.y > size.height - 100 { location.y = size.height - 100 }
        player.position = location
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
        isGameOver = true
        timer.invalidate()
    }
}
