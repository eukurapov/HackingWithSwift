//
//  GameScene.swift
//  Project26
//
//  Created by Eugene Kurapov on 21.09.2020.
//

import SpriteKit
import CoreMotion

enum CollisionCategory: UInt32 {
    case player = 1
    case block = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player: SKSpriteNode!
    private var startPosition: CGPoint!
    
    private var currentLevel = 1
    private var isGameOver = false
    
    private var levelBlocks = [SKNode]()
    
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var motionManager: CMMotionManager?
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - 10)
        scoreLabel.zPosition = 2
        scoreLabel.fontSize = 46.0
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        addChild(scoreLabel)
        score = 0
        
        loadLevel()
        resetPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    private func loadLevel() {
        guard let path = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("Level file not found")
        }
        guard let levelString = try? String(contentsOf: path) else {
            fatalError("Couldn't read level file")
        }
        let levelLines = levelString.components(separatedBy: .newlines).filter { !$0.isEmpty }
        for (row, line) in levelLines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                switch letter {
                case "x":
                    let node = gameNodeFromImage("block", position: position, category: .block)
                    levelBlocks.append(node)
                    addChild(node)
                case "v":
                    let node = gameNodeFromImage("vortex", position: position, category: .vortex)
                    node.name = vortexName
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi, duration: 1)))
                    levelBlocks.append(node)
                    addChild(node)
                case "s":
                    let node = gameNodeFromImage("star", position: position, category: .star)
                    node.name = starName
                    levelBlocks.append(node)
                    addChild(node)
                case "f":
                    let node = gameNodeFromImage("finish", position: position, category: .finish)
                    node.name = finishName
                    levelBlocks.append(node)
                    addChild(node)
                case "t":
                    let node = gameNodeFromImage("vortex", position: position, category: .teleport)
                    node.name = teleportName
                    node.colorBlendFactor = 1
                    node.color = .cyan
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi, duration: 1)))
                    levelBlocks.append(node)
                    addChild(node)
                case "p":
                    startPosition = position
                case " ": break
                default: fatalError("Unknown letter \(letter)")
                }
            }
        }
    }
    
    private func gameNodeFromImage(_ imageName: String, position: CGPoint, category: CollisionCategory) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: imageName)
        node.position = position
        if category == .block {
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.collisionBitMask = CollisionCategory.player.rawValue
        } else {
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
            node.physicsBody?.contactTestBitMask = CollisionCategory.player.rawValue
            node.physicsBody?.collisionBitMask = 0
        }
        node.physicsBody?.categoryBitMask = category.rawValue
        node.physicsBody?.isDynamic = false
        return node
    }
    
    private func resetPlayer() {
        guard startPosition != nil else { fatalError("Starting position is not set") }
        player = SKSpriteNode(imageNamed: "player")
        player.position = startPosition
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = CollisionCategory.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionCategory.block.rawValue
        player.physicsBody?.contactTestBitMask = CollisionCategory.star.rawValue | CollisionCategory.vortex.rawValue | CollisionCategory.finish.rawValue | CollisionCategory.teleport.rawValue
        addChild(player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        if let acceleration = motionManager?.accelerometerData?.acceleration {
            physicsWorld.gravity = CGVector(dx: acceleration.y * 40, dy: acceleration.x * (-40))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node as? SKSpriteNode else { return }
        guard let nodeB = contact.bodyB.node as? SKSpriteNode else { return }
        if nodeA == player {
            playerCollidedWith(nodeB)
        } else if nodeB == player {
            playerCollidedWith(nodeA)
        }
    }
    
    private func playerCollidedWith(_ node: SKSpriteNode) {
        switch node.name {
        case vortexName:
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            let move = SKAction.move(to: node.position, duration: 0.25)
            let fadeOut = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            player.run(SKAction.sequence([move, fadeOut, remove])) { [weak self] in
                self?.resetPlayer()
                self?.isGameOver = false
            }
        case teleportName:
            let move = SKAction.move(to: node.position, duration: 0.25)
            let fadeOut = SKAction.scale(to: 0.0001, duration: 0.25)
            player.run(SKAction.sequence([move, fadeOut])) { [unowned self] in
                if let teleport = levelBlocks.first(where: { $0 != node && $0.name == teleportName }) as? SKSpriteNode {
                    teleport.physicsBody?.categoryBitMask = 0
                    teleport.physicsBody?.contactTestBitMask = 0
                    teleport.color = .yellow
                    teleport.run(SKAction.wait(forDuration: 5)) {
                        teleport.physicsBody?.categoryBitMask = CollisionCategory.teleport.rawValue
                        teleport.physicsBody?.contactTestBitMask = CollisionCategory.player.rawValue
                        teleport.color = .cyan
                    }
                    player.position = teleport.position
                    player.run(SKAction.scale(to: 1, duration: 0.25))
                }
            }
        case starName:
            score += 1
            let scale = SKAction.scale(to: 1.5, duration: 0.2)
            let fadeOut = SKAction.scale(to: 0.0001, duration: 0.4)
            let remove = SKAction.removeFromParent()
            node.run(SKAction.sequence([scale, fadeOut, remove]))
            if let index = levelBlocks.firstIndex(of: node) {
                levelBlocks.remove(at: index)
            }
        case finishName:
            score += 5
            player.physicsBody?.isDynamic = false
            isGameOver = true
            currentLevel += 1
            let move = SKAction.move(to: node.position, duration: 0.25)
            let fadeOut = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            player.run(SKAction.sequence([move, fadeOut, remove]))
            let flip = SKAction.sequence([SKAction.scaleX(to: 0, duration: 0.2), SKAction.scaleX(to: -1, duration: 0.2)])
            node.run(flip) { [unowned self] in
                if currentLevel <= maxLevel {
                    for block in levelBlocks {
                        block.removeFromParent()
                    }
                    levelBlocks.removeAll(keepingCapacity: true)
                    loadLevel()
                    resetPlayer()
                    isGameOver = false
                } else {
                    let gameOver = SKSpriteNode(imageNamed: "gameOver")
                    gameOver.position = CGPoint(x: size.width/2, y: size.height/2)
                    gameOver.zPosition = 2
                    addChild(gameOver)
                }
            }
        default: return
        }
    }
    
    // MARK: - Constant Values
    
    private let fontName: String = "Chalkduster"
    
    private let vortexName: String = "vortex"
    private let starName: String = "star"
    private let finishName: String = "finish"
    private let teleportName: String = "teleport"
    
    private let maxLevel = 2
}
