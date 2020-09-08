//
//  WhackNode.swift
//  Project14
//
//  Created by Eugene Kurapov on 07.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit

class WhackNode: SKNode {
    
    var isVisible = false
    var isHit = false
    var id: UUID!
    
    var penguin: SKSpriteNode!
    private var slot: SKSpriteNode!
    
    func configure(at position: CGPoint) {
        id = UUID()
        
        self.position = position
        
        slot = SKSpriteNode(imageNamed: "whackHole")
        addChild(slot)
        
        let mask = SKCropNode()
        mask.position = CGPoint(x: 0, y: 15)
        mask.zPosition = 1
        mask.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        penguin = SKSpriteNode(imageNamed: "penguinGood")
        penguin.position = CGPoint(x: 0, y: -90)
        penguin.zPosition = 2
        penguin.name = "penguin"
        mask.addChild(penguin)
        
        slot.addChild(mask)
    }
    
    func show(hideTime: Double) {
        guard !isVisible else { return }
        
        penguin.xScale = 1
        penguin.yScale = 1
        penguin.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            penguin.texture = SKTexture(imageNamed: "penguinGood")
            penguin.name = "friend"
        } else {
            penguin.texture = SKTexture(imageNamed: "penguinEvil")
            penguin.name = "enemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [unowned self] in
            self.hide()
        }
        
        runParticles(fileNamed: "MudParticles")
    }
    
    func hide() {
        guard isVisible else { return }
        guard !isHit else { return }
        
        penguin.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        runParticles(fileNamed: "SmokeParticles")
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        penguin.run(SKAction.sequence([delay, hide, notVisible]))
    }
    
    private func runParticles(fileNamed fileName: String) {
        if let emitter = SKEmitterNode(fileNamed: fileName) {
            self.addChild(emitter)
        }
    }
    
}
