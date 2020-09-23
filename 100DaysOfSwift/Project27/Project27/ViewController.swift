//
//  ViewController.swift
//  Project27
//
//  Created by Eugene Kurapov on 23.09.2020.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {
    
    typealias Actions = (UIGraphicsImageRendererContext) -> Void

    @IBOutlet weak var imageView: UIImageView!
    
    private var drawItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        draw(emoji)
    }

    @IBAction func redrawPressed(_ sender: UIButton) {
        drawItem += 1
        
        if drawItem > 6 {
            drawItem = 0
        }
        
        switch drawItem {
        case 0: draw(rectangle)
        case 1: draw(circle)
        case 2: draw(checkerboard)
        case 3: draw(rotatedSquares)
        case 4: draw(movingLines)
        case 5: draw(textAndImage)
        case 6: draw(emoji)
        default: break
        }
    }
    
    private func draw(_ actions: Actions) {
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: 512, height: 512))
        let image = renderer.image(actions: actions)
        imageView.image = image
    }
    
    private let rectangle: Actions = { context in
        let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
        context.cgContext.setFillColor(UIColor.red.cgColor)
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(10)
        context.cgContext.addRect(rect)
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    private let circle: Actions = { context in
        let rect = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
        context.cgContext.setFillColor(UIColor.red.cgColor)
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(10)
        context.cgContext.addEllipse(in: rect)
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    private let checkerboard: Actions = { context in
        context.cgContext.setFillColor(UIColor.black.cgColor)
        for row in 0..<8 {
            for col in 0..<8 {
                if (row + col) % 2 == 0 {
                    context.cgContext.addRect(CGRect(x: 64*row, y: 64*col, width: 64, height: 64))
                }
            }
        }
        context.cgContext.fillPath()
    }
    
    private let rotatedSquares: Actions = { context in
        let rotations = 16
        let stepAngle = CGFloat.pi / CGFloat(rotations)
        context.cgContext.translateBy(x: 256, y: 256)
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        for _ in 0..<rotations {
            context.cgContext.rotate(by: stepAngle)
            context.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
        }
        context.cgContext.strokePath()
    }
    
    private let movingLines: Actions = { context in
        context.cgContext.translateBy(x: 256, y: 256)
        var length: CGFloat = 256
        var first = true
        for _ in 0 ..< 256 {
            context.cgContext.rotate(by: .pi / 2)
            if first {
                context.cgContext.move(to: CGPoint(x: length, y: 50))
                first = false
            } else {
                context.cgContext.addLine(to: CGPoint(x: length, y: 50))
            }
            length *= 0.99
        }
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.strokePath()
    }
    
    private let textAndImage: Actions = { context in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let text = "Some quote\nabout man and a mouse"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36),
            .paragraphStyle: paragraphStyle
        ]
        let attrString = NSAttributedString(string: text, attributes: attributes)
        attrString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
        let mouse = UIImage(named: "mouse")
        mouse?.draw(at: CGPoint(x: 300, y: 150))
    }
    
    // 🙂
    private let emoji: Actions = { context in
        let cgContext = context.cgContext
        let rect = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
        
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.yellow.cgColor, UIColor.orange.cgColor] as CFArray,
            locations: [0.0, 1.0]
        ) else { return }
        
        cgContext.addEllipse(in: rect)
        cgContext.clip()
        cgContext.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.midX, y: rect.minX),
            end: CGPoint(x: rect.midX, y: rect.maxY),
            options: []
        )
        
        cgContext.setStrokeColor(UIColor.orange.cgColor)
        cgContext.setLineWidth(10)
        cgContext.addEllipse(in: rect)
        cgContext.strokePath()
        
        cgContext.addEllipse(in: CGRect(x: rect.midX - 100, y: rect.minY + 150, width: 50, height: 70))
        cgContext.addEllipse(in: CGRect(x: rect.midX + 50, y: rect.minY + 150, width: 50, height: 70))
        cgContext.setFillColor(UIColor.brown.cgColor)
        cgContext.setStrokeColor(UIColor.black.cgColor)
        cgContext.setLineWidth(3)
        cgContext.drawPath(using: .fillStroke)
        
        let smileStart = CGPoint(x: rect.midX - 150, y: rect.maxY - 200)
        let smileEnd = CGPoint(x: rect.midX + 150, y: rect.maxY - 200)
        cgContext.move(to: smileStart)
        cgContext.addQuadCurve(to: smileEnd, control: CGPoint(x: rect.midX, y: smileStart.y + 150))
        cgContext.addQuadCurve(to: smileStart, control: CGPoint(x: rect.midX, y: smileStart.y + 80))
        cgContext.closePath()
        cgContext.drawPath(using: .fillStroke)
    }
    
}

