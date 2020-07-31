//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 김수환 on 2020/07/29.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String>
    private let themes: Array<EmojiTheme>
    private var indexOfTheme: Int
    
    init() {
        themes = EmojiMemoryGame.createThemes()
        indexOfTheme = Int.random(in: 0..<themes.count);
        
        model = EmojiMemoryGame.createMemoryGame(of: themes[indexOfTheme])
    }
        
    static func createMemoryGame(of theme: EmojiTheme) -> MemoryGame<String> {
        let emojis = theme.emojis.shuffled()
        return MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairToPlay) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    static func createThemes() -> Array<EmojiTheme> {
        return [EmojiTheme(name: "Halloween", emojis: ["👻", "🎃", "🕷", "🧛", "🧙", "🧟", "🕸", "🦇", "🌙", "☠️"], color: .orange),
                EmojiTheme(name: "Animals", emojis: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐯", "🐷", "🐸"], color: .green),
                EmojiTheme(name: "Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🥏", "🎱", "🏓", "🏸"], color: .blue),
                EmojiTheme(name: "Foods", emojis: ["🍎", "🍓", "🧀", "🍉", "🍔", "🍕", "🌮", "🍰", "🍣", "🍭"], color: .red),
                EmojiTheme(name: "People", emojis: ["🧑🏻‍💻", "👮🏻", "👷🏻", "🧑🏻‍🌾", "🧑🏻‍🎤", "🧑🏻‍🍳", "🦹🏻", "👸🏻", "🧑🏻‍🔬", "🧑🏻‍🎓"], color: .pink),
                EmojiTheme(name: "Flags", emojis: ["🏴‍☠️", "🇰🇷", "🏳️‍🌈", "🇺🇸", "🇬🇷", "🇩🇪", "🇷🇺", "🇰🇵", "🇬🇧", "🇨🇦"], color: .yellow),]
    }
    
    // MARK: - Access to the Model
    
    var cards: Array<MemoryGame<String>.Card> {
        model.cards
    }
    
    var themeName: String {
        themes[indexOfTheme].name
    }
    
    var themeColor: Color {
        themes[indexOfTheme].color
    }
    
    var score: Int {
        model.score
    }
    
    // MARK: - Intent(s)
    
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
    
    func newGame() {
        indexOfTheme = Int.random(in: 0..<themes.count)
        model = EmojiMemoryGame.createMemoryGame(of: themes[indexOfTheme])
    }
    
    struct EmojiTheme {
        var name: String
        var emojis: Array<String>
        var color: Color
        
        var numberOfPairToPlay: Int {
            Int.random(in: 2...min(emojis.count, 5))
        }
    }
}
