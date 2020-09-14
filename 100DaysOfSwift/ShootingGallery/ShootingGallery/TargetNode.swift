//
//  TargetNode.swift
//  ShootingGallery
//
//  Created by Eugene Kurapov on 14.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import SpriteKit

class TargetNode: SKNode {
    
    var target: SKSpriteNode!
    private var stick: SKSpriteNode!
    
    var points = 1
    
    func configure(at position: CGPoint) {
        self.position = position
        let targetImage = possibleTargets.randomElement()!
        target = SKSpriteNode(imageNamed: targetImage)
        addChild(target)
        
        let stickName = possibleSticks.randomElement()!
        stick = SKSpriteNode(imageNamed: stickName)
        stick.position = CGPoint(x: 0, y: -(target.size.height+5))
        addChild(stick)
    }
    
    func dismiss() {
        target.run(SKAction.scaleX(to: 0, duration: 0.7))
//            ,
//            completion: { [unowned self] in
//                self.stick.run(
//                    SKAction.move(by: CGVector(dx: 0, dy: -700), duration: 2),
//                    completion: {
//                        self.removeFromParent()
//                })
//        })
    }
    
    // MARK: - Constant Values
    
    private let possibleTargets = ["target0", "target1", "target2", "target3"]
    private let possibleSticks = ["stick0", "stick1", "stick2"]
    
}
