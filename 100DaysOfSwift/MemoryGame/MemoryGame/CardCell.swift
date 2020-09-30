//
//  CardCell.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 30.09.2020.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    var cardContent: String! {
        didSet {
            cardContentLabel.text = cardContent
        }
    }
    
    @IBOutlet private weak var cardContentLabel: UILabel!
    
}
