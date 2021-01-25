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
        
    private static func createMemoryGame(of theme: EmojiTheme) -> MemoryGame<String> {
        let emojis = theme.emojis.shuffled()
        return MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairToPlay) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    private static func createThemes() -> Array<EmojiTheme> {
        return [EmojiTheme(name: "Halloween", emojis: ["👻", "🎃", "🕷", "🧛", "🧙", "🧟", "🕸", "🦇", "🌙", "☠️"], numberOfPairToPlay: 3, color: .orange),
                EmojiTheme(name: "Animals", emojis: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐯", "🐷", "🐸"], numberOfPairToPlay: 4, color: .green),
                EmojiTheme(name: "Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🥏", "🎱", "🏓", "🏸"], numberOfPairToPlay: 5, color: .blue),
                EmojiTheme(name: "Foods", emojis: ["🍎", "🍓", "🧀", "🍉", "🍔", "🍕", "🌮", "🍰", "🍣", "🍭"], numberOfPairToPlay: 6, color: .red),
                EmojiTheme(name: "People", emojis: ["🧑🏻‍💻", "👮🏻", "👷🏻", "🧑🏻‍🌾", "🧑🏻‍🎤", "🧑🏻‍🍳", "🦹🏻", "👸🏻", "🧑🏻‍🔬", "🧑🏻‍🎓"], numberOfPairToPlay: 7, color: .pink),
                EmojiTheme(name: "Flags", emojis: ["🏴‍☠️", "🇰🇷", "🏳️‍🌈", "🇺🇸", "🇬🇷", "🇩🇪", "🇷🇺", "🇰🇵", "🇬🇧", "🇨🇦"], numberOfPairToPlay: 8, color: .yellow),]
    }
    
    // MARK: - Access to the Model
    
    var cards: Array<MemoryGame<String>.Card> {
        model.cards
    }
    
    var themeName: String {
        themes[indexOfTheme].name
    }
    
    var themeColor: Color {
        Color(themes[indexOfTheme].color)
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
        printTheme(themes[indexOfTheme])
    }
    
    private func printTheme(_ theme: EmojiTheme) {
        let encodedData = try! JSONEncoder().encode(theme)
        print(String(data: encodedData, encoding: .utf8)!)
    }
    
    struct EmojiTheme: Encodable {
        var name: String
        var emojis: Array<String>
        var color: UIColor.RGB
        var numberOfPairToPlay: Int
        
        init(name: String, emojis: Array<String>, numberOfPairToPlay: Int, color: Color) {
            self.name = name
            self.emojis = emojis
            self.numberOfPairToPlay = numberOfPairToPlay
            self.color = UIColor(color).rgb
        }
    }
}
