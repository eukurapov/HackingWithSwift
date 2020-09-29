//
//  GameScene.swift
//  Project29
//
//  Created by Eugene Kurapov on 28.09.2020.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

func deg2rad(degrees: Int) -> Double {
    return Double(degrees) * .pi / 180
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var viewController: GameViewController!
    
    private var player1: SKSpriteNode!
    private var player2: SKSpriteNode!
    private var banana: SKSpriteNode!
    private var buildings = [BuildingNode]()
    
    private var currentPlayer = 1
    
    private var player1ScoreLabel: SKLabelNode!
    var player1Score = 0 {
        didSet {
            guard let player1ScoreLabel = player1ScoreLabel else { return }
            player1ScoreLabel.attributedText = NSAttributedString(string: "Player One: \(player1Score)", attributes: textAttributes)
        }
    }
    private var player2ScoreLabel: SKLabelNode!
    var player2Score = 0 {
        didSet {
            guard let player2ScoreLabel = player2ScoreLabel else { return }
            player2ScoreLabel.attributedText = NSAttributedString(string: "Player Two: \(player2Score)", attributes: textAttributes)
        }
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = bgColor
        
        physicsWorld.contactDelegate = self
        
        player1ScoreLabel = SKLabelNode()
        player1ScoreLabel.horizontalAlignmentMode = .left
        player1ScoreLabel.position = CGPoint(x: 20, y: 20)
        player1ScoreLabel.zPosition = 100
        addChild(player1ScoreLabel)
        player1ScoreLabel.attributedText = NSAttributedString(string: "Player Two: \(player1Score)", attributes: textAttributes)
        
        player2ScoreLabel = SKLabelNode()
        player2ScoreLabel.horizontalAlignmentMode = .right
        player2ScoreLabel.position = CGPoint(x: size.width-20, y: 20)
        player2ScoreLabel.zPosition = 100
        addChild(player2ScoreLabel)
        player2ScoreLabel.attributedText = NSAttributedString(string: "Player Two: \(player2Score)", attributes: textAttributes)

        createBuildings()
        createPlayers()
    }
    
    private func createBuildings() {
        var currentX: CGFloat = -15
        while currentX < size.width {
            let buildingSize = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += buildingSize.width + 2
            let building = BuildingNode(color: .clear, size: buildingSize)
            building.position = CGPoint(x: currentX - (buildingSize.width / 2), y: buildingSize.height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
        }
    }
    
    private func createPlayers() {
        player1 = createPlayerNode(named: player1Name, at: buildings[1])
        addChild(player1)
        player2 = createPlayerNode(named: player2Name, at: buildings[buildings.count - 2])
        addChild(player2)
    }
    
    private func createPlayerNode(named name: String, at building: BuildingNode) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player")
        player.name = name
        player.position = CGPoint(
            x: building.position.x,
            y: building.position.y + (building.size.height + player.size.height) / 2)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        return player
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity)/10
        let radians = deg2rad(degrees: angle)
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = bananaName
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width/2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        throwBanana(angle: radians, speed: speed)
    }
    
    private func throwBanana(angle: Double, speed: Double) {
        guard banana != nil else { return }
        let raiseArmImage = "player\(currentPlayer)Throw"
        let raiseArm = SKAction.setTexture(SKTexture(imageNamed: raiseArmImage))
        let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let pause = SKAction.wait(forDuration: 0.15)
        let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
        let impulse: CGVector
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            player1.run(sequence)
            impulse = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            player2.run(sequence)
            impulse = CGVector(dx: cos(angle) * -speed, dy: sin(angle) * speed)
        }
        banana.physicsBody?.applyImpulse(impulse)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        if firstNode.name == bananaName && secondNode.name == BuildingNode.nodeName {
            bananaHit(building: secondNode, at: contact.contactPoint)
        }
        if firstNode.name == bananaName {
            if secondNode.name == player1Name || secondNode.name == player2Name  {
                destroy(player: secondNode)
            }
        }
    }
    
    private func bananaHit(building: SKNode, at position: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(position, to: building)
        building.hit(at: buildingLocation)
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = position
            addChild(explosion)
        }
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        changePlayer()
    }
    
    private func destroy(player: SKNode) {
        guard let player = player as? SKSpriteNode else { return }
        
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        player.removeFromParent()
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        if currentPlayer == 1 {
            player1Score += 1
        } else {
            player2Score += 1
        }
        
        if player1Score == 3 || player2Score == 3 {
            let gameOver = SKLabelNode()
            gameOver.attributedText = NSAttributedString(
                string: "Player \(currentPlayer) wins!",
                attributes: textAttributes)
            gameOver.position = CGPoint(x: size.width/2, y: size.height/2)
            gameOver.numberOfLines = -1
            gameOver.zPosition = 100
            addChild(gameOver)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let newGame = GameScene(size: self.size)
                newGame.viewController = self.viewController
                self.viewController.currentGame = newGame

                self.changePlayer()
                newGame.currentPlayer = self.currentPlayer
                newGame.player1Score = self.player1Score
                newGame.player2Score = self.player2Score

                let transition = SKTransition.doorway(withDuration: 1.5)
                self.view?.presentScene(newGame, transition: transition)
            }
        }
    }
    
    private func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        viewController.activatePlayer(number: currentPlayer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    // MARK: - Constant Values
    
    private let bgColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
    
    private let player1Name: String = "player1"
    private let player2Name: String = "player2"
    private let bananaName: String = "banana"
    
    private let fontName: String = "Marker Felt"
    private let fontSize: CGFloat = 46.0
    private let textAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Marker Felt", size: 46.0)!,
        .strokeColor: UIColor.white,
        .strokeWidth: -2,
        .foregroundColor: UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
    ]
    
}
