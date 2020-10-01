//
//  CardCell.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 30.09.2020.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    var bgColor: UIColor! {
        didSet {
            faceDownView.backgroundColor = bgColor
        }
    }
    var card: Game<String>.Card! {
        didSet(oldCard) {
            cardContentLabel.text = self.card.content
        }
    }
    
    @IBOutlet weak var faceUpView: UIView!
    @IBOutlet weak var faceDownView: UIView!
    @IBOutlet private weak var cardContentLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        faceUpView.layer.borderWidth = 1
        faceUpView.layer.borderColor = UIColor.black.cgColor
        faceUpView.layer.cornerRadius = 5
        faceUpView.layer.shadowColor = UIColor.gray.cgColor
        faceUpView.layer.shadowRadius = 3
        faceUpView.layer.shadowOpacity = 0.5
        faceUpView.layer.shadowPath = UIBezierPath(roundedRect:faceDownView.bounds, cornerRadius:faceDownView.layer.cornerRadius).cgPath
        faceDownView.layer.borderWidth = 1
        faceDownView.layer.borderColor = UIColor.black.cgColor
        faceDownView.layer.cornerRadius = 5
        faceDownView.layer.shadowColor = UIColor.gray.cgColor
        faceDownView.layer.shadowRadius = 3
        faceDownView.layer.shadowOpacity = 0.5
        faceDownView.layer.shadowPath = UIBezierPath(roundedRect:faceDownView.bounds, cornerRadius:faceDownView.layer.cornerRadius).cgPath
    }
    
    func reset() {
        self.alpha = 1
        self.isHidden = false
        faceUpView.isHidden = true
        faceDownView.isHidden = false
        // update shadows ↓
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func flip() {
        if self.faceUpView.isHidden != !self.card.isFaceUp {
            UIView.transition(
                with: self.contentView,
                duration: flipDuration,
                options: .transitionFlipFromRight
            ) { [unowned self] in
                    self.faceUpView.isHidden = !self.card.isFaceUp
                    self.faceDownView.isHidden = self.card.isFaceUp
            } completion: { [unowned self] _ in
                if self.card.isMatched {
                    self.hide(after: hideDelay)
                }
            }
        } else {
            if self.card.isMatched {
                self.hide(after: flipDuration + hideDelay)
            }
        }
    }
    
    private func hide(after interval: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now()+interval) {
            UIView.animate(withDuration: self.hideDuration) {
                self.alpha = 0
            } completion: { _ in
                self.isHidden = true
            }
        }
    }
    
    private let flipDuration: TimeInterval = 0.75
    private let hideDelay: TimeInterval = 0.2
    private let hideDuration: TimeInterval = 0.2
    
}
