//
//  Theme.swift
//  Memorize
//
//  Created by Eugene Kurapov on 10.07.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

struct Theme: Codable, Identifiable {
    
    static let defaults: [Theme] = [.halloween, .animals, .sports, .transport, .faces]
    
    static var any: Theme {
        defaults.randomElement()!
    }
    
    static let halloween = Theme(name: "Halloween",
                                 emojis: ["👻", "🎃", "🕷", "🧙‍♀️", "🕯"],
                                 cardStyle: CardStyle(color: .orange),
                                 numberOfPairsOfCards: 4)
    static let sports = Theme(name: "Sports",
                              emojis: ["🏃‍♂️", "⚽️", "🏀", "🎾", "🥋", "🥌", "🏋️", "🥇", "🏓", "🏒"],
                              cardStyle: CardStyle(color: .green, gradientColors: [.green, .blue]),
                              numberOfPairsOfCards: 10)
    static let animals = Theme(name: "Animals",
                               emojis: ["🐶", "🐱", "🐭", "🦊", "🐼", "🐨", "🐷"],
                               cardStyle: CardStyle(color: .systemPink, gradientColors: [.systemPink, .yellow]),
                               numberOfPairsOfCards: 5)
    static let faces = Theme(name: "Faces",
                             emojis: ["😀", "🥰", "🤪", "😎", "🤬", "😱", "🥶", "🤯", "🤢", "🥵", "😘", "🤠"],
                             cardStyle: CardStyle(color: .blue, gradientColors: [.blue, .purple]),
                             numberOfPairsOfCards: 15)
    static let transport = Theme(name: "Transport",
                            emojis: ["🚗", "🚕", "🚜", "🚒", "🏎", "🚑", "🚓"],
                            cardStyle: CardStyle(color: .purple, gradientColors: [.purple, .orange]),
                            numberOfPairsOfCards: 5)
    
    static let untitled = Theme(name: "Untitled",
                                emojis: ["🤷‍♂️", "❓"],
                                cardStyle: CardStyle(color: .green),
                                numberOfPairsOfCards: 2)
    
    var id: UUID
    var name: String
    var emojis: [String] {
        didSet(oldEmojis) {
            let diff = emojis.difference(from: oldEmojis)
            for change in diff {
                switch change {
                case let .insert(_, element, _):
                    removedEmojis.removeAll(where: { $0 == element } )
                case let .remove(_, element, _):
                    removedEmojis.append(element)
                }
            }
        }
    }
    var cardStyle: CardStyle
    var numberOfPairs: Int
    private(set) var removedEmojis: [String] = []
    
    init(id: UUID? = nil, name: String, emojis: [String], cardStyle: CardStyle, numberOfPairsOfCards: Int) {
        self.id = id ?? UUID()
        self.name = name
        self.emojis = emojis
        self.cardStyle = cardStyle
        self.numberOfPairs = max(min(numberOfPairsOfCards, emojis.count), 1)
    }
    
    var json: Data? {
        try? JSONEncoder().encode(self)
    }
    
    init?(from json: Data?) {
        if json != nil, let theme = try? JSONDecoder().decode(Theme.self, from: json!) {
            self = theme
        } else {
            return nil
        }
    }
    
    struct CardStyle: Codable {
        private var _color: UIColor.RGB!
        private var _gradientColors: [UIColor.RGB]?
        
        init(color: UIColor, gradientColors: [UIColor]? = nil) {
            self.color = color
            self.gradientColors = gradientColors
        }
        
        var color: UIColor {
            get { UIColor(_color) }
            set { _color = newValue.rgb }
        }
        
        var gradientColors: [UIColor]? {
            get { _gradientColors?.map { UIColor($0) } }
            set { _gradientColors = newValue?.map { $0.rgb } }
        }
    }
}
