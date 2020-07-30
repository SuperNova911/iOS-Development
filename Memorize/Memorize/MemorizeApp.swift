//
//  MemorizeApp.swift
//  Memorize
//
//  Created by 김수환 on 2020/07/28.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        WindowGroup {
            let game = EmojiMemoryGame()
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
