//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 김수환 on 2020/07/29.
//

import SwiftUI

class EmojiMemoryGame {
    private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()
        
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["👻", "🎃", "🕷", "🧛", "🩸", "🧙", "🧟", "🕸", "🦇", "🧄", "🌙", "🦉"].shuffled()
        let randomNumberOfPairs = Int.random(in: 2...5)
        return MemoryGame<String>(numberOfPairsOfCards: randomNumberOfPairs) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    // MARK: - Access to the Model
    var cards: Array<MemoryGame<String>.Card> {
        model.cards
    }
    
    // MARK: - Intent(s)
    
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
