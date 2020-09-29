//
//  BuildingNode.swift
//  Project29
//
//  Created by Eugene Kurapov on 28.09.2020.
//

import UIKit
import SpriteKit
import CoreGraphics

class BuildingNode: SKSpriteNode {
    
    private var currentImage: UIImage!
    
    func setup() {
        name = BuildingNode.nodeName
        
        currentImage = drawBuilding()
        texture = SKTexture(image: currentImage)
        
        setPhysicsBody()
    }
    
    private func drawBuilding() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let color: UIColor
            switch Int.random(in: 0...2) {
            case 0: color = color1
            case 1: color = color2
            default: color = color3
            }
            color.setFill()
            cgContext.fill(rect)
            
            for row in stride(from: 10, to: Int(size.width - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.height - 10), by: 40) {
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    cgContext.fill(CGRect(x: row, y: col, width: windowWidth, height: windowHeight))
                }
            }
        }
        
        return image
    }
    
    private func setPhysicsBody() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        physicsBody?.isDynamic = false
    }
    
    func hit(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            currentImage.draw(at: .zero)
            cgContext.setBlendMode(.clear)
            cgContext.fillEllipse(in: CGRect(x: convertedPoint.x - hitSize/2, y: convertedPoint.y - hitSize/2, width: hitSize, height: hitSize))
        }
        texture = SKTexture(image: image)
        currentImage = image
        setPhysicsBody()
    }

    
    // MARK: - Constant Values
    
    static let nodeName = "building"
    
    private let hitSize: CGFloat = 64
    private let windowWidth = 15
    private let windowHeight = 20
    
    private let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
    private let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
    private let color1 = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
    private let color2 = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
    private let color3 = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
}
