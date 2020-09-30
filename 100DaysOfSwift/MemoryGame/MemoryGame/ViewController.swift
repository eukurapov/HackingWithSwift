//
//  ViewController.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 30.09.2020.
//

import UIKit

class ViewController: UICollectionViewController {
    
    private var game: Game<String>!
    private var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memory Game"
        
        theme = Theme.any
        game = Game<String>(numberOfPairsOfCards: theme.numberOfPairs, cardContentFactory: { [unowned self] pairIndex in
            return self.theme.emojis[pairIndex]
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardCellIdentifier, for: indexPath)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 5
        if let cardCell = cell as? CardCell {
            cardCell.card = game.cards[indexPath.item]
        }
        return cell
    }

    // MARK: - Constant Values
    
    private let cardCellIdentifier = "CardCell"

}

