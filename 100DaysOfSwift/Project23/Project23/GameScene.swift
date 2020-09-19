//
//  GameScene.swift
//  Project23
//
//  Created by Eugene Kurapov on 19.09.2020.
//

import SpriteKit
import AVFoundation

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var gameOver: SKSpriteNode!
    private var startGame: SKLabelNode!
    
    private var lifeImages = [SKSpriteNode]()
    private var lifesLeft = 0 {
        didSet {
            if lifesLeft == 0 && !isGameEnded {
                endGame(bombTriggered: false)
            }
            for (index, image) in lifeImages.enumerated() {
                if index >= lifesLeft {
                    image.texture = SKTexture(imageNamed: "sliceLifeGone")
                    image.xScale = 1.3
                    image.yScale = 1.3
                    image.run(SKAction.scale(to: 1.0, duration: 0.2))
                } else {
                    image.texture = SKTexture(imageNamed: "sliceLife")
                }
            }
        }
    }
    
    private var slicePoints = [CGPoint]()
    private var sliceBG: SKShapeNode!
    private var sliceFG: SKShapeNode!
    
    private var isSwooshSoundActive = false
    
    private var enemies = [SKSpriteNode]()
    
    private var bombSound: AVAudioPlayer?
    
    private var sequence = [SequenceType]()
    private var currentSequence = 0
    private var popupTime = 0.9
    private var chainDelay = 3.0
    private var nextSequenceQueued = true
    
    private var isGameEnded = false
    
    // MARK: - Presenting Scene
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        
        addStartGame()
        addLifes()
        addScore()
        addSlices()
    }
    
    private func addStartGame() {
        startGame = SKLabelNode(fontNamed: fontName)
        startGame.position = CGPoint(x: size.width/2, y: size.height/2)
        startGame.text = "Start Game"
        startGame.fontSize = largeFontSize
        addChild(startGame)
    }
    
    private func addGameOver() {
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: size.width/2, y: size.height/2 + 150)
        addChild(gameOver)
    }
    
    private func addScore() {
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = largeFontSize
        addChild(scoreLabel)
        score = 0
    }
    
    private func addLifes() {
        for index in 0..<maxLifes {
            let lifeImage = SKSpriteNode(imageNamed: "sliceLife")
            lifeImage.position = CGPoint(x: size.width - 40 - CGFloat(70*index), y: size.height - 40)
            lifeImages.append(lifeImage)
            addChild(lifeImage)
        }
        lifesLeft = maxLifes
    }
    
    private func addSlices() {
        sliceBG = SKShapeNode()
        sliceBG.strokeColor = .yellow
        sliceBG.lineWidth = 9
        sliceBG.zPosition = 2
        addChild(sliceBG)
        
        sliceFG = SKShapeNode()
        sliceFG.strokeColor = .white
        sliceFG.lineWidth = 6
        sliceFG.zPosition = 3
        addChild(sliceFG)
    }
    
    private func redrawSlices() {
        if slicePoints.count < 2 {
            sliceBG.path = nil
            sliceFG.path = nil
            return
        }
        if slicePoints.count > 12 {
            slicePoints.removeFirst(slicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: slicePoints[0])
        for i in 1..<slicePoints.count {
            path.addLine(to: slicePoints[i])
        }
        sliceBG.path = path.cgPath
        sliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !enemies.isEmpty {
            for (index, enemy) in enemies.enumerated().reversed() {
                if enemy.position.y < -140 {
                    if enemy.name == enemyName {
                        enemy.name = ""
                        enemy.removeFromParent()
                        enemies.remove(at: index)
                        lifesLeft -= 1
                        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
                    } else if enemy.name == bombContainerName {
                        enemy.name = ""
                        enemy.removeFromParent()
                        enemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }
        if enemies.filter({ $0.name == bombContainerName }).isEmpty {
            bombSound?.stop()
            bombSound = nil
        }
    }
    
    private func start() {
        isGameEnded = false
        score = 0
        lifesLeft = maxLifes
        
        currentSequence = 0
        popupTime = 0.9
        chainDelay = 3.0
        physicsWorld.speed = 0.85
        
        startGame.removeFromParent()
        if gameOver != nil { gameOver.removeFromParent() }
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    private func endGame(bombTriggered: Bool) {
        if isGameEnded { return }

        isGameEnded = true

        bombSound?.stop()
        bombSound = nil
        
        addGameOver()
        addStartGame()
        
        for enemy in enemies {
            enemy.removeFromParent()
        }
        enemies.removeAll()

        if bombTriggered {
            lifesLeft = 0
        }
    }
    
    // MARK: - Enemies
    
    private func tossEnemies() {
        if isGameEnded { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        let sequenceType = sequence[currentSequence]

        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }
        case .fastChain:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }

        currentSequence += 1
        nextSequenceQueued = false
    }
    
    private func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        var enemyType = Int.random(in: 0...6)
        if forceBomb == .always {
            enemyType = 0
        } else if forceBomb == .never {
            enemyType = 1
        }
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.name = bombContainerName
            let bomb = SKSpriteNode(imageNamed: "sliceBomb")
            bomb.name = bombName
            enemy.addChild(bomb)
            enemy.zPosition = 1
            resetBombSound()
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.name = enemyName
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        }
        addChild(enemy)
        setPositionFor(enemy)
        enemies.append(enemy)
    }
    
    private func setPositionFor(_ enemy: SKSpriteNode) {
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition

        let randomAngularVelocity = CGFloat.random(in: -3...3 )
        let randomXVelocity: Int
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        let randomYVelocity = Int.random(in: 24...32)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
    }
    
    private func resetBombSound() {
        if bombSound != nil {
            bombSound?.stop()
            bombSound = nil
        }
        if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
            bombSound = try? AVAudioPlayer(contentsOf: path)
            bombSound?.play()
        }
    }
    
    private func scaleOutAndRemove(_ node: SKSpriteNode) {
        node.physicsBody?.isDynamic = false
        
        let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])
        let sequence = SKAction.sequence([group, .removeFromParent()])
        node.run(sequence)
        
        if let index = enemies.firstIndex(of: node) {
            enemies.remove(at: index)
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        slicePoints.removeAll(keepingCapacity: true)
        let position = touch.location(in: self)
        slicePoints.append(position)
        redrawSlices()
        sliceBG.removeAllActions()
        sliceFG.removeAllActions()
        sliceBG.alpha = 1
        sliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameEnded { return }
        
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        slicePoints.append(position)
        redrawSlices()
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let touchNodes = nodes(at: position)
        for case let node as SKSpriteNode in touchNodes {
            if node.name == enemyName {
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                node.name = ""
                scaleOutAndRemove(node)
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                score += 1
            } else if node.name == bombName {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                node.name = ""
                scaleOutAndRemove(bombContainer)
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(bombTriggered: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sliceBG.run(SKAction.fadeOut(withDuration: 0.2))
        sliceFG.run(SKAction.fadeOut(withDuration: 0.2))
        
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let touchNodes = nodes(at: position)
        if touchNodes.contains(startGame) {
            start()
        }
    }
    
    // MARK: - Constant Values
    
    private let fontName: String = "Chalkduster"
    private let largeFontSize: CGFloat = 46.0
    
    private let maxLifes: Int = 3
    
    private let bombContainerName: String = "bombContainer"
    private let enemyName: String = "enemy"
    private let bombName: String = "bomb"
    
}
