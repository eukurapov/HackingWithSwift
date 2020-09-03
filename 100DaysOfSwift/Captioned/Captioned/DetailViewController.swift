//
//  DetailViewController.swift
//  Captioned
//
//  Created by Eugene Kurapov on 02.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet var captionHeight: NSLayoutConstraint!
    
    var caption: String!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnTap = true
        
        title = caption
        imageView.image = image
        captionLabel.text = caption
        captionLabel.superview?.layer.cornerRadius = 7
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(onLabelTap))
        captionLabel.superview?.addGestureRecognizer(tapRecogniser)
    }
    
    @objc
    private func onLabelTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            NSLayoutConstraint.deactivate([captionHeight])
            if captionHeight.relation == .greaterThanOrEqual {
                captionHeight = NSLayoutConstraint(
                    item: captionLabel!,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1,
                    constant: 30)
            } else if captionHeight.relation == .equal {
                captionHeight = NSLayoutConstraint(
                    item: captionLabel!,
                    attribute: .height,
                    relatedBy: .greaterThanOrEqual,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1,
                    constant: 30)
            }
            NSLayoutConstraint.activate([captionHeight])
        }
    }

}
