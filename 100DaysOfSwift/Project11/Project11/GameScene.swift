//
//  GameScene.swift
//  Project11
//
//  Created by Eugene Kurapov on 02.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var scoreLabel: SKLabelNode!
    
    private var isEdit = false {
        didSet {
            editLabel.text = isEdit ? "Done" : "Edit"
        }
    }
    private var editLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        addSlot(at: CGPoint(x: size.width * 1 / 8, y: 0), isGood: true)
        addSlot(at: CGPoint(x: size.width * 3 / 8, y: 0), isGood: false)
        addSlot(at: CGPoint(x: size.width * 5 / 8, y: 0), isGood: true)
        addSlot(at: CGPoint(x: size.width * 7 / 8, y: 0), isGood: false)
        
        addBouncer(at: CGPoint(x: 0, y: 0))
        addBouncer(at: CGPoint(x: size.width * 1 / 4, y: 0))
        addBouncer(at: CGPoint(x: size.width * 1 / 2, y: 0))
        addBouncer(at: CGPoint(x: size.width * 3 / 4, y: 0))
        addBouncer(at: CGPoint(x: size.width, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: size.width - 100, y: size.height - 100)
        scoreLabel.horizontalAlignmentMode = .right
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 100, y: size.height - 100)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            if touchedNodes.contains(editLabel) {
                isEdit.toggle()
            } else {
                if isEdit {
                    let box = SKSpriteNode(
                        color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
                        size: CGSize(width: Int.random(in: 16...64), height: 16))
                    box.position = location
                    box.zRotation = CGFloat.random(in: (-.pi/4)...(.pi/4))
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                } else {
                    let ball = SKSpriteNode(imageNamed: balls.randomElement()!)
                    ball.name = ballNodeName
                    ball.position = location
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    addChild(ball)
                }
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA.name == ballNodeName {
            collisionBetween(ball: nodeA, node: nodeB)
        } else if nodeB.name == ballNodeName {
            collisionBetween(ball: nodeB, node: nodeA)
        }
    }
    
    private func collisionBetween(ball: SKNode, node: SKNode) {
        if node.name == goodSlotNodeName {
            remove(ball: ball)
            score += 1
        } else if node.name == badSlotNodeName {
            remove(ball: ball)
            score -= 1
        }
    }
    
    private func remove(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    private func addBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.position = position
        addChild(bouncer)
    }
    
    private func addSlot(at position: CGPoint, isGood: Bool) {
        let slot: SKSpriteNode
        let glow: SKSpriteNode
        if isGood {
            slot = SKSpriteNode(imageNamed: "slotBaseGood")
            slot.name = goodSlotNodeName
            glow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slot = SKSpriteNode(imageNamed: "slotBaseBad")
            slot.name = badSlotNodeName
            glow = SKSpriteNode(imageNamed: "slotGlowBad")
        }
        slot.position = position
        slot.physicsBody = SKPhysicsBody(rectangleOf: slot.size)
        slot.physicsBody?.isDynamic = false
        glow.position = position
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        glow.run(spinForever)
        addChild(slot)
        addChild(glow)
    }
    
    // MARK: - Constant Values
    
    private let balls = ["ballRed", "ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballYellow", "ballPurple"]
    private let ballNodeName = "ball"
    private let goodSlotNodeName = "slotGood"
    private let badSlotNodeName = "slotBad"
    
}
