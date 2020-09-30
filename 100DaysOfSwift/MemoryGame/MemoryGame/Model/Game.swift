//
//  Game.swift
//  Memorize
//
//  Created by Evgeniy Kurapov on 22.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import Foundation

// MARK: - This is a Model

struct Game<CardContent> where CardContent: Equatable {
    
    private(set) var score: Int
    private(set) var cards: [Card]
    private var theOnlyFaceUpCardIndex: Int? {
        get {
            cards.indices.filter { cards[$0].isFaceUp } .only
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    mutating func choose(card: Card) {
        if let selectedCardIndex = cards.firstIndexOf(card), !cards[selectedCardIndex].isFaceUp, !cards[selectedCardIndex].isMatched {
            if let theOnlyFaceUpCardIndex = self.theOnlyFaceUpCardIndex {
                cards[selectedCardIndex].isFaceUp = true
                if cards[selectedCardIndex].content == cards[theOnlyFaceUpCardIndex].content {
                    cards[selectedCardIndex].isMatched = true
                    cards[theOnlyFaceUpCardIndex].isMatched = true
                    score += 2 + Int((cards[selectedCardIndex].bonusPartRemaining + cards[theOnlyFaceUpCardIndex].bonusPartRemaining + 1) * 2)
                } else {
                    score -= cards[selectedCardIndex].isSeen ? 1 : 0
                    score -= cards[theOnlyFaceUpCardIndex].isSeen ? 1 : 0
                }
            } else {
                theOnlyFaceUpCardIndex = selectedCardIndex
            }
        }
    }
    
    mutating func hideAll() {
        for index in cards.indices {
            cards[index].isFaceUp = false
        }
    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        score = 0
        cards = []
        for pairIndex in 0..<numberOfPairsOfCards {
            let pairContent = cardContentFactory(pairIndex)
            cards.append(Card(content: pairContent, id: pairIndex*2))
            cards.append(Card(content: pairContent, id: pairIndex*2 + 1))
        }
        cards.shuffle()
    }
 
    struct Card: Identifiable {
        var isFaceUp: Bool = false {
            didSet {
                if oldValue == true && isFaceUp == false {
                    isSeen = true
                }
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched: Bool = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        var isSeen: Bool = false
        var content: CardContent
        var id: Int
        
        let bonusTimeLimit = TimeInterval(5)
        private(set) var bonusTimeSpent = TimeInterval(0)
        private(set) var lastFaceUp: Date!
        private(set) var timerIsOn = false
        
        var isConsumingBonus: Bool {
            isFaceUp && bonusTimeRemaining > 0 && !isMatched
        }
        
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - bonusTimeSpent)
        }
        
        var bonusPartRemaining: Double {
            bonusTimeRemaining > 0 ? bonusTimeRemaining / bonusTimeLimit : 0
        }
        
        private mutating func startUsingBonusTime() {
            if lastFaceUp == nil, bonusTimeRemaining > 0 {
                lastFaceUp = Date()
            }
        }
        
        private mutating func stopUsingBonusTime() {
            if lastFaceUp != nil {
                bonusTimeSpent += Date().timeIntervalSince(lastFaceUp)
                lastFaceUp = nil
            }
        }
    }

}
