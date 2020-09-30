//
//  CardCell.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 30.09.2020.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    var card: Game<String>.Card! {
        didSet {
            let content: String
            if card.isMatched {
                content = "✔"
            } else if card.isFaceUp {
                content = self.card.content
            } else {
                content = "❓"
            }
            cardContentLabel.text = content
        }
    }
    
    @IBOutlet private weak var cardContentLabel: UILabel!
    
}
