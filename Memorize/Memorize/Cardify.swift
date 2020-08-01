//
//  Cardify.swift
//  Memorize
//
//  Created by 김수환 on 2020/08/01.
//

import SwiftUI

struct Cardify: ViewModifier {
    let isFaceUp: Bool

    func body(content: Content) -> some View {
        ZStack {
            if isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                content
            } else {
                RoundedRectangle(cornerRadius: cornerRadius).fill()
            }
        }
    }
    
    private let cornerRadius: CGFloat = 10.0
    private let edgeLineWidth: CGFloat = 3
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
