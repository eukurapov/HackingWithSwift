//
//  UIImageWithBorder.swift
//  FlagList
//
//  Created by Evgeniy Kurapov on 13.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

extension UIImage {
    
    func imageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width + width * 2, height: size.height + width * 2))
        imageView.contentMode = .center
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color.cgColor
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}
