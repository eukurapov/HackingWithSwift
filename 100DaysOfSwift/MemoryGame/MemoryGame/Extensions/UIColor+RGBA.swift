//
//  UIColor+RGBA.swift
//  Memorize
//
//  Created by Eugene Kurapov on 10.07.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import SwiftUI

extension Color {
    
    init(_ rgb: UIColor.RGB) {
        self.init(UIColor(rgb))
    }
    
    
    func uiColor() -> UIColor {
        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
    
    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
    
}

extension UIColor {
    
    public struct RGB: Hashable, Codable {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }
    
    convenience init(_ rgb: RGB) {
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
    }
    
    public var rgb: RGB {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGB(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

