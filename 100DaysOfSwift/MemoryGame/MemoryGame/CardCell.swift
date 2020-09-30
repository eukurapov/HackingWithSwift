//
//  CardCell.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 30.09.2020.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    // TODO: Replace with Game.Card
    var card: Game<String>.Card! {
        didSet {
            cardContentLabel.text = card.content
        }
    }
    
    @IBOutlet private weak var cardContentLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        cardContentLabel.transform = .identity
//        let scaleFactor = frame.size.height / cardContentLabel.frame.size.height
//        let fontTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
//        cardContentLabel.transform = fontTransform
    }
    
}
