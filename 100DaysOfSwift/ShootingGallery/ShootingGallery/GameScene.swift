//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Eugene Kurapov on 14.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var scoreLabel: SKLabelNode!
    
    private var startLabel: SKLabelNode!
    private var gameOver: SKSpriteNode?
    
    private var isGameOver: Bool = true
    
    private var shotsCount = 0 {
        didSet {
            shots.texture = SKTexture(imageNamed: "shots\(shotsCount)")
        }
    }
    private var shots: SKSpriteNode!
    
    private var timer: Timer?
    
    private var counter: Int = 0 {
        didSet {
            counterLabel.text = "\(counter)"
        }
    }
    private var counterLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.blendMode = .replace
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.scale(to: size)
        addChild(background)
        
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: size.width / 2, y: size.height / 2)
        curtains.zPosition = 10
        curtains.scale(to: size)
        addChild(curtains)
        
        let trees = SKSpriteNode(imageNamed: "grass-trees")
        trees.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        trees.zPosition = 1
        trees.setScale(size.width / trees.size.width)
        addChild(trees)
        
        let whaterBG = SKSpriteNode(imageNamed: "water-bg")
        whaterBG.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        whaterBG.zPosition = 3
        whaterBG.setScale(size.width / whaterBG.size.width)
        addChild(whaterBG)
        
        let whaterFG = SKSpriteNode(imageNamed: "water-fg")
        whaterFG.position = CGPoint(x: size.width / 2, y: size.height / 2 - 220)
        whaterFG.zPosition = 5
        whaterFG.setScale(size.width / whaterFG.size.width)
        addChild(whaterFG)
        
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontSize = headerFontSize
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width - 150, y: 50)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        counterLabel = SKLabelNode(fontNamed: fontName)
        counterLabel.fontSize = headerFontSize
        counterLabel.horizontalAlignmentMode = .left
        counterLabel.position = CGPoint(x: 150, y: size.height - 50)
        counterLabel.zPosition = 100
        addChild(counterLabel)
        
        shots = SKSpriteNode(imageNamed: "shots3")
        shots.position = CGPoint(x: 200, y: 75)
        shots.setScale(1.5)
        shots.zPosition = 100
        addChild(shots)
        
        startLabel = addStartLabel()
    }
    
    private func startGame() {
        isGameOver = false
        score = 0
        counter = timeToPlay
        shotsCount = maxShotsCount
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addTarget), userInfo: nil, repeats: true)
        startLabel.removeFromParent()
        gameOver?.removeFromParent()
    }
    
    private func finishGame() {
        isGameOver = true
        timer?.invalidate()
        startLabel = addStartLabel()
        gameOver = addGameOver()
    }
    
    private var previousRow = 0
    @objc
    private func addTarget() {
        if counter % 2 == 0 || counter % 3 == 0 {
            var row = Int.random(in: 1...3)
            if row == previousRow { row = row == 3 ? 1 : row + 1 }
            previousRow = row
            let target = TargetNode()
            let startingX: CGFloat
            let destinationX: CGFloat
            let startingY: CGFloat
            switch row {
            case 1:
                startingX = size.width + 50
                destinationX = -50
                startingY = 250
                target.zPosition = firstRowZPosition
                target.xScale = -1
            case 2:
                startingX = 50
                destinationX = size.width + 50
                startingY = 350
                target.zPosition = secondRowZPosition
            case 3:
                startingX = size.width + 50
                destinationX = -50
                startingY = 480
                target.zPosition = thirdRowZPosition
                target.xScale = -1
            default: return
            }
            target.configure(at: CGPoint(x: startingX, y: startingY))
            target.target.name = targetName
            addChild(target)
            let speed = Int.random(in: 1...3)
            target.points = speed
            target.run(
                SKAction.moveTo(x: destinationX, duration: TimeInterval(5-speed)),
                completion: {
                    target.removeFromParent()
            })
        }
        counter -= 1
        if counter == 0 {
            finishGame()
        }
    }
    
    private func addStartLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: fontName)
        label.text = "Start Game"
        label.fontSize = headerFontSize
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 100
        addChild(label)
        return label
    }
    
    private func addGameOver() -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "game-over")
        node.position = CGPoint(x: size.width / 2, y: 150 + size.height / 2)
        node.zPosition = 100
        addChild(node)
        return node
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        if touchNodes.contains(startLabel) {
            startGame()
            return
        }
        
        if !isGameOver {
            if touchNodes.contains(shots) {
                shotsCount = maxShotsCount
                run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
            } else {
                if shoot(at: position) {
                    for node in touchNodes {
                        if node.name == targetName {
                            if let targetNode = node.parent as? TargetNode {
                                score += targetNode.points
                                targetNode.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func shoot(at position: CGPoint) -> Bool {
        if shotsCount > 0 {
            run(SKAction.playSoundFileNamed("shot", waitForCompletion: false))
            let shot = SKSpriteNode(imageNamed: "cursor")
            shot.position = position
            shot.zPosition = 100
            shot.setScale(1.5)
            addChild(shot)
            shot.run(
                SKAction.fadeOut(withDuration: 1.2),
                completion: {
                    shot.removeFromParent()
            })
            shotsCount -= 1
            return true
        }
        run(SKAction.playSoundFileNamed("empty", waitForCompletion: false))
        return false
    }
    
    // MARK: - Constant Values
    
    private let fontName: String = "Chalkduster"
    private let headerFontSize: CGFloat = 46.0
    
    private let firstRowZPosition: CGFloat = 6
    private let secondRowZPosition: CGFloat = 4
    private let thirdRowZPosition: CGFloat = 2
    
    private let maxShotsCount = 3
    private let targetName = "target"
    private let timeToPlay = 60

}
