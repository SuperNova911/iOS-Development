//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by 김수환 on 2020/07/28.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var viewModel: EmojiMemoryGame
    
    var body: some View {
        NavigationView {
            VStack {
                Grid(viewModel.cards) { card in
                        CardView(card: card).onTapGesture {
                            withAnimation(.linear(duration: cardFlipDuration)) {
                                viewModel.choose(card: card)
                            }
                        }
                        .padding(cardPadding)
                }
                Text("Score: \(viewModel.score)")
                    .font(Font.largeTitle)
            }
            .padding()
            .foregroundColor(viewModel.themeColor)
            .navigationBarTitle(viewModel.themeName)
            .navigationBarItems(trailing: Button(action: { withAnimation(Animation.easeInOut) {
                viewModel.newGame()
            } }, label: { Text("New Game") }))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Drawing Constants
    
    private let cardFlipDuration: Double = 0.75
    private let cardPadding: CGFloat = 5;
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    var body: some View {
        GeometryReader { geometry in
            body(for: geometry.size)
        }
    }
    
    @State private var animatedBonusRemaining: Double = 0
    
    private func startBonusTimeAnimation() {
        animatedBonusRemaining = card.bonusRemaining
        withAnimation(.linear(duration: card.bonusTimeRemaining)) {
            animatedBonusRemaining = 0
        }
    }
    
    @ViewBuilder
    private func body(for size: CGSize) -> some View {
        if card.isFaceUp || !card.isMatched {
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle.degrees(pieStartAngle), endAngle: Angle.degrees(-animatedBonusRemaining * 360 - 90),
                            clockwise: true)
                            .onAppear {
                                startBonusTimeAnimation()
                            }
                    } else {
                        Pie(startAngle: Angle.degrees(pieStartAngle), endAngle: Angle.degrees(-card.bonusRemaining * 360 - 90),
                            clockwise: true)
                    }
                }
                .padding(piePadding).opacity(pieOpacity)
                .transition(.identity)
                Text(card.content)
                    .font(Font.system(size: fontSize(for: size)))
                    .rotationEffect(Angle.degrees(card.isMatched ? cardRotateDegrees : 0))
                    .animation(card.isMatched ? Animation.linear(duration: cardRotateDuration).repeatForever(autoreverses: false) : .default)
            }
            .cardify(isFaceUp: card.isFaceUp)
            .transition(AnyTransition.scale)
        }
    }
    
    // MARK: - Drawing Constants
    
    private let piePadding: CGFloat = 5
    private let pieOpacity: Double = 0.4
    private let pieStartAngle: Double = 0 - 90
    private let pieEndAngle: Double = 110 - 90
    private let cardRotateDegrees: Double = 360
    private let cardRotateDuration: Double = 1
    
    private func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.7
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(card: game.cards[0])
        return EmojiMemoryGameView(viewModel: game)
    }
}
