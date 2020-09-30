//
//  ViewController.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 30.09.2020.
//

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var game: Game<String>!
    private var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newGame()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(newGame))
    }
    
    @objc
    private func newGame() {
        theme = Theme.any
        game = Game<String>(numberOfPairsOfCards: theme.numberOfPairs, cardContentFactory: { [unowned self] pairIndex in
            return self.theme.emojis[pairIndex]
        })
        navigationItem.prompt = theme.name
        updateScore()
        updateCellSize()
        collectionView.reloadData()
    }
    
    private func updateScore() {
        title = "Score: \(game.score)"
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    private func updateCellSize() {
        let aspectScale: CGFloat = 4/5
        let numberOfItems = game.cards.count
        let frameHeight = collectionView.frame.height
        let frameWidth = collectionView.frame.width
        
        var rows = 1
        var cols = numberOfItems
        let getWidth = { (frameWidth - 10*CGFloat(cols+2)) / CGFloat(cols) }
        var width = getWidth()
        let getHeight = { width / aspectScale }
        var height = getHeight()
        while Int(frameHeight-20) / Int(height + 10) >= rows {
            cols -= 1
            rows = numberOfItems / cols + 1
            width = getWidth()
            height = getHeight()
        }
        cols += 1
        fixedWidth = getWidth()
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var fixedWidth: CGFloat = 128 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectScale: CGFloat = 4/5
        return CGSize(width: fixedWidth, height: fixedWidth / aspectScale)
    }
    
    // MARK: - UICollectionViewDataSource
    
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
        cell.isUserInteractionEnabled = !game.cards[indexPath.item].isMatched
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        game.choose(card: game.cards[indexPath.item])
        collectionView.reloadData()
        updateScore()
    }

    // MARK: - Constant Values
    
    private let cardCellIdentifier = "CardCell"

}

